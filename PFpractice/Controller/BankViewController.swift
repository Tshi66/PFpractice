//
//  BankViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/05.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift
import MBCircularProgressBar
import Validator
import Loaf

class BankViewController: UIViewController {
    
    @IBOutlet weak var savingLabel: UILabel!
    @IBOutlet weak var sumDepositLabel: UILabel!
    @IBOutlet weak var presentCostLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    @IBOutlet weak var editSavingButton: UIButton!
    
    let realm = try! Realm()
    var posts: Results<Post>!
    var bank = Bank()
    var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        loadPostsFromRealm()
        loadBankFromRealm()
        indicateProgress()
        
    }
    
    @IBAction func PushEditSavingButton(_ sender: UIButton) {
           
        showEditSavingAlert()
        
    }
    
    @IBAction func inputSavingButton(_ sender: UIButton) {
        
        showAddSavingAlert()
        
    }
    
    private func showAddSavingAlert() {
        
        let alert = UIAlertController(title: "貯金しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        
            self.validateTextField(caseNumber: 1)
            self.viewDidLoad()
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (inputSavingTextField) in
            inputSavingTextField.keyboardType = .numberPad
            inputSavingTextField.placeholder = "貯金額を入力してください。"
            
            self.textField = inputSavingTextField
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showEditSavingAlert() {
        
        let alert = UIAlertController(title: "貯金額を編集しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.validateTextField(caseNumber: 0)
            self.viewDidLoad()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (editSavingTextField) in
            editSavingTextField.placeholder = "\(self.bank.saving)"
            editSavingTextField.keyboardType = .numberPad
            self.textField = editSavingTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func indicateProgress(){
        let sumBudget: Int = posts.sum(ofProperty: "budget")
        let sumDeposit: Int = posts.sum(ofProperty: "deposit")
        
        savingLabel.text = "\(bank.saving)円"
        sumDepositLabel.text = "\(sumDeposit)円"
        presentCostLabel.text = "\(sumBudget)円"
        
        showProgressView(sumBudget: sumBudget)
    }
    
    private func showProgressView(sumBudget: Int) {
                
        (text: progressLabel.text, color: progressLabel.textColor) = {
            
            let amount = sumBudget - bank.saving
            
            if amount < 0 {
                return (text: "余り \(-(amount))円", color: .blue)
                
            } else {
                return (text: "あと \(amount)円", color: .red)
            }
        }()
        
        UIView.animate(withDuration: 1.0) {
            self.progressView.value = CGFloat(self.bank.saving)
        }
        
        progressView.maxValue = CGFloat(sumBudget)
    }
    
    private func createBankOnRealm(){
        do {
            try self.realm.write {
                self.realm.add(Bank())
            }
        } catch {
            print("Error saving bank \(error)")
        }
        
    }
    
    private func loadBankFromRealm() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
        }
    }
    
    private func loadPostsFromRealm(){
        
        posts = realm.objects(Post.self).filter("finished = false")
        
    }
    
    private func validateTextField(caseNumber: Int) {
        
        let rules = setValidateRule()
        let depositValidation = textField.validate(rules: rules)
        reflectValidateResalut(result: depositValidation, pattern: caseNumber)
        
    }
    
    private func setValidateRule() -> ValidationRuleSet<String> {
        
        //空白文字が含むとエラー
        let stringRule = ValidationRulePattern(pattern: "^[\\S]+$", error: ExampleValidationError("空白等は含めないで下さい"))
        //数字以外はエラー
        let moneyRule = ValidationRulePattern(pattern: "^[\\d]+$", error: ExampleValidationError("金額を入力して下さい"))
        
        var depositRules = ValidationRuleSet<String>()
        depositRules.add(rule: stringRule)
        depositRules.add(rule: moneyRule)
        
        return depositRules
    }
    
    private func reflectValidateResalut(result: ValidationResult, pattern: Int) {
        
        switch result {
        case .valid:
            
            processSaving(pattern: pattern)
                        
        case .invalid(let failures):
            
            //Loafでエラーメッセージ表示
            let errorMessage = String(describing: (failures.first as! ExampleValidationError).message)
            let loafMessage = "貯金額が反映されませんでした。\nエラー: \(errorMessage)"
            
            showLoafMessage(message: loafMessage, state: .error)
        }
    }
    
    private func processSaving(pattern: Int){
        
        guard let input = textField.text else {
            return
        }
        
        let inputValue: Int = Int(input)!
        var add: Int = bank.saving
        
        //Bankデータが存在していなければ、Bankデータを新規作成
        if realm.objects(Bank.self).filter("id = 0").first == nil{
            
            createBankOnRealm()
        }
        
        if pattern == 0 {
            
            add = 0
            saveToRealm(add: add, inputValue: inputValue)
            
            //貯金額変更を知らせる
            showLoafMessage(message: "貯金額を\(inputValue)円に変更しました", state: .success)
            
        //pattern == 1
        } else {
                
            saveToRealm(add: add, inputValue: inputValue)
            
            //完了を知らせる
            showLoafMessage(message: "\(inputValue)円を貯金しました", state: .success)
        }
    }
    
    private func saveToRealm(add: Int, inputValue: Int) {
        
        do {
            try realm.write {
                bank.saving = add + inputValue
            }
        } catch {
            print("Error saving bank \(error)")
        }
    }
    
    private func showLoafMessage(message: String, state: Loaf.State) {
        
        Loaf(message, state: state, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
}
