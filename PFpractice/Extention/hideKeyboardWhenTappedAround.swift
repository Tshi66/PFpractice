//
//  hideKeyboardWhenTappedAround.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2020/01/09.
//  Copyright © 2020 渡辺崇博. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
