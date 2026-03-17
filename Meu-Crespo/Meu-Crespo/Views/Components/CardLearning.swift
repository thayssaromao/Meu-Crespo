import SwiftUI

struct CardLearning: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSheet = false
    var content: ContentModel

        var body: some View{
            Button() {
                showingSheet.toggle()
            }label:{
                ZStack {
                    Rectangle()
                      .foregroundColor(.clear)
                      .background(
                        Image("cardInfoBg")
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                          .clipped()
                      )
                      .cornerRadius(10)
                      .shadow(color: Color(red: 0.32, green: 0.13, blue: 0.02).opacity(0.6), radius: 2, x: 0, y: 4)
                    
                    HStack(alignment:.center){
                        Text(content.titulo)
                        Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(20)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.redBrown)

                }
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 360 : 700, height: 88)

            }
            .sheet(isPresented: $showingSheet) {
               ScrollView {
                   VStack(alignment: .leading, spacing: 16) {
                       Spacer()
                       Text(content.titulo)
                           .font(.system(size: 28, weight: .bold))
                           .foregroundColor(colorScheme == .light ? .redBrown : .pinky)
                       Spacer()
                       Text(content.texto)
                           .font(.system(size: 22, weight: .medium))
                           .foregroundColor(colorScheme == .light ? .redBrown : .white)
                   }
                   .foregroundStyle(Color.redBrown)
                   .padding(25)
               }
           }
    }
}
//
//#Preview {
//    LearnView()
//}
