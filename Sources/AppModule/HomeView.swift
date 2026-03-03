import SwiftUI

struct HomeView: View {
    @State var totalSession = 4
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack {
                    Text("POMO")
                        .font(
                            .system(size: 42, weight: .bold)
                        )
                    Text("Focus. Breath. Achieve")
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Target Sessions")
                        .font(.headline.bold())
                    
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "minus")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                        .background(.white.opacity(0.3))
                        .clipShape(Circle())
                        
                        Spacer()
                        
                        Text("\(totalSession)")
                            .font(
                                .system(size: 46, weight: .bold)
                            )
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                        .background(.white.opacity(0.3))
                        .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 20, style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 20, style: .continuous
                    )
                    .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
