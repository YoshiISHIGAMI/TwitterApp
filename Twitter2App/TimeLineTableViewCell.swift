//
//  TimeLineTableViewCell.swift
//  Twitter2App
//
//  Created by Yoshi Ishigami on 2015/09/13.
//  Copyright (c) 2015年 Yoshi Ishigami. All rights reserved.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tweetLabel: UILabel!

}
