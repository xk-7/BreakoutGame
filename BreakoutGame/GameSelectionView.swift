//
//  GameSelectionView.swift
//  BreakoutGame
//
//  Created by 小科 on 2024/7/25.
//

import SwiftUI

struct GameSelectionView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Select a Game")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: BreakoutGameView()) {
                    Text("Breakout Game")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: MemoryGameView()) {
                    Text("Memory Game")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink(destination: MatchThreeGameView()) {
                    Text("Match Three Game")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct GameSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GameSelectionView()
    }
}


