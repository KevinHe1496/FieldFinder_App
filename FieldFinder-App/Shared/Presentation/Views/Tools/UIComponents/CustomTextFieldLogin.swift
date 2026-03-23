import SwiftUI

struct CustomTextFieldLogin: View {
    let titleKey: String
    @Binding var textField: String
    var keyboardType: UIKeyboardType
    var prompt: Text
    var colorBackground: Color
    
    var body: some View {
        
        TextField(titleKey, text: $textField, prompt: prompt)
            .font(.appDescription)
            .foregroundStyle(.primary)
            .padding()
            .background(colorBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .keyboardType(keyboardType)
    }
}

#Preview {
    CustomTextFieldLogin(titleKey: "Email", textField: .constant(""), keyboardType: .emailAddress, prompt: Text("Email"), colorBackground: .thirdColorWhite)
}
