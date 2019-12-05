//
//  UITextField.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/05.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import Foundation
import UIKit

private var maxLengths = [UITextField: Int]()

extension UITextField {

    @IBInspectable var maxLength: Int {
        get {
            guard let length = maxLengths[self] else {
                return Int.max
            }

            return length
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(limitLength), for: .editingChanged)
        }
    }

    @objc func limitLength(textField: UITextField) {
        guard let prospectiveText = textField.text, prospectiveText.count > maxLength else {
            return
        }

        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)

        #if swift(>=4.0)
            text = String(prospectiveText[..<maxCharIndex])
        #else
            text = prospectiveText.substring(to: maxCharIndex)
        #endif

        selectedTextRange = selection
    }

}
