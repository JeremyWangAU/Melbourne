//
//  NearbyTableViewCell.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 3/1/18.
//  Copyright © 2018 Zihao Wang. All rights reserved.
//

import UIKit

class NearbyTableViewCell: UITableViewCell {

    @IBOutlet weak var nearbyImage: UIImageView!
    @IBOutlet weak var nearbyName: UILabel!
    @IBOutlet weak var nearbyAddress: UILabel!
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
