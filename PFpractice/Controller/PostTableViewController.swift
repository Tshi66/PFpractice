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
        
        loadPostsFromRealm()
        loadBankFromRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        showMiniBankView()
        loadPostsFromRealm()
        loadBankFromRealm()
        
    }

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
        
        post = posts[indexPath.row]
        
        //アイコンをセットする
        iconSetToLabel(cell: cell)
        
        //ポストデータを表示
        showPostData(cell: cell)
        
        //通知の有無を表示
        showNotificationLabel(cell: cell)
        
        //subProgressViewを表示
        showSubProgressView(cell: cell)
        
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
}

private extension PostTableViewController {
    
    func showPostData(cell: PostTableViewCell) {
        
        cell.nameLabel.text = post.name
        cell.themeLabel.text = post.theme
        cell.presentLabel.text = post.present
        cell.dateLabel.text = post.date
        cell.budgetLabel.text = String("\(post.deposit) / \(post.budget)円")
        cell.photoImageView.image = post.photo
        
        cell.remainingTimeLabel.text = {
            
            let remainingDays = outputRemainingDays(date: post.date)
            
            if remainingDays < 0 {
                return ("\(-(remainingDays))日前")
            } else {
                return ("あと\(remainingDays)日")
            }
        }()
    }
    
    func outputRemainingDays(date: String) -> Int {
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: Locale(identifier: "ja_JP"))
        let currentDate = dateFormatter.string(from: now)
        let curDate = dateFormatter.date(from: currentDate)
        let repDate = dateFormatter.date(from: date)

        return (Calendar.current.dateComponents([.day], from: curDate!, to: repDate!)).day!
        
    }
    
    func iconSetToLabel(cell: PostTableViewCell){
        
        fontAwesomeIconSet(iconLabel: cell.themeIcon, iconName: .fontAwesomeIcon(name: .heart))
        fontAwesomeIconSet(iconLabel: cell.presentIcon, iconName: .fontAwesomeIcon(name: .gem))
        fontAwesomeIconSet(iconLabel: cell.dateIcon, iconName: .fontAwesomeIcon(name: .calendarAlt))
        fontAwesomeIconSet(iconLabel: cell.budgetIcon, iconName: .fontAwesomeIcon(name: .moneyBillAlt))
        
    }
    
    func fontAwesomeIconSet(iconLabel: UILabel, iconName: String) {
        
        let font = UIFont.fontAwesome(ofSize: 14.0, style: .regular)
        let color = AppTheme.mainColor
        let fontAwesomeIcon = iconName
        
        iconLabel.font = font
        iconLabel.text = fontAwesomeIcon
        iconLabel.textColor = color
    }
    
    func showNotificationLabel(cell: PostTableViewCell) {
        
        cell.notificationLabel.layer.cornerRadius = 3
        cell.notificationLabel.clipsToBounds = true
        
        if post.info?.enable != nil {
            cell.notificationLabel.isHidden = false
            
            cell.notificationLabel.text =
                "[\(String(post.info!.repetition))] \(String(post.info!.date))、\(String(post.info!.time))"
            
        } else {
            cell.notificationLabel.isHidden = true
        }
    }
    
    func showSubProgressView(cell: PostTableViewCell){
        
        UIView.animate(withDuration: 1.0) {
            cell.subProgressView.value = CGFloat(self.post.deposit)
        }
        cell.subProgressView.maxValue = CGFloat(post.budget)
    }
    
    func showMiniBankView(){
        
        let sumBudget: Int = posts.sum(ofProperty: "budget")
        let sumDeposit: Int = posts.sum(ofProperty: "deposit")
                
        savingLabel.text = "\(bank.saving)円"
        sumDepositLabel.text = "\(sumDeposit)円"
        presentCostLabel.text = "\(sumBudget)円"
        
        //mainProgressViewを表示
        showMainProgressView(sumBudget: sumBudget, sumDeposit: sumDeposit)
    }
    
    func showMainProgressView(sumBudget: Int, sumDeposit: Int) {
                
        var amount: Int = 0
        
        (text: progressLabel.text, color: progressLabel.textColor) = {
            
            amount = sumBudget - (bank.saving + sumDeposit)
            return amount < 0 ? (text: "+ \(-(amount))円", color: .blue) : (text: "- \(amount)円", color: .red)
            
        }()
        
        UIView.animate(withDuration: 1.0) {
            self.mainProgressView.value = CGFloat(amount)
        }
        
        mainProgressView.maxValue = CGFloat(sumBudget)
    }
    
    func loadPostsFromRealm(){
        
        posts = realm.objects(Post.self).filter("finished = false")
        
    }
    
    func loadBankFromRealm() {
        if realm.objects(Bank.self).filter("id = 0").first != nil{
            
            bank = realm.objects(Bank.self).filter("id = 0").first!
        } else {
            print("Bankデータが存在しません。")
        }
    }
}
