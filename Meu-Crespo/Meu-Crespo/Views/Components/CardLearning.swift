import SwiftUI

struct CardLearning: View {
    @State private var showingSheet = false
    var content: ContentModel

        var body: some View{
            Button() {
                showingSheet.toggle()
            }label:{
                ZStack {
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 360, height: 88)
                      .background(
                        Image("cardInfoBg")
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                          .frame(width: 360, height: 88)
                          .clipped()
                      )
                      .cornerRadius(10)
                      .shadow(color: Color(red: 0.32, green: 0.13, blue: 0.02).opacity(0.6), radius: 2, x: 0, y: 4)
                    
                    
                    HStack(alignment:.center){
                        Text(content.titulo)
                        Spacer()
                            Image(systemName: "chevron.right")
                        }.frame(width: 301)
                        .font(.system(size: 20, weight: .bold))
                          .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                        
                    
                    
                }
                .frame(width: 350)
            }
            .sheet(isPresented: $showingSheet) {
               ScrollView {
                   VStack(alignment: .leading, spacing: 16) {
                       Spacer()
                       Text(content.titulo)
                           .font(.system(size: 28, weight: .bold))
                       Spacer()
                       Text(content.texto)
                           .font(.system(size: 22, weight: .medium))
                   }
                   .foregroundStyle(Color.redBrown)
                   .padding(25)
               }
           }
    }
}

#Preview {
    LearnView()
}
