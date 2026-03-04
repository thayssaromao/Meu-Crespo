import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var weatherManager: WeatherManager
    @Environment(\.colorScheme) var colorScheme

    var item: ConteudoItem
    var climaAtual: String
    var climaChave: String
    var temperatura: String
    var vento: String
    var dataSelecionada: Date
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(item.titulo)
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(colorScheme == .light ? Color.redBrown : Color.pinky)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(climaChave.uppercased())
                        Text("\(formatarData(weatherManager.selectedDate))")
                    }
                    .font(.system(size: 15))
                    .foregroundColor(colorScheme == .light ? .gray : .white)
                    .padding(.bottom, 8)
                    
                    VStack(spacing: 10) {
                        if let conteudo = item.climas.values.first {
                            ForEach(conteudo, id: \.self) { linha in
                                GlassCardView(linha: linha)
                            }
                        } else {
                            Text("Sem informações disponíveis para este clima.")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    func formatarData(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

struct GlassCardView: View {
    @Environment(\.colorScheme) var colorScheme
    var linha: String
    private var partes: [String] {
        let componentes = linha.components(separatedBy: ": ")
        return componentes.count > 1 ? componentes : [linha, ""]
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(partes[0])
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .light ? Color.redBrown : .white)
                    .padding(.top, 4)
                
                Text(partes[1])
                    .font(.system(size: 18))
                    .foregroundColor(colorScheme == .light ? Color.redBrown : .white)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 140)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 32)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.black.opacity(0.03), lineWidth: 1)
            )
            
            Spacer()
        }
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)


    }
}

//struct GlassCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        GlassCardView()
//    }
//}

#Preview {
    CardListView()
        .environmentObject(WeatherManager())
        .padding()
}
