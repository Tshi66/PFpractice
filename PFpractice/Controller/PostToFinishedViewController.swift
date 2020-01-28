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
import Loaf

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
        
        //全体表示をオンにする
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
        
        guard realThemeVdLabel.text == "ok" && realDateVdLabel.text == "ok" && realPresentVdLabel.text == "ok" && realCostVdLabel.text == "ok" else {
            
            //Loafでエラーメッセージ表示
            let loafMessage = "変更が反映されませんでした。"
            showLoafMessage(message: loafMessage, state: .error)
            
            return
        }
        
        //アニメーションの停止
        animationView.stop()
        
        //変更値を保存
        modifyPost(post: post)
        
        //全体表示をオフにする
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
        
        navigationController?.popToRootViewController(animated: true)
        
        //Loafでメッセージ表示
        let image = post.photo
        let name = post.name
        let loafMassage = "\(name)のポストが「プレゼント完了」に追加されました。"
        Loaf(loafMassage, state: .custom(.init(backgroundColor: .systemGreen, icon: image)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
        
    }
    
    func modifyPost(post: Post){
        
        do {
            try realm.write {
                
                //変更がなくても、それぞれ変更値としてデータを保存する
                post.realTheme = realThemeTextField.text ?? ""
                post.realPresent = realPresentTextField.text ?? ""
                post.realDate = realDateTextField.text ?? ""
                post.realCost = Int(realCostTextField.text ?? "") ?? 0
                
            }
        } catch {
            print("Error saving post \(error)")
            return
        }
    }
    
    func bankLoad() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
            return
        }
    }
    
    private func validateTextField() {
        
        //空白文字が含むとエラー
        let stringRule = ValidationRulePattern(pattern: "^[\\S]+$", error: ExampleValidationError("空白等は含めないで下さい"))
        //数字以外はエラー
        let moneyRule = ValidationRulePattern(pattern: "^[\\d]+$", error: ExampleValidationError("金額を入力して下さい"))
        //20../../..の型でないとエラー
        let dateRule = ValidationRulePattern(pattern: "20../../..", error: ExampleValidationError("日付を入力して下さい"))
        
        applyRuleToTF(textField: realThemeTextField, rule: stringRule, VDLabel: realThemeVdLabel)
        applyRuleToTF(textField: realPresentTextField, rule: stringRule, VDLabel: realPresentVdLabel)
        applyRuleToTF(textField: realDateTextField, rule: dateRule, VDLabel: realDateVdLabel)
        applyRuleToTF(textField: realCostTextField, rule: moneyRule, VDLabel: realCostVdLabel)
        
    }
    
    private func applyRuleToTF(textField: UITextField, rule: ValidationRulePattern, VDLabel: UILabel) {
        
        let validateTF = textField.validate(rule: rule)
        reflectValidateResalut(result: validateTF, label: VDLabel)
    }
    
    func reflectValidateResalut(result: ValidationResult, label: UILabel) {
        switch result {
        case .valid:
            
            label.text = "ok"
            
        case .invalid(let failures):
            
            label.text = (failures.first as? ExampleValidationError)?.message
        }
    }
    
    func showLoafMessage(message: String, state: Loaf.State) {
        
        Loaf(message, state: state, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
}
