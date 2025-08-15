import SwiftUI

struct ChickenBreedCard: View {
    let breed: ChickenBreed
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: breed.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 190)
            } placeholder: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(1.2)
                }
            }
            .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.7)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            Text(breed.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .padding(12)
        }
        .frame(width: 150, height: 190)
        .cornerRadius(15)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}
