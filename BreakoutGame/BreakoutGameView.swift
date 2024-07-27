import SwiftUI

struct BreakoutGameView: View {
    @State private var ballPositions: [CGPoint]
    @State private var ballDirections: [CGSize]
    @State private var paddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
    @State private var score = 0
    @State private var level = 1
    @State private var showLevelOverlay = true
    @State private var showGameOverOverlay = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    let initialPaddleWidth: CGFloat = 100
    let paddleHeight: CGFloat = 10
    let ballSize: CGFloat = 10
    
    // 设置每关的砖块宽度
    var brickWidth: CGFloat {
        switch level {
        case 1:
            return 40 // 第一关砖块宽度
        case 2:
            return 30 // 第二关砖块宽度
        default:
            return 40
        }
    }
    
    // 根据砖块宽度计算每行的砖块数量
    var bricksPerRow: Int {
        return Int(UIScreen.main.bounds.width / brickWidth)
    }
    
    var brickHeight: CGFloat {
        return brickWidth / 2
    }
    
    var totalBricks: Int {
        switch level {
        case 1:
            return bricksPerRow * 2 // 第一关的砖块数量为2行
        case 2:
            return bricksPerRow * 5 // 第二关的砖块数量为5行
        default:
            return bricksPerRow * 2
        }
    }
    
    var paddleWidth: CGFloat {
        switch level {
        case 1:
            return initialPaddleWidth
        case 2:
            return initialPaddleWidth - 60 // 第二关难度增加，减少挡板长度
        default:
            return initialPaddleWidth
        }
    }
    
    @State private var bricks: [Brick]
    
