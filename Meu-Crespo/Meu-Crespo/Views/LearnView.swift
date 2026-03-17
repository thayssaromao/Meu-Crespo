import SwiftUI

struct LearnView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("userName") var userName: String = "Usuário"
    @State private var contents: [ContentModel] = []
    
    var body: some View {
        NavigationStack {
            ZStack{
                (colorScheme == .light ? Color.white : Color.brownBg)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack( alignment: .center, spacing: 24){
                        Text("Olá, \(userName)!")
                            .font(.system(size:30, weight: .bold))
                            .foregroundColor(colorScheme == .light ? .redBrown : .white)
                        
                        Text("Aqui você pode explorar diversos assuntos relacionados a cuidados com o  seu cabelo crespo!")
                          .font(Font.custom("SF Pro", size: 18))
                          .foregroundColor(colorScheme == .light ? .redBrown : .white)

                        Spacer()
                        
                        VStack(spacing: 25){
                            ForEach(contents) { content in
                               CardLearning(content: content)
                           }
                        }
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color.brownBg)
                    .ignoresSafeArea()
                }
                .onAppear {
                    contents = ContentService.loadContents()
                }
            }
        }
            
    }
}

//#Preview {
//    LearnView()
//}
