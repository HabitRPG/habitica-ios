//
//  FocusableTextField.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.12.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI

// Use for TextField to become first Responder
// Source: https://stackoverflow.com/questions/56507839/swiftui-how-to-make-textfield-become-first-responder
struct FocusableTextField: UIViewRepresentable {
    @Binding public var isFirstResponder: Bool
    @Binding public var text: String
    public var placeholder: String
    
    public var configuration = { (_: UITextField) in }

    public init(placeholder: String, text: Binding<String>, isFirstResponder: Binding<Bool>, configuration: @escaping (UITextField) -> Void = { _ in }) {
        self.configuration = configuration
        self._text = text
        self.placeholder = placeholder
        self._isFirstResponder = isFirstResponder
    }

    public func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        view.textColor = ThemeService.shared.theme.primaryTextColor
        return view
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.placeholder = placeholder
        uiView.text = text
        configuration(uiView)
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($text, isFirstResponder: $isFirstResponder)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>

        init(_ text: Binding<String>, isFirstResponder: Binding<Bool>) {
            self.text = text
            self.isFirstResponder = isFirstResponder
        }

        @objc
        public func textViewDidChange(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            self.isFirstResponder.wrappedValue = true
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            self.isFirstResponder.wrappedValue = false
        }
    }
}

struct FocusableTextFieldPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            FocusableTextField(placeholder: "Placeholder",
                               text: .constant("This is a long overflowing textfield that will stay the right width hopefully"),
                               isFirstResponder: .constant(false)).background(Color.red).padding()
        }
    }
}
