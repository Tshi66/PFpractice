//
//  PostToFinishedViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2020/01/12.
//  Copyright © 2020 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift
import Validator
import Lottie

class PostToFinishedViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, ContentScrollable {
    
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var realThemeTextField: UITextField!
    @IBOutlet weak var realPresentTextField: UITextField!
    @IBOutlet weak var realDateTextField: UITextField!
    @IBOutlet weak var realCostTextField: UITextField!
    @IBOutlet weak var realThemeVdLabel: UILabel!
    @IBOutlet weak var realPresentVdLabel: UILabel!
    @IBOutlet weak var realDateVdLabel: UILabel!
    @IBOutlet weak var realCostVdLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var post = Post()
    var bank = Bank()
    let realm = try! Realm()
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        
        realThemeTextField.delegate = self
        realPresentTextField.delegate = self
        realDateTextField.delegate = self
        realCostTextField.delegate = self
        
        setAnimation()
        setDatePicker()
        setPostData()
        hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureObserver()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObserver()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func setAnimation(){
        
        let explosionAnimation = Animation.named("explosion")
        animationView.animation = explosionAnimation
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.8
        animationView.respectAnimationFrameRate = true
        animationView.play()
    }
    
    func setPostData(){
        
        realThemeTextField.text = post.theme
        realPresentTextField.text = post.present
        realDateTextField.text = post.date
        realCostTextField.text = "\(post.deposit)"
        heroImageView.image = post.photo
        heroImageView.layer.cornerRadius = heroImageView.frame.size.width * 0.5
    }
    
    func setDatePicker() {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        realDateTextField.inputView = datePicker
        realDateTextField.inputAccessoryView = toolbar
        
    }
    
    @objc func done() {
        realDateTextField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        realDateTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    @IBAction func doneFinishButton(_ sender: UIButton) {
        
        validateTextField()
        
        //アニメーションのデバック
        if animationView.isAnimationPlaying == true {
            print("再生中")
        } else {
            print("停止中")
        }
        
        if realThemeVdLabel.text == "ok" && realDateVdLabel.text == "ok" && realPresentVdLabel.text == "ok" && realCostVdLabel.text == "ok" {
            
            //アニメーションの停止
            animationView.stop()
            
            modifyPost(post: post)
            
            navigationController?.isNavigationBarHidden = false
            tabBarController?.tabBar.isHidden = false
            self.navigationController?.popToRootViewController(animated: true)
            
        }
    }
    
    func modifyPost(post: Post){
        
        do {
            try realm.write {
                
                //変更がなくても、それぞれ変更値としてデータを保存する
                post.realTheme = self.realThemeTextField.text!
                post.realPresent = self.realPresentTextField.text!
                post.realDate = self.realDateTextField.text!
                post.realCost = Int(self.realCostTextField.text!)!
                
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
    
    func validateTextField() {
        
        //空白文字が含むとエラー
        let stringRule = ValidationRulePattern(pattern: "^[\\S]+$", error: ExampleValidationError("空白等は含めないで下さい"))
        //数字以外はエラー
        let moneyRule = ValidationRulePattern(pattern: "^[\\d]+$", error:
            ExampleValidationError("金額を入力して下さい"))
        //20../../..の型でないとエラー
        let dateRule = ValidationRulePattern(pattern: "20../../..", error: ExampleValidationError("日付を入力して下さい"))
        
        var dateRules = ValidationRuleSet<String>()
        dateRules.add(rule: stringRule)
        dateRules.add(rule: dateRule)
        
        var moneyRules = ValidationRuleSet<String>()
        moneyRules.add(rule: stringRule)
        moneyRules.add(rule: moneyRule)
        
        let themeValidation = realThemeTextField.validate(rule: stringRule)
        reflectValidateResalut(result: themeValidation, label: realThemeVdLabel)
        
        let presentValidation = realPresentTextField.validate(rule: stringRule)
        reflectValidateResalut(result: presentValidation, label: realPresentVdLabel)
        
        let dateValidation = realDateTextField.validate(rules: dateRules)
        reflectValidateResalut(result: dateValidation, label: realDateVdLabel)
        
        let budgetValidation = realCostTextField.validate(rules: moneyRules)
        reflectValidateResalut(result: budgetValidation, label: realCostVdLabel)
        
    }
    
    func reflectValidateResalut(result: ValidationResult, label: UILabel) {
        switch result {
        case .valid:
            label.text = "ok"
        case .invalid(let failures):
            label.text = (failures.first as? ExampleValidationError)?.message
        }
    }
}
