//
//  FinishedTableViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/18.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//


import UIKit
import FontAwesome_swift
import RealmSwift

class FinishedTableViewController: UITableViewController {
    //MARC: Properties
    var posts: Results<Post>!
    var post = Post()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
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
        let budgetLabelText = budgetIcon + "  " + "\(post.budget)円"
        let attrBudgetLabel = NSMutableAttributedString(string: budgetLabelText)
        attrBudgetLabel.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, 1))
        cell.budgetLabel.font = font
        cell.budgetLabel.attributedText = attrBudgetLabel
        
        //残り日数
        cell.remainingTimeLabel.text = "あとxx日"
        
        //photoを丸く表示
        cell.photoImageView.image = post.photo
        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.size.width * 0.5
        
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
    
    func loadPosts(){
        
        posts = realm.objects(Post.self)
        
        self.tableView.reloadData()
    }
}

