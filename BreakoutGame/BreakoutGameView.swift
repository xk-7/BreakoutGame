import SwiftUI

struct BreakoutGameView: View {
    @State private var ballPosition: CGPoint
    @State private var ballDirection = CGSize(width: 2, height: -2) // 调整速度和方向
    @State private var paddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
    @State private var score = 0
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    let brickWidth: CGFloat = 50 // 方块宽度
    let brickHeight: CGFloat = 20 // 方块高度
    let paddleWidth: CGFloat = 100
    let paddleHeight: CGFloat = 10
    let ballSize: CGFloat = 10
    
    let totalBricks: Int = 105 // 总方块数
    let bricksPerRow: Int = 7 // 每行方块数
    
    @State private var bricks: [Bool]
    
    init() {
        _bricks = State(initialValue: Array(repeating: true, count: totalBricks))
        _ballPosition = State(initialValue: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120))
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: ballSize, height: ballSize)
                .position(ballPosition)
                .onAppear {
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                        moveBall()
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
                                if ballPosition.y == UIScreen.main.bounds.height - 120 {
                                    ballPosition.x = value.location.x
                                }
                            })

            ForEach(0..<bricks.count, id: \.self) { index in
                if bricks[index] {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: brickWidth, height: brickHeight)
                        .position(x: CGFloat((index % bricksPerRow) * Int(brickWidth + 5) + 30), y: CGFloat((index / bricksPerRow) * Int(brickHeight + 5) + 50))
                }
            }

            Text("Score: \(score)")
                .position(x: 50, y: 20)
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Game Over"),
                message: Text("You lost the ball. What would you like to do?"),
                primaryButton: .default(Text("Restart")) {
                    restartGame()
                },
                secondaryButton: .destructive(Text("Exit")) {
                    exitGame()
                }
            )
        }
    }

    private func moveBall() {
        ballPosition.x += ballDirection.width
        ballPosition.y += ballDirection.height

        // Bounce off walls
        if ballPosition.x <= 0 || ballPosition.x >= UIScreen.main.bounds.width {
            ballDirection.width *= -1
        }
        if ballPosition.y <= 0 {
            ballDirection.height *= -1
        }

        // Bounce off paddle
        if ballPosition.y >= paddlePosition.y - paddleHeight / 2 - ballSize / 2 &&
            ballPosition.x >= paddlePosition.x - paddleWidth / 2 &&
            ballPosition.x <= paddlePosition.x + paddleWidth / 2 {
            ballDirection.height *= -1
        }

        // Check for collision with bricks
        for i in 0..<bricks.count {
            if bricks[i] {
                let brickX = CGFloat((i % bricksPerRow) * Int(brickWidth + 5) + 30)
                let brickY = CGFloat((i / bricksPerRow) * Int(brickHeight + 5) + 50)
                if abs(ballPosition.x - brickX) < brickWidth / 2 && abs(ballPosition.y - brickY) < brickHeight / 2 {
                    bricks[i] = false
                    ballDirection.height *= -1
                    score += 10
                }
            }
        }

        // Game over condition
        if ballPosition.y > UIScreen.main.bounds.height {
            showAlert = true
        }
    }

    private func restartGame() {
        ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 120)
        ballDirection = CGSize(width: 2, height: -2) // Reset speed and direction
        score = 0
        bricks = Array(repeating: true, count: totalBricks)
    }
    
    private func exitGame() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct BreakoutGameView_Previews: PreviewProvider {
    static var previews: some View {
        BreakoutGameView()
    }
}
