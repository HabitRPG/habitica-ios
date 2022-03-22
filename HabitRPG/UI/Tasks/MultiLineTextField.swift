//
//  MultiLineTextField.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.10.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import UIKit

private struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?
    var onEditingChanged: ((Bool) -> Void)?
    var giveInitialResponder = false
    var textColor = UIColor.black

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.textColor = textColor
        textField.tintColor = textColor
        if nil != onDone {
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        
        if giveInitialResponder {
            textField.becomeFirstResponder()
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    @State private var wasAssignedResponder = false
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        if giveInitialResponder && uiView.isFirstResponder && !wasAssignedResponder {
            uiView.becomeFirstResponder()
            wasAssignedResponder = true
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        var onEditingChanged: ((Bool) -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if let onEditingChanged = onEditingChanged {
                onEditingChanged(true)
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if let onEditingChanged = onEditingChanged {
                onEditingChanged(false)
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }

}

struct MultilineTextField: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?
    private var onEditingChanged: ((Bool) -> Void)?
    private var giveInitialResponder = false
    private var textColor: Color

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text }) {
            self.text = $0
        }
    }

    @State private var dynamicHeight: CGFloat = 40

    init (_ placeholder: String = "", text: Binding<String>, onCommit: (() -> Void)? = nil, onEditingChanged: ((Bool) -> Void)? = nil, giveInitialResponder: Bool = false, textColor: Color) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
        self.giveInitialResponder = giveInitialResponder
        self.textColor = textColor
        self._text = text
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit, onEditingChanged: onEditingChanged, giveInitialResponder: giveInitialResponder, textColor: textColor.uiColor())
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
    }
}

#if DEBUG
struct MultilineTextField_Previews: PreviewProvider {
    static var test: String = ""// some very very very long description string to be initially wider than screen"
    static var testBinding = Binding<String>(get: { test }, set: {
//        print("New value: \($0)")
        test = $0 })

    static var previews: some View {
        VStack(alignment: .leading) {
            Text("Description:")
            MultilineTextField("Enter some text here", text: testBinding, onCommit: {
                print("Final text: \(test)")
            })
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black))
            Text("Something static here...")
            Spacer()
        }
        .padding()
    }
}
#endif
