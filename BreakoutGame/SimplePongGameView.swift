//
//  SimplePongGameView.swift
//  BreakoutGame
//
//  Created by 小科 on 2024/7/27.
//

import SwiftUI

struct SimplePongGameView: View {
    @State private var ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State private var ballDirection = CGSize(width: 2, height: 2)
    @State private var paddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
    @State private var score = 0
    @State private var showGameOverOverlay = false
    @Environment(\.presentationMode) var presentationMode
    
    let paddleWidth: CGFloat = 100
    let paddleHeight: CGFloat = 10
    let ballSize: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
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
                                })
                
                VStack {
                    Text("Score: \(score)")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
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
            score += 1
        }
        
        // Game over condition
        if ballPosition.y > UIScreen.main.bounds.height {
            showGameOverOverlay = true
        }
    }
    
    private func restartGame() {
        ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        ballDirection = CGSize(width: 2, height: 2)
        paddlePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
        score = 0
        showGameOverOverlay = false
    }
    
    private func exitGame() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SimplePongGameView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePongGameView()
    }
}
