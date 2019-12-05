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

class BankViewController: UIViewController {
    
    @IBOutlet weak var savingLabel: UILabel!
    @IBOutlet weak var stackLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    let realm = try! Realm()
    var bank = Bank()
    
    override func viewDidLoad() {
        print("viewDidLoad!!!!")
        super.viewDidLoad()
        bankLoad()
        savingLabel.text = "\(bank.saving)円"
        stackLabel.text = "\(bank.stack)円 / 月"
        
        progressLabel.text = "あと \(20000 - bank.saving)円"
        
        UIView.animate(withDuration: 1.0) {
            self.progressView.value = CGFloat(self.bank.saving)
        }
        
        progressView.maxValue = 20000
        
    }
    
    @IBAction func editSavingButton(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "貯金額を編集しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.navigationController?.popViewController(animated: true)
            
            do {
                try self.realm.write {
                    self.bank.saving = Int(textField.text!)!
                }
            } catch {
                print("Error saving bank \(error)")
            }
            
            self.viewDidLoad()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (editSavingTextField) in
            self.bankLoad()
            editSavingTextField.text = "\(self.bank.saving)"
            textField = editSavingTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func editStackButton(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "積立額を編集しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.navigationController?.popViewController(animated: true)
            
            do {
                try self.realm.write {
                    self.bank.stack = Int(textField.text!)!
                }
            } catch {
                print("Error saving bank \(error)")
            }
            
            self.viewDidLoad()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (editStackTextField) in
            self.bankLoad()
            editStackTextField.text = "\(self.bank.stack)"
            textField = editStackTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func inputSavingButton(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "貯金しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.navigationController?.popViewController(animated: true)
            
            if self.realm.objects(Bank.self).filter("id = 0").first != nil{
//                print(self.realm.objects(Bank.self).filter("id = 0").first)
                
                do {
                    try self.realm.write {
                        self.bank.saving += Int(textField.text!)!
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
                        self.bank.saving += Int(textField.text!)!
                        print(self.realm.objects(Bank.self).filter("saving > 0"))
                    }
                } catch {
                    print("Error saving bank \(error)")
                }
            }

            self.viewDidLoad()
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (inputSavingTextField) in
            inputSavingTextField.placeholder = "貯金額を入力してください。"
            
            textField = inputSavingTextField
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
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
}
