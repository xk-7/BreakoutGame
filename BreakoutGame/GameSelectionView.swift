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
                    .fontWeight(.bold)
                    .padding()
                
                NavigationLink(destination: BreakoutGameView()) {
                    Text("Play Breakout")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // 可以在这里添加更多游戏选项
                
                Spacer()
            }
        }
    }
}

struct GameSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GameSelectionView()
    }
}