    init() {
        _bricks = State(initialValue: BreakoutGameView.generateBricks(for: 1))
        _ballPositions = State(initialValue: [CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120)])
        _ballDirections = State(initialValue: [CGSize(width: 2, height: -2)])
    }
    
    static func generateBricks(for level: Int) -> [Brick] {
        let totalBricks = level == 1 ? 20 : 50
        return (0..<totalBricks).map { _ in
            let type: BrickType
            let random = Int.random(in: 1...100)
            if random <= 10 {
                type = .bomb
            } else if random <= 20 {
                type = .multiBall
            } else {
                type = .normal
            }
            return Brick(type: type)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<ballPositions.count, id: \.self) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: ballSize, height: ballSize)
                        .position(ballPositions[index])
                }
                .onAppear {
                    AudioManager.shared.playBackgroundMusic() // 播放背景音乐
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                        moveBalls()
                    }
                    timer.fire()
                }

                Rectangle()
                    .fill(Color.gray)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(paddlePosition)
                    .gesture(DragGesture()
                                .onChanged { value in
                                    paddlePosition.x = value.location.x
                                    for i in 0..<ballPositions.count where ballPositions[i].y == UIScreen.main.bounds.height - 120 {
                                        ballPositions[i].x = value.location.x
                                    }
                                })

                ForEach(0..<bricks.count, id: \.self) { index in
                    if bricks[index].isActive {
                        Rectangle()
                            .fill(bricks[index].color)
                            .frame(width: brickWidth, height: brickHeight)
                            .position(x: CGFloat((index % bricksPerRow) * Int(brickWidth + 5) + 30),
                                      y: CGFloat((index / bricksPerRow) * Int(brickHeight + 5) + 50))
                    }
                }

                VStack {
                    Text("Score: \(score)")
                    Text("Level: \(level)")
                    Button(action: skipToSecondLevel) {
                        Text("Skip to Level 2")
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, geometry.safeAreaInsets.top)
                .frame(maxWidth: .infinity, alignment: .topLeading)
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
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func moveBalls() {
        for i in 0..<ballPositions.count {
            ballPositions[i].x += ballDirections[i].width
            ballPositions[i].y += ballDirections[i].height

            // Bounce off walls
            if ballPositions[i].x <= 0 || ballPositions[i].x >= UIScreen.main.bounds.width {
                ballDirections[i].width *= -1
            }
            if ballPositions[i].y <= 0 {
                ballDirections[i].height *= -1
            }

            // Bounce off paddle
            if ballPositions[i].y >= paddlePosition.y - paddleHeight / 2 - ballSize / 2 &&
                ballPositions[i].x >= paddlePosition.x - paddleWidth / 2 &&
                ballPositions[i].x <= paddlePosition.x + paddleWidth / 2 {
                ballDirections[i].height *= -1
                AudioManager.shared.playSoundEffect(name: "bounce")
            }

            // Check for collision with bricks
            for j in 0..<bricks.count {
                if bricks[j].isActive {
                    let brickX = CGFloat((j % bricksPerRow) * Int(brickWidth + 5) + 30)
                    let brickY = CGFloat((j / bricksPerRow) * Int(brickHeight + 5) + 50)
                    
                    if abs(ballPositions[i].x - brickX) < brickWidth / 2 && abs(ballPositions[i].y - brickY) < brickHeight / 2 {
                        bricks[j].isActive = false
                        ballDirections[i].height *= -1
                        score += 10
                        AudioManager.shared.playSoundEffect(name: "brick_break")
                        
                        // Check for power-up or bomb
                        if bricks[j].type == .bomb {
                            showGameOverOverlay = true
                            AudioManager.shared.playSoundEffect(name: "game_over")
                        } else if bricks[j].type == .multiBall {
                            addBalls()
                        }
                    }
                }
            }

            // Game over condition
            if ballPositions[i].y > UIScreen.main.bounds.height {
                ballPositions.remove(at: i)
                ballDirections.remove(at: i)
                if ballPositions.isEmpty {
                    showGameOverOverlay = true
                    AudioManager.shared.playSoundEffect(name: "game_over")
                }
                break
            }
        }

        // Check if all bricks are cleared
        if bricks.allSatisfy({ !$0.isActive }) {
            levelUp()
        }
    }

    private func addBalls() {
        let newBallPositions = ballPositions.map { _ in
            CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120)
        }
        let newBallDirections = ballPositions.map { _ in
            CGSize(width: CGFloat.random(in: -2...2), height: -2)
        }
        ballPositions.append(contentsOf: newBallPositions)
        ballDirections.append(contentsOf: newBallDirections)
    }

    private func levelUp() {
        level += 1
        showLevelOverlay = true
        bricks = BreakoutGameView.generateBricks(for: level)
        ballPositions = [CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120)]
        ballDirections = [CGSize(width: 2, height: -2)] // Reset speed and direction
        paddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
        
        // 确保关卡浮窗在2秒后消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showLevelOverlay = false
            }
        }
    }

    private func restartGame() {
        level = 1
        score = 0
        showLevelOverlay = true
        showGameOverOverlay = false
        bricks = BreakoutGameView.generateBricks(for: level)
        ballPositions = [CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120)]
        ballDirections = [CGSize(width: 2, height: -2)] // Reset speed and direction
        paddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
        
        // 确保关卡浮窗在2秒后消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showLevelOverlay = false
            }
        }
    }
    
    private func skipToSecondLevel() {
        level = 2
        score = 0
        showLevelOverlay = true
        showGameOverOverlay = false
        bricks = BreakoutGameView.generateBricks(for: level)
        ballPositions = [CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120)]
        ballDirections = [CGSize(width: 2, height: -2)] // Reset speed and direction
        paddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
        
        // 确保关卡浮窗在2秒后消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showLevelOverlay = false
            }
        }
    }
    
    private func exitGame() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct Brick {
    var isActive: Bool = true
    var type: BrickType = .normal
    var color: Color {
        switch type {
        case .normal:
            return .red
        case .bomb:
            return .black
        case .multiBall:
            return .green
        }
    }
}

enum BrickType {
    case normal
    case bomb
    case multiBall
}

struct BreakoutGameView_Previews: PreviewProvider {
    static var previews: some View {
        BreakoutGameView()
    }
}
