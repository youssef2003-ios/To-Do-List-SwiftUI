import SwiftUI

struct RoundedCardField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
            } else {
                TextField(placeholder, text: $text)
                    .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    RoundedCardField(iconName: "", placeholder: "", text: .constant(""))
}
