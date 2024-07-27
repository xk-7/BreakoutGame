import SwiftUI

struct MatchThreeGameView: View {
    @State private var grid: [[Tile]] = MatchThreeGameView.generateGrid(for: 1)
    @State private var score = 0
    @State private var selectedTiles: [Coordinate] = []
    @State private var level = 1
    @State private var showGameOverOverlay = false
    @Environment(\.presentationMode) var presentationMode
    
    let rows = 7
    let cols = 6
    let tileSize: CGFloat = 40
    
    var body: some View {
        VStack {
            Text("Score: \(score)")
                .font(.largeTitle)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(tileSize)), count: cols)) {
                ForEach(0..<grid.count, id: \.self) { row in
                    ForEach(0..<grid[row].count, id: \.self) { col in
                        TileView(tile: grid[row][col], isSelected: selectedTiles.contains(Coordinate(row: row, col: col)))
                            .frame(width: tileSize, height: tileSize)
                            .onTapGesture {
                                selectTile(row: row, col: col)
                            }
                    }
                }
            }
            .padding()
            
            if showGameOverOverlay {
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .padding()
                    Text("Your score: \(score)")
                        .font(.title)
                        .padding()
                    
                    HStack {
                        Button(action: restartGame) {
                            Text("Restart")
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: exitGame) {
                            Text("Exit")
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .background(Color.black.opacity(0.5))
            }
        }
        .padding()
        .onAppear {
            processMatches()
        }
    }
    
    private func selectTile(row: Int, col: Int) {
        let selectedCoordinate = Coordinate(row: row, col: col)
        if selectedTiles.contains(selectedCoordinate) {
            return
        }
        selectedTiles.append(selectedCoordinate)
        
        if selectedTiles.count == 3 {
            let firstType = grid[selectedTiles[0].row][selectedTiles[0].col].type
            if selectedTiles.allSatisfy({ grid[$0.row][$0.col].type == firstType }) {
                // 消除三个相同类型的方块
                for tile in selectedTiles {
                    grid[tile.row][tile.col].type = .empty
                }
                score += 30
                withAnimation {
                    processMatches()
                }
            }
            selectedTiles.removeAll()
        }
    }
    
    private func checkForMatches() -> Bool {
        var matchedTiles = Set<Coordinate>()
        
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                let currentTile = grid[row][col]
                if col < grid[row].count - 2, currentTile.type == grid[row][col + 1].type, currentTile.type == grid[row][col + 2].type {
                    matchedTiles.insert(Coordinate(row: row, col: col))
                    matchedTiles.insert(Coordinate(row: row, col: col + 1))
                    matchedTiles.insert(Coordinate(row: row, col: col + 2))
                }
                if row < grid.count - 2, currentTile.type == grid[row + 1][col].type, currentTile.type == grid[row + 2][col].type {
                    matchedTiles.insert(Coordinate(row: row, col: col))
                    matchedTiles.insert(Coordinate(row: row + 1, col: col))
                    matchedTiles.insert(Coordinate(row: row + 2, col: col))
                }
            }
        }
        
        if !matchedTiles.isEmpty {
            for coordinate in matchedTiles {
                grid[coordinate.row][coordinate.col].type = .empty
            }
            return true
        }
        
        return false
    }
    
    private func processMatches() {
        while checkForMatches() {
            removeMatchesAndDropTiles()
            fillEmptyTiles()
        }
        if level == 1 && grid.allSatisfy({ row in row.allSatisfy { $0.type == .empty } }) {
            levelUp()
        } else if level == 2 {
            if !canMatch() {
                if grid.count < rows {
                    addRow()
                } else {
                    showGameOverOverlay = true
                }
            }
        }
    }
    
    private func removeMatchesAndDropTiles() {
        for col in 0..<cols {
            var emptyCount = 0
            for row in (0..<grid.count).reversed() {
                if grid[row][col].type == .empty {
                    emptyCount += 1
                } else if emptyCount > 0 {
                    grid[row + emptyCount][col].type = grid[row][col].type
                    grid[row][col].type = .empty
                }
            }
        }
    }
    
    private func fillEmptyTiles() {
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if grid[row][col].type == .empty {
                    grid[row][col].type = TileType.random()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.checkForMatches() {
                self.score += 10
                self.processMatches()
            }
        }
    }
    
    private func canMatch() -> Bool {
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                let currentTile = grid[row][col]
                if col < grid[row].count - 2, currentTile.type == grid[row][col + 1].type, currentTile.type == grid[row][col + 2].type {
                    return true
                }
                if row < grid.count - 2, currentTile.type == grid[row + 1][col].type, currentTile.type == grid[row + 2][col].type {
                    return true
                }
            }
        }
        return false
    }
    
    private func addRow() {
        let newRow = Array(repeating: Tile(type: TileType.random()), count: cols)
        grid.insert(newRow, at: 0)
    }
    
    private func levelUp() {
        level = 2
        grid = MatchThreeGameView.generateGrid(for: 2)
        score += 50
    }
    
    private func restartGame() {
        grid = MatchThreeGameView.generateGrid(for: 1)
        score = 0
        level = 1
        selectedTiles.removeAll()
        showGameOverOverlay = false
        processMatches()
    }
    
    private func exitGame() {
        presentationMode.wrappedValue.dismiss()
    }
    
    static func generateGrid(for level: Int) -> [[Tile]] {
        var grid = [[Tile]]()
        let cols = 6
        if level == 1 {
            let tiles = [
                Tile(type: .red), Tile(type: .red), Tile(type: .red),
                Tile(type: .green), Tile(type: .green), Tile(type: .green)
            ]
            var shuffledTiles = tiles.shuffled()
            grid.append(shuffledTiles)
        } else if level == 2 {
            for _ in 0..<2 {
                var rowArray = [Tile]()
                for _ in 0..<cols {
                    rowArray.append(Tile(type: TileType.random()))
                }
                grid.append(rowArray)
            }
        }
        return grid
    }
}

struct Tile: Identifiable {
    let id = UUID()
    var type: TileType
}

enum TileType: CaseIterable {
    case red, blue, green, yellow, purple, empty
    
    static func random() -> TileType {
        return allCases.filter { $0 != .empty }.randomElement()!
    }
}

struct Coordinate: Hashable {
    let row: Int
    let col: Int
}

struct TileView: View {
    let tile: Tile
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            if tile.type != .empty {
                Rectangle()
                    .fill(color(for: tile.type))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                    )
            }
        }
    }
    
    private func color(for type: TileType) -> Color {
        switch type {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .purple:
            return .purple
        case .empty:
            return .clear
        }
    }
}

struct MatchThreeGameView_Previews: PreviewProvider {
    static var previews: some View {
        MatchThreeGameView()
    }
}
