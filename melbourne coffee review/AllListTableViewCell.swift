//
//  AllListTableViewCell.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 13/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import UIKit

class AllListTableViewCell: UITableViewCell {

    @IBOutlet weak var AllListImage: UIImageView!
    
    @IBOutlet weak var AlllListAddress: UILabel!
    
    @IBOutlet weak var AllListRating: UILabel!
    
    @IBOutlet weak var AllListName: UILabel!
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
