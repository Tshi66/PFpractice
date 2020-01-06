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

class BankViewController: UIViewController {
    
    @IBOutlet weak var savingLabel: UILabel!
    @IBOutlet weak var sumDepositLabel: UILabel!
    @IBOutlet weak var presentCostLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    let realm = try! Realm()
    var posts: Results<Post>!
    var bank = Bank()
    var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPosts()
        bankLoad()
        indicateProgress()
        
    }
    
    @IBAction func editSavingButton(_ sender: UIButton) {
                
        let alert = UIAlertController(title: "貯金額を編集しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.validateTextField(caseNumber: 0)
            self.viewDidLoad()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (editSavingTextField) in
            self.bankLoad()
            editSavingTextField.placeholder = "\(self.bank.saving)"
            self.textField = editSavingTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func inputSavingButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "貯金しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
                        
            self.validateTextField(caseNumber: 1)
            self.viewDidLoad()
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (inputSavingTextField) in
            inputSavingTextField.placeholder = "貯金額を入力してください。"
            
            self.textField = inputSavingTextField
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func indicateProgress(){
        let sumBudget: Int = posts.sum(ofProperty: "budget")
        let sumDeposit: Int = posts.sum(ofProperty: "deposit")
        
        bankLoad()
        savingLabel.text = "\(bank.saving)円"
        sumDepositLabel.text = "\(sumDeposit)円"
        presentCostLabel.text = "\(sumBudget)円"
        
        let amount = sumBudget - sumDeposit
        
        if amount < 0 {
            progressLabel.text = "余り \(-(amount))円"
            progressLabel.textColor = .blue
        } else {
            progressLabel.text = "あと \(amount)円"
            progressLabel.textColor = .red
        }
        
        UIView.animate(withDuration: 1.0) {
            self.progressView.value = CGFloat(sumDeposit)
        }
        
        progressView.maxValue = CGFloat(sumBudget)
    }
    
    func save(){
        do {
            try self.realm.write {
                self.realm.add(Bank())
            }
        } catch {
            print("Error saving bank \(error)")
        }
        
    }
    
    func bankLoad() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
        }
    }
    
    func loadPosts(){
        
        posts = realm.objects(Post.self).filter("finished = false")
        
    }
    
    func validateTextField(caseNumber: Int) {
        
        let caseNumber = caseNumber
        
        //空白文字が含むとエラー
        let stringRule = ValidationRulePattern(pattern: "^[\\S]+$", error: ExampleValidationError("空白等は含めないで下さい"))
        //数字以外はエラー
        let moneyRule = ValidationRulePattern(pattern: "^[\\d]+$", error: ExampleValidationError("金額を入力して下さい"))
        
        var depositRules = ValidationRuleSet<String>()
        depositRules.add(rule: stringRule)
        depositRules.add(rule: moneyRule)

        if caseNumber == 0 {
            
            let depositValidation = textField.validate(rules: depositRules)
            reflectValidateResalut(result: depositValidation, pattern: caseNumber)
            
        } else {
            
            let depositValidation = textField.validate(rules: depositRules)
            reflectValidateResalut(result: depositValidation, pattern: caseNumber)
            
        }
        
    }
    
    func reflectValidateResalut(result: ValidationResult, pattern: Int) {
        
        switch result {
        case .valid:
            let pattern = pattern
            
            if pattern == 0 {
                
                do {
                    try self.realm.write {
                        self.bank.saving = Int(textField.text!)!
                    }
                } catch {
                    print("Error saving bank \(error)")
                }
                
            } else {
                
                if self.realm.objects(Bank.self).filter("id = 0").first != nil{
                    
                    do {
                        try self.realm.write {
                            self.bank.saving += Int(self.textField.text!)!
                            print(self.bank.saving)
                        }
                    } catch {
                        print("Error saving bank \(error)")
                    }
                    
                } else {
                    
                    self.save()
                    
                    do {
                        self.bankLoad()
                        try self.realm.write {
                            self.bank.saving += Int(self.textField.text!)!
                            print(self.realm.objects(Bank.self).filter("saving > 0"))
                        }
                    } catch {
                        print("Error saving bank \(error)")
                    }
                }
            }
                        
        case .invalid(let failures):
            let alert = UIAlertController(title: "エラー",
                                          message: "\(String(describing: (failures.first as? ExampleValidationError)?.message))", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
}
