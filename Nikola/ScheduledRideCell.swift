//
//  ScheduledRideCell.swift
//  Nikola
//
//  Created by Sutharshan Ram on 15/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class ScheduledRideCell: UITableViewCell {
    
    @IBOutlet weak var carImg: UIImageView!
    @IBOutlet weak var ridetime: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var pickUpAddress: UILabel!
    @IBOutlet weak var dropAddress: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
