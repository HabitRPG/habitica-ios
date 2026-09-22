//
//  FocusableTextField.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.12.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI

extension Font.Weight {
    var asUIFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .black:
            return .black
        case .light:
            return .light
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .medium:
            return .medium
        case .regular:
            return .regular
        case .semibold:
            return .semibold
        case .thin:
            return .thin
        default:
            return .regular
        }
    }
}

// Use for TextField to become first Responder
// Source: https://stackoverflow.com/questions/56507839/swiftui-how-to-make-textfield-become-first-responder
struct FocusableTextField: UIViewRepresentable {
    @Binding public var isFirstResponder: Bool
    @Binding public var text: String
    public var placeholder: String
    
    public var onReturnPressed: (() -> Void)?
    public var shouldChangeText: ((String) -> Bool)?
    
    public var configuration = { (_: UITextField) in }

    public init(placeholder: String, text: Binding<String>, isFirstResponder: Binding<Bool>,
                onReturnPressed: (() -> Void)? = nil, shouldChangeText: ((String) -> Bool)? = nil,
                configuration: @escaping (UITextField) -> Void = { _ in }) {
        self.configuration = configuration
        self._text = text
        self.placeholder = placeholder
        self.onReturnPressed = onReturnPressed
        self.shouldChangeText = shouldChangeText
        self._isFirstResponder = isFirstResponder
    }

    public func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        if #available(iOS 26.0, *) {
            if let font = context.environment.font?.resolve(in: context.environment.fontResolutionContext) {
                view.font = UIFont.systemFont(ofSize: font.pointSize, weight: font.weight.asUIFontWeight)
            }
        }
        view.textColor = context.environment.tintColor?.uiColor()
        return view
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.text = $text
        context.coordinator.onReturnPressed = onReturnPressed
        context.coordinator.shouldChangeText = shouldChangeText
        uiView.placeholder = placeholder
        if uiView.text != text {
            uiView.text = text
        }
        if #available(iOS 26.0, *) {
            if let font = context.environment.font?.resolve(in: context.environment.fontResolutionContext) {
                uiView.font = UIFont.systemFont(ofSize: font.pointSize, weight: font.weight.asUIFontWeight)
            }
        }
        uiView.textColor = context.environment.tintColor?.uiColor()
        configuration(uiView)
        if isFirstResponder && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFirstResponder && uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($text, isFirstResponder: $isFirstResponder, onReturnPressed: onReturnPressed, shouldChangeText: shouldChangeText)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>
        var onReturnPressed: (() -> Void)?
        var shouldChangeText: ((String) -> Bool)?

        init(_ text: Binding<String>, isFirstResponder: Binding<Bool>, onReturnPressed: (() -> Void)?,
             shouldChangeText: ((String) -> Bool)? = nil) {
            self.text = text
            self.isFirstResponder = isFirstResponder
            self.onReturnPressed = onReturnPressed
            self.shouldChangeText = shouldChangeText
        }

        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let shouldChangeText = shouldChangeText else {
                return true
            }
            let current = textField.text ?? ""
            guard let stringRange = Range(range, in: current) else {
                return true
            }
            return shouldChangeText(current.replacingCharacters(in: stringRange, with: string))
        }

        @objc
        public func textViewDidChange(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
            let normalized = self.text.wrappedValue
            if textField.text != normalized {
                textField.text = normalized
            }
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            self.isFirstResponder.wrappedValue = true
            DispatchQueue.main.async {
                let newPosition = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            self.isFirstResponder.wrappedValue = false
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let action = onReturnPressed {
                action()
                return false
            }
            return true
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
