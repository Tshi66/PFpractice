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
    @IBOutlet weak var presentCostLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    let realm = try! Realm()
    var posts: Results<Post>!
    var bank = Bank()
    
    override func viewDidLoad() {
        print("viewDidLoad!!!!")
        super.viewDidLoad()
        loadPosts()
        bankLoad()
        
        let sum: Int = posts.sum(ofProperty: "budget")
        
        savingLabel.text = "\(bank.saving)円"
        presentCostLabel.text = "\(sum)"
        stackLabel.text = "\(bank.stack)円 / 月"
        
        let amount = sum - bank.saving
        
        if amount < 0 {
            progressLabel.text = "余り \(-(amount))円"
            progressLabel.textColor = .blue
        } else {
            progressLabel.text = "あと \(amount)円"
        }
        
        
        UIView.animate(withDuration: 1.0) {
            self.progressView.value = CGFloat(self.bank.saving)
        }
        
        progressView.maxValue = 20000
        
    }
    
    @IBAction func editSavingButton(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "貯金額を編集しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
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
            editSavingTextField.placeholder = "\(self.bank.saving)"
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
            editStackTextField.placeholder = "\(self.bank.stack)"
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
                        
            if self.realm.objects(Bank.self).filter("id = 0").first != nil{
                
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
    
    func loadPosts(){
        
        posts = realm.objects(Post.self).filter("finished = false")
        
    }
}
