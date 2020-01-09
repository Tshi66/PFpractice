//
//  PostTableViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/20.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import FontAwesome_swift
import RealmSwift
import MBCircularProgressBar

class PostTableViewController: UITableViewController {
    //MARC: Properties
    @IBOutlet weak var savingLabel: UILabel!
    @IBOutlet weak var presentCostLabel: UILabel!
    @IBOutlet weak var sumDepositLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var mainProgressView: MBCircularProgressBarView!
    
    var posts: Results<Post>!
    var post = Post()
    var bank = Bank()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        indicateMainProgress()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return posts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PostTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PostTableViewCell else {
                
            fatalError("dequeueできませんでした。")
        }
        
        let post = posts[indexPath.row]
        
        cell.nameLabel.text = post.name
        
        
        let font = UIFont.fontAwesome(ofSize: 14.0, style: .regular)
        let color = UIColor.init(red: 219/255, green: 68/255, blue: 55/255, alpha: 1.0)

        //アイコンとラベルテキストを表示。アイコンのみを着色する。
        let themeIcon = String.fontAwesomeIcon(name: .heart)
        let themeLabelText = themeIcon + "  " + post.theme
        let attrThemeLabel = NSMutableAttributedString(string: themeLabelText)
        attrThemeLabel.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, 1))
        cell.themeLabel.font = font
        cell.themeLabel.attributedText = attrThemeLabel
        
        let presentIcon = String.fontAwesomeIcon(name: .gem)
        let presentLabelText = presentIcon + "  " + post.present
        let attrPresentLabel = NSMutableAttributedString(string: presentLabelText)
        attrPresentLabel.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, 1))
        cell.presentLabel.font = font
        cell.presentLabel.attributedText = attrPresentLabel
        
        let dateIcon = String.fontAwesomeIcon(name: .calendarAlt)
        let dateLabelText = dateIcon + "   " + post.date
        let attrDateLabel = NSMutableAttributedString(string: dateLabelText)
        attrDateLabel.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, 1))
        cell.dateLabel.font = font
        cell.dateLabel.attributedText = attrDateLabel
 
        let budgetIcon = String.fontAwesomeIcon(name: .moneyBillAlt)
        let budgetLabelText = budgetIcon + "  " + "\(post.deposit) / \(post.budget)円"
        let attrBudgetLabel = NSMutableAttributedString(string: budgetLabelText)
        attrBudgetLabel.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, 1))
        cell.budgetLabel.font = font
        cell.budgetLabel.attributedText = attrBudgetLabel
        
        if remainingTime(date: post.date) < 0 {
            
            cell.remainingTimeLabel.text = "\(-(remainingTime(date: post.date)))日前"
        } else {
            
            cell.remainingTimeLabel.text = "あと\(remainingTime(date: post.date))日"
        }
        
        cell.notificationLabel.layer.cornerRadius = 3
        cell.notificationLabel.clipsToBounds = true
        
        if post.info?.enable != nil {
            cell.notificationLabel.isHidden = false
            
            cell.notificationLabel.text =
                "[\(String(post.info!.repetition))] \(String(post.info!.date))、\(String(post.info!.time))"
            
        } else {
            cell.notificationLabel.isHidden = true
        }
        
        cell.photoImageView.image = post.photo
        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.size.width * 0.5
        
        //subProgressViewの数値設定
        UIView.animate(withDuration: 1.0) {
            cell.subProgressView.value = CGFloat(post.deposit)
        }
        cell.subProgressView.maxValue = CGFloat(post.budget)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        post = posts[indexPath.row]
        
        performSegue(withIdentifier: "Post", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Post" {
            let nextVC: PostOneViewController = (segue.destination as? PostOneViewController)!
            
            nextVC.post = post
        }
    }
    
    func indicateMainProgress(){
        let sumBudget: Int = posts.sum(ofProperty: "budget")
        let sumDeposit: Int = posts.sum(ofProperty: "deposit")
        
        bankLoad()
        savingLabel.text = "\(bank.saving)円"
        sumDepositLabel.text = "\(sumDeposit)円"
        presentCostLabel.text = "\(sumBudget)円"
        
        let amount = sumBudget - bank.saving
        
        if amount < 0 {
            progressLabel.text = "余り \(-(amount))円"
            progressLabel.textColor = .blue
        } else {
            progressLabel.text = "あと \(amount)円"
            progressLabel.textColor = .red
        }
        
        UIView.animate(withDuration: 1.0) {
            self.mainProgressView.value = CGFloat(self.bank.saving)
        }
        
        mainProgressView.maxValue = CGFloat(sumBudget)
        
    }
    
    func loadPosts(){
        
        posts = realm.objects(Post.self).filter("finished = false")
        
        self.tableView.reloadData()
    }
    
    func bankLoad() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
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
}
