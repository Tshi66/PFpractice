//
//  PostTableViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/20.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import FontAwesome_swift


class PostTableViewController: UITableViewController {
    //MARC: Properties
    var posts = [Post]()
    var post = Post(name: "", theme: "", present: "", date: "", budget: 0, photo: nil, backImage: nil, remainingTime: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSamplePost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Home"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let themeLabelText = themeIcon + "   " + post.theme
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
        cell.remainingTimeLabel.text = "あと\(post.remainingTime)日"
        
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

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARC: Private Method
    private func loadSamplePost(){
        let photo1 = UIImage(named: "hiyoko")
        let photo2 = UIImage(named: "man1")
        let photo3 = UIImage(named: "woman1")
        let photo4 = UIImage(named: "man2")
        let photo5 = UIImage(named: "man3")
        
        let backImage = UIImage(named: "backImage")

        
        guard let post1 = Post(name: "ひよこ", theme: "誕生日", present: "チュール", date: "2019/11/20", budget: 1000, photo: photo1, backImage: backImage, remainingTime: "60") else {
            fatalError("post1は初期化できませんでした。")
        }
        
        guard let post2 = Post(name: "たかし", theme: "誕生日", present: "チュール", date: "2019/11/20", budget: 1000, photo: photo2, backImage: backImage, remainingTime: "60") else {
            fatalError("post2は初期化できませんでした。")
        }
        
        guard let post3 = Post(name: "よしこ", theme: "誕生日", present: "チュール", date: "2019/11/20", budget: 1000, photo: photo3, backImage: backImage, remainingTime: "60") else {
            fatalError("post3は初期化できませんでした。")
        }
        
        guard let post4 = Post(name: "たけし", theme: "誕生日", present: "チュール", date: "2019/11/20", budget: 1000, photo: photo4, backImage: backImage, remainingTime: "60") else {
            fatalError("post4は初期化できませんでした。")
        }
        
        guard let post5 = Post(name: "やまだ", theme: "誕生日", present: "チュール", date: "2019/11/20", budget: 1000, photo: photo5, backImage: backImage, remainingTime: "60") else {
            fatalError("post5は初期化できませんでした。")
        }
        
        posts += [post1, post2, post3, post4, post5]
    }

}
