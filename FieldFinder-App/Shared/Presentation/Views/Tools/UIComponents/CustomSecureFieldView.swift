//
//  CustomSecureFieldView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 8/5/25.
//


import SwiftUI

struct CustomSecureFieldView: View {
    
    let titleKey: LocalizedStringKey
    @Binding var textField: String
    var keyboardType: UIKeyboardType
    var prompt: Text
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack {
            Group {
                if isPasswordVisible {
                    TextField(titleKey, text: $textField)
                        .font(.appDescription)
                        .padding(.vertical, 12)
                    
                    
                } else {
                    SecureField(titleKey, text: $textField, prompt: prompt)
                        .font(.appDescription)
                        .padding(.vertical, 12)
                    
                    
                }
                
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.primaryColorGreen)
                }
            }
        }
        .padding()
        .frame(height: 53)
        .background(.thirdColorWhite)
        .clipShape(.buttonBorder)
    }
}

#Preview {
    CustomSecureFieldView(titleKey: "Password", textField: .constant("123456"), keyboardType: .default, prompt: Text("Enter your password"))
}

