//
//  CocoaTextField.swift
//  SceneSwitcher
//
//  Created by Nick Stull on 4/18/25.
//

import SwiftUI
import AppKit

struct CocoaTextField: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(string: text)
        textField.isEditable = true
        textField.isSelectable = true
        textField.focusRingType = .default
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textField.delegate = context.coordinator
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CocoaTextField

        init(_ parent: CocoaTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.text = textField.stringValue
        }
    }
}
