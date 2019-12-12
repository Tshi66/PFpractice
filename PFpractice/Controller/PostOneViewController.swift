//
//  PostOneViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/22.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift

class PostOneViewController: UIViewController {
    
    //MARC: Properties
    var post = Post()
    var bank = Bank()
    let realm = try! Realm()
    
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var presentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var themeIcon: UILabel!
    @IBOutlet weak var presentIcon: UILabel!
    @IBOutlet weak var dateIcon: UILabel!
    @IBOutlet weak var budgetIcon: UILabel!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        postDataLoad()
        bankLoad()
        postRealmLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPost" {
            let nextVC: EditPostViewController = (segue.destination as? EditPostViewController)!
            
            nextVC.post = post
        }
    }
    
    @IBAction func depositButton(_ sender: UIButton) {
        
        var textField = UITextField()
        
        if bank.saving > 0 && realm.objects(Bank.self).filter("id = 0").first != nil {
            
            if post.budget != post.deposit {
                
                let alert = UIAlertController(title: "入金する", message: "貯金箱からこのポストに入金できます。\n(現在の貯金額:\(self.bank.saving))円", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    
                    if Int(textField.text!)! > self.bank.saving {
                        textField.text = String(self.bank.saving)
                    }
                    
                    if self.post.budget < Int(textField.text!)! + self.post.deposit {
                        let modifiedDeposit =  self.post.budget - self.post.deposit
                        textField.text = String(modifiedDeposit)
                    }
                    
                    do {
                        try self.realm.write {
                            self.post.deposit += Int(textField.text!)!
                            self.bank.saving -= Int(textField.text!)!
                        }
                    } catch {
                        print("Error saving bank \(error)")
                    }
                    
                    self.viewWillAppear(true)
                }
                
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
                }
                
                alert.addTextField { (depositTextField) in
                    
                    depositTextField.placeholder = "あと\(self.post.budget - self.post.deposit)円"
                    depositTextField.enablesReturnKeyAutomatically = true
                    depositTextField.keyboardType = .numberPad
                    
                    textField = depositTextField
                }
                
                alert.addAction(action)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: "入金できません", message: "入金総額が予算額に到達したため、\nこれ以上入金できません。", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "入金できません", message: "貯金額があれば、貯金箱からこのポストに入金できます。\n!!現在の貯金額が0円のため、入金できません。", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    @IBAction func finishedButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "プレゼント完了", message: "完了を押すと、「プレゼント完了」に移動されます。", preferredStyle: .alert)
        let action = UIAlertAction(title: "完了", style: .default) { (action) in
            
            self.updatePost(post: self.post)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "ポストの削除", message: "削除すると復元できません。", preferredStyle: .alert)
        let action = UIAlertAction(title: "削除", style: .destructive) { (action) in
            
            self.deletePost(post: self.post)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func editDepositButton(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "入金額を編集しますか？\n(現在の貯金額:\(self.bank.saving))円", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            if Int(textField.text!)! > self.post.budget {
                textField.text = String(self.post.budget)
            }
            
            if Int(textField.text!)! < self.post.deposit {
                do {
                    try self.realm.write {
                        self.bank.saving += self.post.deposit - Int(textField.text!)!
                        self.post.deposit = Int(textField.text!)!
                    }
                } catch {
                    print("Error saving bank \(error)")
                    
                }
            } else {
                if Int(textField.text!)! - self.post.deposit > self.bank.saving {
                    do {
                        try self.realm.write {
                            self.post.deposit += self.bank.saving
                            self.bank.saving = 0
                        }
                    } catch {
                        print("Error saving bank \(error)")
                    }
                    
                } else {
                    do {
                        try self.realm.write {
                            self.bank.saving -= Int(textField.text!)! - self.post.deposit
                            self.post.deposit = Int(textField.text!)!
                        }
                    } catch {
                        print("Error saving bank \(error)")
                    }
                }
                
            }
            
            self.viewWillAppear(true)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (editSavingTextField) in
            editSavingTextField.placeholder = "\(self.post.deposit)"
            textField = editSavingTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    private func postDataLoad(){
        let font = UIFont.fontAwesome(ofSize: 20.0, style: .regular)
        let color = UIColor.init(red: 219/255, green: 68/255, blue: 55/255, alpha: 1.0)
        
        //FAアイコン。
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
        
        backImage.image = post.backImage
        heroImage.image = post.photo
        nameLabel.text = post.name
        themeLabel.text = post.theme
        presentLabel.text = post.present
        dateLabel.text = post.date
        budgetLabel.text = "\(post.deposit) / \(post.budget)円"
        
        if remainingTime(date: post.date) < 0 {
            
            remainingTimeLabel.text = "\(-(remainingTime(date: post.date)))日前"
        } else {
            
            remainingTimeLabel.text = "あと\(remainingTime(date: post.date))日"
        }
        
        balanceLabel.text = "あと\(post.budget - post.deposit)円"
        
        heroImage.layer.cornerRadius = heroImage.frame.size.width * 0.5
    }
    
    func remainingTime(date: String) -> Int {
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: Locale(identifier: "ja_JP"))
        let currentDate = dateFormatter.string(from: now)
        let curDate = dateFormatter.date(from: currentDate)
        let repDate = dateFormatter.date(from: date)

        return (Calendar.current.dateComponents([.day], from: curDate!, to: repDate!)).day!
        
    }
    
    func bankLoad() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
        }
    }
    
    func postRealmLoad(){
        post = realm.objects(Post.self).filter("id = \(post.id)").first!
        
    }
    
    func updatePost(post: Post){
        do {
            try realm.write {
                
                post.finished = true
            }
        } catch {
            print("Error saving post \(error)")
        }
    }
    
    func deletePost(post: Post) {
        do {
            try realm.write {
                bank.saving += post.deposit
                realm.delete(post)
            }
        } catch {
            print("Error deleting post \(error)")
        }
    }
}
