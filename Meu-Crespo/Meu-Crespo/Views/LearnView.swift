import SwiftUI

struct LearnView: View {
    @State var nome: String = "Fulano"
    @State private var contents: [ContentModel] = []
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack( alignment: .leading, spacing: 24){
                    Text("Olá, \(nome)!")
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Aqui você pode explorar diversos assuntos relacionados a cuidados com o  seu cabelo crespo!")
                      .font(Font.custom("SF Pro", size: 18))
                      .foregroundColor(.black)

                    Spacer()
                    
                    VStack(spacing: 25){
                        ForEach(contents) { content in
                           CardLearning(content: content)
                       }
                    }
                }.padding()
    //            .toolbar {
    //                ToolbarItem(placement: .topBarLeading) {
    //                    Menu {
    //                          opçao de linguas pode ser aqui?
    //                    } label: {
    //                        Label("Tema", systemImage: "circle.lefthalf.filled")
    //                    }
    //                }
    //            }
            }
            .onAppear {
                contents = ContentService.loadContents()
            }
        }
            
    }
}
