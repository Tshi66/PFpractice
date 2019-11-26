//
//  CreatePostViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/18.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, ContentScrollable {

    //MARC: Properties
    @IBOutlet weak var themeIcon: UILabel!
    @IBOutlet weak var presentIcon: UILabel!
    @IBOutlet weak var dateIcon: UILabel!
    @IBOutlet weak var budgetIcon: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var themeTextField: UITextField!
    @IBOutlet weak var presentTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var heroImage:UIImage?
    var backImgae:UIImage?
    var tapId = 0
    
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        themeTextField.delegate = self
        presentTextField.delegate = self
        dateTextField.delegate = self
        budgetTextField.delegate = self
        
        setDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //FAアイコン。
        fontAwesomeIconSet()
        configureObserver()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeObserver()
        super.viewWillDisappear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func fontAwesomeIconSet(){
        let font = UIFont.fontAwesome(ofSize: 20.0, style: .regular)
        let color = UIColor.init(red: 219/255, green: 68/255, blue: 55/255, alpha: 1.0)

        themeIcon.font = font
        themeIcon.text = String.fontAwesomeIcon(name: .heart)
        themeIcon.textColor = color
        presentIcon.font = font
        presentIcon.text = String.fontAwesomeIcon(name: .gem)
        presentIcon.textColor = color
        dateIcon.font = font
        dateIcon.text = String.fontAwesomeIcon(name: .calendarAlt)
        dateIcon.textColor = color
        budgetIcon.font = font
        budgetIcon.text = String.fontAwesomeIcon(name: .moneyBillAlt)
        budgetIcon.textColor = color
    }
    
    func setDatePicker() {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = toolbar
        
    }
    
    @objc func done() {
        dateTextField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    //MARC: IBAction
    

    @IBAction func backTapGesture(_ sender: UITapGestureRecognizer) {
        setImgPicker()
        tapId = 1
    }
    @IBAction func heroTapGesture(_ sender: UITapGestureRecognizer) {
        setImgPicker()
        tapId = 0
    }
    func setImgPicker(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
}

extension CreatePostViewController: UIImagePickerControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        if tapId == 0 {
            heroImage = pickerImage
        } else {
            backImgae = pickerImage
        }
        
        picker.dismiss(animated: true) {
            if self.tapId == 0 {
                self.heroImageView.image = self.heroImage
                self.heroImageView.layer.cornerRadius = self.heroImageView.frame.size.width * 0.5
            } else {
                self.backImageView.image = self.backImgae
            }
        }
    }
}

//scrollViewを拡張。
extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
}

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
