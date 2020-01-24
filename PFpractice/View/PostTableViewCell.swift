//
//  PostTableViewCell.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/20.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class PostTableViewCell: UITableViewCell {
    
    //MARC: Properties
    @IBOutlet weak var themeIcon: UILabel!
    @IBOutlet weak var presentIcon: UILabel!
    @IBOutlet weak var dateIcon: UILabel!
    @IBOutlet weak var budgetIcon: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var presentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var subProgressView: MBCircularProgressBarView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
