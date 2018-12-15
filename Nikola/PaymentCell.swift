//
//  PaymentCell.swift
//  Nikola
//
//  Created by Sutharshan Ram on 25/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

import UIKit

class PaymentCell: UITableViewCell {
    
    @IBOutlet weak var radioButton: UIButton!
    
    @IBOutlet weak var cardNumber: UILabel!
    
    @IBOutlet weak var cardTypeImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
