import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            if isActive {
                GameSelectionView()
            } else {
                VStack {
                    Text("Welcome to Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Loading...")
                        .font(.headline)
                        .padding()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
