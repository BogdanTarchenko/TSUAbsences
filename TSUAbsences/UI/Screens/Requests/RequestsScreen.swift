import SwiftUI

struct RequestsScreen: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                Text("Заявки")
                    .foregroundColor(Color(hex: "346CB0"))
            }
            .navigationTitle("Заявки")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
} 
