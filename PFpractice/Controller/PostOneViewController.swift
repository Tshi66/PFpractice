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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        postDataLoad()
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
        budgetLabel.text = "500 / \(post.budget)円"
        
        heroImage.layer.cornerRadius = heroImage.frame.size.width * 0.5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPost" {
            let nextVC: EditPostViewController = (segue.destination as? EditPostViewController)!
            
            nextVC.post = post
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
                realm.delete(post)
            }
        } catch {
            print("Error deleting post \(error)")
        }
    }
}
