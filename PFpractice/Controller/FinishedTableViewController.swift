//
//  FinishedTableViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/05.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import FontAwesome_swift
import RealmSwift
import Loaf

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
        let cellIdentifier = "FinishedTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FinishedTableViewCell else {
            
            fatalError("dequeueできませんでした。")
        }
        
        let post = posts[indexPath.row]
        
        //アイコンを表示
        setIconFromFontAwesome(cell: cell)
        
        //各ラベルとイメージを表示
        setPostLabelAndImage(cell: cell, post: post)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            let deletePost = self.posts![indexPath.row]
            
            Loaf("\(deletePost.name)のポストが削除されました", state: .success, location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
            
            try! realm.write {
                realm.delete(deletePost)
            }
            
            self.tableView.reloadData()
            
            
        }
    }
    
    func loadPosts(){
        
        posts = realm.objects(Post.self).filter("finished = true")
        
        self.tableView.reloadData()
    }
    
    func setPostLabelAndImage(cell: FinishedTableViewCell, post: Post){
        
        cell.nameLabel.text = post.name
        cell.themeLabel.text = post.realTheme
        cell.presentLabel.text = post.realPresent
        cell.dateLabel.text = post.realDate
        cell.budgetLabel.text = String(post.realCost)
        //photoを丸く表示
        cell.photoImageView.image = post.photo
        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.size.width * 0.5
    }
    
    func setIconFromFontAwesome(cell: FinishedTableViewCell){
        
        let font = UIFont.fontAwesome(ofSize: 13.0, style: .regular)
        let color = UIColor.init(red: 219/255, green: 68/255, blue: 55/255, alpha: 1.0)
        
        //FAアイコン。
        cell.themeIcon.font = font
        cell.themeIcon.text = String.fontAwesomeIcon(name: .heart)
        cell.themeIcon.textColor = color
        cell.presentIcon.font = font
        cell.presentIcon.text = String.fontAwesomeIcon(name: .gem)
        cell.presentIcon.textColor = color
        cell.dateIcon.font = font
        cell.dateIcon.text = String.fontAwesomeIcon(name: .calendarAlt)
        cell.dateIcon.textColor = color
        cell.budgetIcon.font = font
        cell.budgetIcon.text = String.fontAwesomeIcon(name: .moneyBillAlt)
        cell.budgetIcon.textColor = color
    }
}

