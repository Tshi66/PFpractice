//
//  PostNotificationTableViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/20.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import Validator
import Loaf

//:FIXME
//ここのクラスはリファクタリングが済んでいませんので、後回しでお願いします

class PostNotificationTableViewController: UITableViewController,UIPickerViewDelegate,UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    var textField = UITextField()
    let center = UNUserNotificationCenter.current()
    
    let realm = try! Realm()
    var post = Post()
    var info = Info()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postRealmLoad()
        allowNotification()
        setLabel()

        if post.info != nil {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
        
        //通知デバック用
        print("<Pending request identifiers>")
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("identifier:\(request.identifier)")
                print("  title:\(request.content.title)")
                
            }
        }
        
        print("<Delivered request identifiers>")
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications: [UNNotification]) in
            for notification in notifications {
                print("identifier:\(notification.request.identifier)")
                print("  title:\(notification.request.content.title)")
                
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            
            let alert = UIAlertController(title: "日付を選択してください。", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                self.validateTextField(caseNumber: 0)
            }
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
            }
            
            alert.addTextField { (datePickTextField) in
                self.textField = datePickTextField
                datePickTextField.placeholder = self.post.info?.date ?? ""
                self.setDatePicker()
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
        case 1:
            
            let alert = UIAlertController(title: "時刻を選択してください。", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                self.validateTextField(caseNumber: 1)
            }
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
            }
            
            alert.addTextField { (timePickTextField) in
                self.textField = timePickTextField
                timePickTextField.placeholder = self.post.info?.time ?? ""
                self.setTimePicker()
                
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
        case 2:
            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
            
            let action_1 = UIAlertAction(title: "繰り返さない", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                
                self.repetitionLabel.text = "繰り返さない"
                self.info.repetition = self.repetitionLabel.text!
                tableView.reloadData()
            })
            
            let action_2 = UIAlertAction(title: "毎日", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                self.repetitionLabel.text = "毎日"
                self.info.repetition = self.repetitionLabel.text!
                tableView.reloadData()
            })
            
            let action_3 = UIAlertAction(title: "毎週", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                self.repetitionLabel.text = "毎週"
                self.info.repetition = self.repetitionLabel.text!
                tableView.reloadData()
            })
            
            let action_4 = UIAlertAction(title: "毎月", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                self.repetitionLabel.text = "毎月"
                self.info.repetition = self.repetitionLabel.text!
                tableView.reloadData()
            })
            
            alert.addAction(action_1)
            alert.addAction(action_2)
            alert.addAction(action_3)
            alert.addAction(action_4)
            
            present(alert, animated: true, completion: nil)
        default:
            print("error")
        }
    }
    
    func setLabel() {
        if post.info != nil {
            
            dateLabel.text = post.info?.date
            timeLabel.text = post.info?.time
            repetitionLabel.text = post.info?.repetition
            
        } else {
            
            let current = Date()
            let calendar = Calendar.current
            let component = DateComponents(day: 1)
            let date = calendar.date(byAdding: component, to: current)
            let formatter1 = DateFormatter()
            let formatter2 = DateFormatter()
            formatter1.dateFormat = "yyyy/MM/dd"
            formatter2.dateFormat = "HH:mm"
            formatter1.locale = .current
            formatter2.locale = .current
            
            let format1 = formatter1.string(from: date!)
            let format2 = formatter2.string(from: date!)
            
            info.date = format1
            info.time = format2
            info.repetition = "繰り返さない"
            info.enable = true
            
            dateLabel.text = info.date
            timeLabel.text = info.time
            repetitionLabel.text = info.repetition
            
        }
    }
    
    func setDatePicker() {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(setDate))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
        
    }
    
    func setTimePicker() {
        datePicker.datePickerMode = UIDatePicker.Mode.time
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.init(identifier: "Japanese")
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(setTime))
        
        toolbar.setItems([spacelItem, doneItem], animated: true)
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
    
    @objc func setDate() {
        textField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = .current
        let format = formatter.string(from: datePicker.date)
        textField.text = format
        
    }
    
    @objc func setTime(){
        textField.endEditing(true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .current
        let format = formatter.string(from: datePicker.date)
        textField.text = format
        
    }
    
    @IBAction func savePostNotification(_ sender: UIBarButtonItem) {
        do {
            try realm.write {
                if post.info != nil {
                    post.info?.date = dateLabel.text!
                    post.info?.time = timeLabel.text!
                    post.info?.repetition = repetitionLabel.text!
                    post.info?.enable = true
                    
                } else {
                    post.info = info
                }
                
            }
        } catch {
            print("Error saving post \(error)")
        }
        
        setNotification()
        
        //1つ前の画面に戻り、Loafでメッセージ表示
        self.navigationController?.popViewController(animated: false)
        
        let image = UIImage(named: "通知")
        Loaf("通知を設定しました。", state: .custom(.init(backgroundColor: .gray, icon: image)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "通知を削除します。", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            do {
                try self.realm.write {
                    self.realm.delete(self.post.info!)
                }
            } catch {
                print("Error delete post.info \(error)")
            }
            
            let identifier = "postNotification" + String(self.post.id)
            self.center.removePendingNotificationRequests(withIdentifiers: [identifier])
            
            //1つ前の画面に戻り、Loafでメッセージ表示
            let image = UIImage(named: "通知オフ")
            Loaf("通知を削除しました。", state: .custom(.init(backgroundColor: .gray, icon: image)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: ((self.navigationController?.popViewController(animated: false))!)).show()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action: UIAlertAction!) in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func postRealmLoad(){
        post = realm.objects(Post.self).filter("id = \(post.id)").first!
        
    }
    
    func setNotification() {
        
        switch post.info?.repetition {
        case "繰り返さない":
            
            setRepetition(date: [.year, .month, .day, .hour, .minute], repeats: false)
            
        case "毎日":
            
            setRepetition(date: [.day, .hour, .minute], repeats: true)
            
        case "毎週":
    
            setRepetition(date: [.weekday, .hour, .minute], repeats: true)
            
        case "毎月":
            
            setRepetition(date: [.day, .hour, .minute], repeats: true)
            
        default:
            
            setRepetition(date: [.year, .month, .day, .hour, .minute], repeats: false)
        }
        
    }
    
    func setRepetition(date: Set<Calendar.Component>, repeats: Bool) {
                
        let identifier = "postNotification" + String(post.id)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "\(post.name)ポストの状況"
        
        var remTime: String = ""
        
        if remainingTime(date: post.date) < 0 {
            
            remTime = "\(-(remainingTime(date: post.date)))日"
        } else {
            
            remTime = "\(remainingTime(date: post.date))日"
        }
        
        let difference = "\(post.budget - post.deposit)円"
        
        content.body = "プレゼントを渡す日まであと\(remTime)。予算より\(difference)不足しています。"
        
        content.sound = UNNotificationSound.default
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/ddHH:mm"
        formatter.locale = .current
        let dateFromFormatter = formatter.date(from: post.info!.date + post.info!.time)
        
        let component = Calendar.current.dateComponents(date, from: dateFromFormatter!)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: component, repeats: repeats)
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
    }
    
    func allowNotification() {
        if #available(iOS 10.0, *) {
            // iOS 10
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if error != nil {
                    return
                }
                
                if granted {
                    print("通知許可")
                    
                    let center = UNUserNotificationCenter.current()
                    center.delegate = self
                    
                } else {
                    print("通知拒否")
                }
            })
            
        } else {
            // iOS 9以下
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
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
    
    func validateTextField(caseNumber: Int) {
        
        let caseNumber = caseNumber
        
        //空白文字が含むとエラー
        let stringRule = ValidationRulePattern(pattern: "^[\\S]+$", error: ExampleValidationError("空白等は含めないで下さい"))
        //..:..の型でないとエラー
        let timeRule = ValidationRulePattern(pattern: "..:..", error:
            ExampleValidationError("時刻を入力して下さい"))
        //20../../..の型でないとエラー
        let dateRule = ValidationRulePattern(pattern: "20../../..", error: ExampleValidationError("日付を入力して下さい"))
        
        var dateRules = ValidationRuleSet<String>()
        dateRules.add(rule: stringRule)
        dateRules.add(rule: dateRule)
        
        var timeRules = ValidationRuleSet<String>()
        timeRules.add(rule: timeRule)
        timeRules.add(rule: stringRule)
        
        
        if caseNumber == 0 {
            
            let dateValidation = textField.validate(rules: dateRules)
            reflectValidateResalut(result: dateValidation, pattern: 0)
        } else {
            
            let timeValidation = textField.validate(rules: timeRules)
            reflectValidateResalut(result: timeValidation, pattern: 1)
            
        }
        
    }
    
    func reflectValidateResalut(result: ValidationResult, pattern: Int) {
        switch result {
        case .valid:
            let pattern = pattern
            
            if pattern == 0 {
                
                self.dateLabel.text = self.textField.text
                self.info.date = self.dateLabel.text!
            } else {
                
                self.timeLabel.text = self.textField.text
                self.info.time = self.timeLabel.text!
            }
            
            tableView.reloadData()
            
        case .invalid(let failures):

            //Loafでエラーメッセージ表示
            setLoaf(message: "設定できませんでした。\nエラー: \((String(describing: (failures.first as! ExampleValidationError).message)))", state: .error)
        }
    }
    
    func setLoaf(message: String, state: Loaf.State) {
        
        Loaf(message, state: state, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
}
