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

class PostNotificationTableViewController: UITableViewController,UIPickerViewDelegate,UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    let datePicker = UIDatePicker()
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
        showDeleteButton()
        //通知デバック用
        debugNotification()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            
            showDatePickAlert()
            
        case 1:
            
            showTimePickAlert()
            
        case 2:
            
            showRepeatAlert()
            
        default:
            
            fatalError("原因不明のエラーが発生しました。")
        }
    }
    
    @IBAction func savePostNotification(_ sender: UIBarButtonItem) {
        
        saveValueToPost()
        
        saveInfoToRealm()
        
        setNotification()
        
        //1つ前の画面に戻り、Loafでメッセージ表示
        self.navigationController?.popViewController(animated: false)
        
        let image = UIImage(named: "通知")
        Loaf("通知を設定しました。", state: .custom(.init(backgroundColor: .gray, icon: image)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        
        showDeleteAlerm()
        
    }
    
}

private extension PostNotificationTableViewController {
    
    func showDeleteButton(){
        
        deleteButton.isHidden = {
            
            return post.info != nil ? false : true
        }()
    }
    
    func showDatePickAlert(){
        
        let alert = UIAlertController(title: "日付を選択してください。", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.validateTextField(pickerType: .date)
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
    }
    
    func showTimePickAlert(){
        
        let alert = UIAlertController(title: "時刻を選択してください。", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.validateTextField(pickerType: .time)
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
    }
    
    func showRepeatAlert(){
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        createAlertAction(alert: alert, actionTitle: "繰り返さない", labelText: "繰り返さない", tableView: tableView)
        createAlertAction(alert: alert, actionTitle: "毎日", labelText: "毎日", tableView: tableView)
        createAlertAction(alert: alert, actionTitle: "毎週", labelText: "毎週", tableView: tableView)
        createAlertAction(alert: alert, actionTitle: "毎月", labelText: "毎月", tableView: tableView)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createAlertAction(alert: UIAlertController, actionTitle: String, labelText: String, tableView: UITableView){
        
        let action = UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            self.repetitionLabel.text = labelText
            self.info.repetition = self.repetitionLabel.text!
            tableView.reloadData()
        })
        
        alert.addAction(action)
    }
    
    func showDeleteAlerm(){
        
        let alert = UIAlertController(title: "通知を削除します。", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.removeInfoInRealm()
            
            self.removeNotificationRequests()
            
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
    
    func removeInfoInRealm() {
        do {
            try self.realm.write {
                self.realm.delete(self.post.info!)
            }
        } catch {
            print("Error delete post.info \(error)")
        }
    }
    
    func removeNotificationRequests(){
        
        let identifier = "postNotification" + String(self.post.id)
        self.center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func setLabel() {
        if post.info != nil {
            
            //保存されている通知設定を表示する。
            dateLabel.text = post.info?.date
            timeLabel.text = post.info?.time
            repetitionLabel.text = post.info?.repetition
            
        } else {
            
            //現在の日時を表示する。
            let date = setCurrent(dateFormat: "yyyy/MM/dd")
            let time = setCurrent(dateFormat: "HH:mm")
            
            dateLabel.text = date
            timeLabel.text = time
            repetitionLabel.text = "繰り返さない"
            
        }
    }
    
    func setCurrent(dateFormat: String) -> String {
        
        let current = Date()
        let calendar = Calendar.current
        let component = DateComponents(day: 1)
        let date = calendar.date(byAdding: component, to: current)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = .current
        
        guard date != nil else {
            fatalError("原因不明のエラーが発生しました。")
        }
        
        let format = formatter.string(from: date!)
        return format
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
        
        format(dateFormat: "yyyy/MM/dd")
        
    }
    
    @objc func setTime(){
        
        format(dateFormat: "HH:mm")
        
    }
    
    @objc func format(dateFormat: String){
        textField.endEditing(true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = .current
        let format = formatter.string(from: datePicker.date)
        textField.text = format
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
            
            fatalError("原因不明のエラーが発生しました。")
        }
        
    }
    
    func setRepetition(date: Set<Calendar.Component>, repeats: Bool) {
                
        guard post.info != nil else {
            fatalError("原因不明のエラーが発生しました。")
        }
        
        removeNotificationRequests()
        
        let content = setContentOfNotification()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/ddHH:mm"
        formatter.locale = .current
        
        let dateFromFormatter = formatter.date(from: post.info!.date + post.info!.time)
        let component = Calendar.current.dateComponents(date, from: dateFromFormatter!)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: component, repeats: repeats)
        let identifier = "postNotification" + String(post.id)
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
        
    }
    
    func setContentOfNotification() -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = "\(post.name)ポストの状況"
        
        let remTime = {
            
            remainingTime(date: post.date) < 0 ? "\(-(remainingTime(date: post.date)))日" : "\(remainingTime(date: post.date))日"
        }()
        
        let difference = "\(post.budget - post.deposit)円"
        
        content.body = "プレゼントを渡す日まであと\(remTime)。予算より\(difference)不足しています。"
        
        content.sound = UNNotificationSound.default
        
        return content
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
    
    func validateTextField(pickerType: pickerType) {
        
        let rules = setRule(pickerType: pickerType)
        let validationResult = textField.validate(rules: rules)
        
        switch pickerType {
        case .date:
            reflectValidateResalut(result: validationResult, pickerType: pickerType)
            
        case .time:
            reflectValidateResalut(result: validationResult, pickerType: pickerType)
        }
        
    }
    
    func setRule(pickerType: pickerType) -> ValidationRuleSet<String>{
        
        //空白文字が含むとエラー
        let stringRule = ValidationRulePattern(pattern: "^[\\S]+$", error: ExampleValidationError("空白等は含めないで下さい"))
        //..:..の型でないとエラー
        let timeRule = ValidationRulePattern(pattern: "..:..", error:
            ExampleValidationError("時刻を入力して下さい"))
        //20../../..の型でないとエラー
        let dateRule = ValidationRulePattern(pattern: "20../../..", error: ExampleValidationError("日付を入力して下さい"))
        
        var rules = ValidationRuleSet<String>()
        rules.add(rule: stringRule)
        
        switch pickerType {
        case .date:
            rules.add(rule: dateRule)
            
        case .time:
            rules.add(rule: timeRule)
        }
        
        return rules
    }
    
    func reflectValidateResalut(result: ValidationResult, pickerType: pickerType) {
        switch result {
        case .valid:
            
            actionOnValid(pickerType: pickerType)
            
        case .invalid(let failures):

            //Loafでエラーメッセージ表示
            setLoaf(message: "設定できませんでした。\nエラー: \((String(describing: (failures.first as! ExampleValidationError).message)))", state: .error)
        }
    }
    
    func actionOnValid(pickerType: pickerType){
        
        switch pickerType {
        case .date:
            dateLabel.text = textField.text
            info.date = dateLabel.text!
            
        case .time:
            timeLabel.text = textField.text
            info.time = timeLabel.text!
        }
        
        tableView.reloadData()
    }
    
    func setLoaf(message: String, state: Loaf.State) {
        
        Loaf(message, state: state, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
    
    func saveValueToPost(){
        
        info.date = dateLabel.text!
        info.time = timeLabel.text!
        info.repetition = repetitionLabel.text!
        info.enable = true
        
    }
    
    func saveInfoToRealm(){
        
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
    }
    
    func debugNotification(){
        
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
}
