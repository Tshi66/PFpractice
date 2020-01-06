//
//  EditPostViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/05.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift
import Validator

class EditPostViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, ContentScrollable {

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
    @IBOutlet weak var nameVdLabel: UILabel!
    @IBOutlet weak var themeVdLabel: UILabel!
    @IBOutlet weak var presentVdLabel: UILabel!
    @IBOutlet weak var dateVdLabel: UILabel!
    @IBOutlet weak var budgetVdLabel: UILabel!
    
    var heroImage:UIImage?
    var backImgae:UIImage?
    var tapId = 0
    var datePicker = UIDatePicker()
    var post = Post()
    var bank = Bank()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        nameTextField.delegate = self
        themeTextField.delegate = self
        presentTextField.delegate = self
        dateTextField.delegate = self
        budgetTextField.delegate = self
        
        nameTextField.text = post.name
        themeTextField.text = post.theme
        presentTextField.text = post.present
        dateTextField.text = post.date
        budgetTextField.text = "\(post.budget)"
        backImageView.image = post.backImage
        heroImageView.image = post.photo
        heroImageView.layer.cornerRadius = heroImageView.frame.size.width * 0.5
        
        bankLoad()
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
        self.next?.touchesBegan(touches, with: event)
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
    
    @IBAction func editPostButton(_ sender: UIButton) {
        
        validateTextField()
        
        if nameVdLabel.text == "ok" && themeVdLabel.text == "ok" && presentVdLabel.text == "ok" && dateVdLabel.text == "ok" && budgetVdLabel.text == "ok"  {
            
            saveAlert()
        }
        
        
    }
    
    func saveAlert() {
        
        let alert = UIAlertController(title: "ポストを編集しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        
            self.navigationController?.popToRootViewController(animated: true)
            
            self.updatePost(post: self.post)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func validateTextField() {
        
        //空白文字が含むとエラー
        let stringRule = ValidationRulePattern(pattern: "^[\\S]+$", error: ExampleValidationError("空白等は含めないで下さい"))
        //数字以外はエラー
        let budgetRule = ValidationRulePattern(pattern: "^[\\d]+$", error: ExampleValidationError("金額を入力して下さい"))
        //20../../..の型でないとエラー
        let dateRule = ValidationRulePattern(pattern: "20../../..", error: ExampleValidationError("日付を入力して下さい"))
        
        let nameValidation = nameTextField.validate(rule: stringRule)
        reflectValidateResalut(result: nameValidation, label: nameVdLabel)
        
        let themeValidation = themeTextField.validate(rule: stringRule)
        reflectValidateResalut(result: themeValidation, label: themeVdLabel)
        
        let presentValidation = presentTextField.validate(rule: stringRule)
        reflectValidateResalut(result: presentValidation, label: presentVdLabel)
        
        let dateValidation = dateTextField.validate(rule: dateRule)
        reflectValidateResalut(result: dateValidation, label: dateVdLabel)
        
        let budgetValidation = budgetTextField.validate(rule: budgetRule)
        reflectValidateResalut(result: budgetValidation, label: budgetVdLabel)
        
    }
    
    func reflectValidateResalut(result: ValidationResult, label: UILabel) {
        switch result {
        case .valid:
            label.text = "ok"
        case .invalid(let failures):
            label.text = (failures.first as? ExampleValidationError)?.message
        }
    }
    
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
    
    func updatePost(post: Post){
        do {
            try realm.write {
            
                if post.deposit > Int(self.budgetTextField.text!)! {
                    bank.saving += (post.deposit - Int(self.budgetTextField.text!)!)
                    
                    post.deposit -= (post.deposit - Int(self.budgetTextField.text!)!)
                }
                
                post.name = self.nameTextField.text!
                post.theme = self.themeTextField.text!
                post.present = self.presentTextField.text!
                post.date = self.dateTextField.text!
                post.budget = Int(self.budgetTextField.text!)!
                post.backImage = self.backImageView.image
                post.photo = self.heroImageView.image
                
            }
        } catch {
            print("Error saving post \(error)")
        }
    }
    
    func bankLoad() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
        }
    }

}

extension EditPostViewController: UIImagePickerControllerDelegate{
    
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
