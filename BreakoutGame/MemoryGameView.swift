//
//  MemoryGameView.swift
//  BreakoutGame
//
//  Created by 小科 on 2024/7/27.
//

import SwiftUI

struct MemoryGameView: View {
    @State private var cards: [Card] = []
    @State private var flippedCards: [Int] = []
    @State private var matchedCards: Set<Int> = []
    @State private var score = 0
    @State private var level = 1
    @State private var showLevelOverlay = false
    @State private var showGameOverOverlay = false
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [GridItem(.adaptive(minimum: 80))]
    
    init() {
        _cards = State(initialValue: MemoryGameView.generateCards(for: 1))
    }
    
    var body: some View {
        VStack {
            Text("Score: \(score)")
                .font(.largeTitle)
                .padding()
            
            Text("Level: \(level)")
                .font(.title)
                .padding()
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(cards.indices, id: \.self) { index in
                    CardView(card: cards[index], isFlipped: flippedCards.contains(index) || matchedCards.contains(index))
                        .onTapGesture {
                            flipCard(at: index)
                        }
                }
            }
            .padding()
            
            if showLevelOverlay {
                VStack {
                    Text("Level \(level)")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .background(Color.black.opacity(0.5))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showLevelOverlay = false
                        }
                    }
                }
            }
            
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
            showLevelOverlay = true
        }
    }
    
    private func flipCard(at index: Int) {
        guard !flippedCards.contains(index) && !matchedCards.contains(index) else {
            return
        }
        
        flippedCards.append(index)
        
        if flippedCards.count == 2 {
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        let firstIndex = flippedCards[0]
        let secondIndex = flippedCards[1]
        
        if cards[firstIndex].id == cards[secondIndex].id {
            matchedCards.insert(firstIndex)
            matchedCards.insert(secondIndex)
            score += 10
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                flippedCards.removeAll()
            }
        }
        
        flippedCards.removeAll()
        
        if matchedCards.count == cards.count {
            levelUp()
        }
    }
    
    private func levelUp() {
        level += 1
        score += 50
        matchedCards.removeAll()
        flippedCards.removeAll()
        cards = MemoryGameView.generateCards(for: level)
        showLevelOverlay = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showLevelOverlay = false
            }
        }
    }
    
    private func restartGame() {
        level = 1
        score = 0
        matchedCards.removeAll()
        flippedCards.removeAll()
        cards = MemoryGameView.generateCards(for: level)
        showGameOverOverlay = false
        showLevelOverlay = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showLevelOverlay = false
            }
        }
    }
    
    private func exitGame() {
        presentationMode.wrappedValue.dismiss()
    }
    
    static func generateCards(for level: Int) -> [Card] {
        var cards = [Card]()
        let pairCount = min(level * 2, 16) // 每关增加2对，最多16对
        for id in 1...pairCount {
            let card1 = Card(id: id)
            let card2 = Card(id: id)
            cards.append(card1)
            cards.append(card2)
        }
        return cards.shuffled()
    }
}

struct Card: Identifiable {
    let id: Int
}

struct CardView: View {
    let card: Card
    let isFlipped: Bool
    
    var body: some View {
        ZStack {
            if isFlipped {
                Rectangle()
                    .fill(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                Text("\(card.id)")
                    .font(.largeTitle)
                    .foregroundColor(.black)
            } else {
                Rectangle()
                    .fill(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .frame(width: 80, height: 120)
    }
}

struct MemoryGameView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryGameView()
    }
}
