//
//  PostOneViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/22.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift
import Validator
import MBCircularProgressBar
import Loaf

class PostOneViewController: UIViewController {
    
    //MARC: Properties
    var post = Post()
    var bank = Bank()
    let realm = try! Realm()
    var textField = UITextField()
    let center = UNUserNotificationCenter.current()
    
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
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var subProgressView: MBCircularProgressBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        showContentsOfOnePost()
        loadBankFromRealm()
        loadPostFromRealm()
        setNotificationLabel()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "editPost":
            let nextVC: EditPostViewController = (segue.destination as? EditPostViewController)!
            
            nextVC.post = post
        case "postInfo":
            let nextVC: PostNotificationTableViewController = (segue.destination as? PostNotificationTableViewController)!
            
            nextVC.post = post
            
        case "toPostFinished":
            let nextVC: PostToFinishedViewController = (segue.destination as? PostToFinishedViewController)!
            
            nextVC.post = post
            
        default:
            print("error")
        }
    }
    
    @IBAction func addDepositButton(_ sender: UIButton) {
        
        judgeToShowWhatAlert()
        
    }
    
    @IBAction func finishedButton(_ sender: UIButton) {
        
        showFinishedAlert()
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        
        showDeletePostAlert()
    }
    
    @IBAction func editDepositButton(_ sender: UIButton) {
        
        let alertTitle = "入金額を編集しますか？\n(現在の貯金額:\(bank.saving))円"
        let alertMessage = ""
        let validateCase = "editDeposit"
        let depositTFplaceholder = "\(post.deposit)"
        
        showDepositAlert(alertTitle: alertTitle, alertMessage: alertMessage, validateCase: validateCase, depositTFplaceholder: depositTFplaceholder)
        
    }
    
    private func judgeHavingSavingOfBank() -> Bool {
        
        if bank.saving > 0 && realm.objects(Bank.self).filter("id = 0").first != nil {
            return true
        } else {
            return false
        }
    }
    
    private func judgeDepositIsFiFull() -> Bool {
        
        if post.budget == post.deposit {
            return true
        } else {
            return false
        }
    }
    
    private func judgeToShowWhatAlert() {
        
        let hasSavingOfBank: Bool = judgeHavingSavingOfBank()
        
        let depositIsFiFull: Bool = judgeDepositIsFiFull()
        
        if hasSavingOfBank == false {
            
            let errorMessage = "貯金額があれば、貯金箱からこのポストに入金できます。\n!!現在の貯金額が0円のため、入金できません。"
            showErrorAlert(message: errorMessage)
        }
        
        if hasSavingOfBank == true && depositIsFiFull == false {
            
            let alertTitle = "入金する"
            let alertMessage = "貯金箱からこのポストに入金できます。\n(現在の貯金額:\(bank.saving))円"
            let validateCase = "deposit"
            let depositTFplaceholder = "あと\(post.budget - post.deposit)円"
            
            showDepositAlert(alertTitle: alertTitle, alertMessage: alertMessage, validateCase: validateCase, depositTFplaceholder: depositTFplaceholder)
            
        }
        
        if hasSavingOfBank == true && depositIsFiFull == true{
            
            let errorMessage = "入金総額が予算額に到達したため、\nこれ以上入金できません。"
            showErrorAlert(message: errorMessage)
        }
    }
    
    private func showDeletePostAlert() {
        
        let alert = UIAlertController(title: "ポストの削除", message: "削除すると復元できません。", preferredStyle: .alert)
        let action = UIAlertAction(title: "削除", style: .destructive) { (action) in
            
            //1つ前の画面に戻り、Loafでメッセージ表示
            self.navigationController?.popViewController(animated: false)
            
            //loafメッセージを表示
            let name = self.post.name
            let image = self.post.photo
            let loafMessage = "\(name)のポストを削除しました。"
            self.setLoaf(message: loafMessage, state: .custom(.init(backgroundColor: .systemGreen, icon: image)))
            
            //通知が設定されていれば、削除。
            if self.post.info != nil {
                
                self.deleteNotification()
            }
            //postを削除
            self.deletePostFromRealm(post: self.post)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showFinishedAlert() {
        
        let alert = UIAlertController(title: "プレゼント完了", message: "完了を押すと、「プレゼント完了」に移動されます。", preferredStyle: .alert)
        let action = UIAlertAction(title: "完了", style: .default) { (action) in
            
            //finishedをtrueとしてrealmに保存する
            self.postFinishedSaveToRealm(post: self.post)
            
            //通知が設定されていれば、削除。
            if self.post.info != nil {
                
                self.deleteNotification()
            }
            
            self.performSegue(withIdentifier: "toPostFinished", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteNotification() {
        
        //通知リクエストの削除
        let identifier = "postNotification" + String(post.id)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        //realmから通知データを削除
        do {
            try self.realm.write {
                self.realm.delete(post.info!)
            }
        } catch {
            print("Error delete post.info \(error)")
        }
        
    }
    
    private func showDepositAlert(alertTitle: String, alertMessage: String, validateCase: String, depositTFplaceholder: String) {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.validateTextField(validateCase: validateCase)
            self.viewWillAppear(true)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addTextField { (depositTextField) in
            
            depositTextField.placeholder = depositTFplaceholder
            depositTextField.enablesReturnKeyAutomatically = true
            depositTextField.keyboardType = .numberPad
            
            self.textField = depositTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showErrorAlert(message: String) {
        
        let alert = UIAlertController(title: "入金できません", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func setNotificationLabel() {
        
        let imageName: String = {
            
            if post.info?.enable != nil {
                return "通知"
            } else {
                return "通知オフ"
            }
        }()
        
        notificationButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func showContentsOfOnePost(){
        
        //FAアイコンを表示
        iconSetToLabel()
        
        //ポストデータを表示する
        showPostData()
        
        //通知設定があれば表示する
        showNotificationLabel()
        
        //subProgressViewを表示
        showSubProgressView()
        
    }
    
    private func showSubProgressView(){
        
        UIView.animate(withDuration: 1.0) {
            self.subProgressView.value = CGFloat(self.post.deposit)
        }
        self.subProgressView.maxValue = CGFloat(post.budget)
    }
    
    private func showNotificationLabel(){
        
        notificationLabel.layer.cornerRadius = 3
        notificationLabel.clipsToBounds = true
        
        if post.info?.enable != nil {
            notificationLabel.isHidden = false
            
            notificationLabel.text =
            " [\(String(post.info!.repetition))]  \(String(post.info!.date))、\(String(post.info!.time)) "
        } else {
            notificationLabel.isHidden = true
        }
    }
    
    private func showPostData(){
        
        backImage.image = post.backImage
        heroImage.image = post.photo
        nameLabel.text = post.name
        themeLabel.text = post.theme
        presentLabel.text = post.present
        dateLabel.text = post.date
        budgetLabel.text = "\(post.deposit) / \(post.budget)円"
        balanceLabel.text = "あと\(post.budget - post.deposit)円"
        
        remainingTimeLabel.text = {
            
            let remainingDays = outputRemainingDays(date: post.date)
            guard let days = remainingDays else {
                
                return nil
            }
            
            if days < 0 {
                return ("\(-(days))日前")
            } else {
                return ("あと\(days)日")
            }
        }()
    }
    
    private func iconSetToLabel(){
        
        fontAwesomeIconSet(iconLabel: themeIcon, iconName: .fontAwesomeIcon(name: .heart))
        fontAwesomeIconSet(iconLabel: presentIcon, iconName: .fontAwesomeIcon(name: .gem))
        fontAwesomeIconSet(iconLabel: dateIcon, iconName: .fontAwesomeIcon(name: .calendarAlt))
        fontAwesomeIconSet(iconLabel: budgetIcon, iconName: .fontAwesomeIcon(name: .moneyBillAlt))
        
    }
    
    private func fontAwesomeIconSet(iconLabel: UILabel, iconName: String) {
        
        let font = UIFont.fontAwesome(ofSize: 20.0, style: .regular)
        let color = AppTheme().mainColor
        let fontAwesomeIcon = iconName
        
        iconLabel.font = font
        iconLabel.text = fontAwesomeIcon
        iconLabel.textColor = color
    }
    
    private func outputRemainingDays(date: String) -> Int? {
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: Locale(identifier: "ja_JP"))
        let currentDate = dateFormatter.string(from: now)
        guard let curDate = dateFormatter.date(from: currentDate) else { return nil }
        guard let repDate = dateFormatter.date(from: date) else { return nil }
        
        return (Calendar.current.dateComponents([.day], from: curDate, to: repDate)).day
        
    }
    
    private func loadBankFromRealm() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
        }
    }
    
    private func loadPostFromRealm(){
        
        self.post = realm.objects(Post.self).filter("id = \(post.id)").first!
        
    }
    
    private func postFinishedSaveToRealm(post: Post){
        do {
            try realm.write {
                
                post.finished = true
            }
        } catch {
            print("Error saving post \(error)")
        }
    }
    
    private func deletePostFromRealm(post: Post) {
        do {
            try realm.write {
                
                realm.delete(post)
            }
        } catch {
            print("Error deleting post \(error)")
        }
    }
    
    private func validateTextField(validateCase: String) {
        
        let ValidationRules = setValidateRule()
        let depositValidation = textField.validate(rules: ValidationRules)
        
        reflectValidateResalut(result: depositValidation, pattern: validateCase)
        
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
    
    // FIXME: 現状ここまでしかリファクタリングできない。処理が複雑すぎる
    // 要レビュー要請。
    private func reflectValidateResalut(result: ValidationResult, pattern: String) {
        
        var inputtedDepositOnTF = textField.text
        let savingOnBank = bank.saving
        let budget = post.budget
        let deposit = post.deposit
        
        switch result {
        case .valid:
            
            //ポストに入金したときの処理
            if pattern == "deposit" {
                
                if Int(inputtedDepositOnTF!)! > savingOnBank {
                    
                    inputtedDepositOnTF = String(savingOnBank)
                }
                
                if budget < Int(inputtedDepositOnTF!)! + deposit {
                    
                    let modifiedDeposit =  budget - deposit
                    inputtedDepositOnTF = String(modifiedDeposit)
                }
                
                let modifiedSaving: Int = deposit + Int(inputtedDepositOnTF!)!
                let modifiedDeposit: Int = savingOnBank - Int(inputtedDepositOnTF!)!
                
                modifyRealm(modifiedDeposit: modifiedDeposit, modifiedSaving: modifiedSaving)
                
                //Loafを表示
                setLoaf(message: "\(Int(inputtedDepositOnTF!)!)円を入金しました。", state: .success)
                
                //入金額を編集するときの処理 pattern == "editDeposit"
            } else {
                
                //入力した金額が予算額を超える
                if Int(inputtedDepositOnTF!)! > budget {
                    inputtedDepositOnTF = String(budget)
                }
                
                //入力した金額よりも、入金額が大きい場合
                if Int(inputtedDepositOnTF!)! < deposit {
                    
                    let modifiedSaving: Int = savingOnBank + (deposit - Int(inputtedDepositOnTF!)!)
                    let modifiedDeposit: Int = Int(inputtedDepositOnTF!)!
                    
                    modifyRealm(modifiedDeposit: modifiedDeposit, modifiedSaving: modifiedSaving)
                    
                } else {
                    
                    if Int(inputtedDepositOnTF!)! - deposit > savingOnBank {
                        
                        let modifiedSaving: Int = savingOnBank - savingOnBank
                        let modifiedDeposit: Int = deposit + savingOnBank

                        modifyRealm(modifiedDeposit: modifiedDeposit, modifiedSaving: modifiedSaving)
                        
                    } else {
                        
                        let modifiedSaving: Int = savingOnBank - (Int(inputtedDepositOnTF!)! - deposit)
                        let modifiedDeposit: Int = Int(inputtedDepositOnTF!)!
                        
                        modifyRealm(modifiedDeposit: modifiedDeposit, modifiedSaving: modifiedSaving)
                        
                    }
                }
                
                //Loafを表示
                setLoaf(message: "入金額を\(Int(post.deposit))円に変更しました。", state: .success)
            }
            
        case .invalid(let failures):
            //Loafでエラーメッセージ表示
            let errorMessage = String(describing: (failures.first as! ExampleValidationError).message)
            let loafMassage = "入金額が反映されませんでした。\nエラー: \(errorMessage)"
            setLoaf(message: loafMassage, state: .error)
        }
    }
    
    private func modifyRealm(modifiedDeposit: Int, modifiedSaving: Int) {
        
        do {
            try self.realm.write {
                
                self.post.deposit = modifiedDeposit
                self.bank.saving = modifiedSaving
            }
        } catch {
            print("Error saving post.deposit and bank.saving \(error)")
        }
    }
    
    
    private func setLoaf(message: String, state: Loaf.State) {
        
        Loaf(message, state: state, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
}
