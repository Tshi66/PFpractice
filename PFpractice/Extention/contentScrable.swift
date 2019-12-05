//
//  contentScrable.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/03.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import Foundation
import UIKit

protocol ContentScrollable {
    /// ViewController上で@IBOutletでStoryboardと接続されている前提
    var scrollView: UIScrollView! { get }

    /// Notificationを設定
    /// （viewWillAppearで呼ぶ）
    func configureObserver()

    /// Notificationを削除
    /// (viewWillDisappearで呼ぶ)
    func removeObserver()
}

extension ContentScrollable where Self: UIViewController {
    func configureObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
            self.keyboardWillHide(notification)
        }
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    /// キーボードが表示される時の処理
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        scrollView.contentInset.bottom = keyboardSize
    }

    /// キーボードが隠れる時の処理
    func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
