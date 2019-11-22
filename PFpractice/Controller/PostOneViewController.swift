//
//  PostOneViewController.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/22.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit

class PostOneViewController: UIViewController {
    
    //MARC: Properties
    var post = Post(name: "", theme: "", present: "", date: "", budget: 0, photo: nil, backImage: nil, remainingTime: "")

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
        
        
        
        backImage.image = post?.backImage
        heroImage.image = post?.photo
        nameLabel.text = post?.name
        themeLabel.text = post?.theme
        presentLabel.text = post?.present
        dateLabel.text = post?.date
        budgetLabel.text = "500 / \(post?.budget ?? 0)円"
        
        heroImage.layer.cornerRadius = heroImage.frame.size.width * 0.5
    }

}
