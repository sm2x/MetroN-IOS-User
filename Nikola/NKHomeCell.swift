//
//  NKHomeCell.swift
//  Nikola
//
//  Created by sudharsan s on 04/12/17.
//  Copyright © 2017 Nikola. All rights reserved.
//

import UIKit
import Localize_Swift

class NKHomeCell: UITableViewCell {

    @IBOutlet weak var lblHome: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        lblHome.text = "Home".localized()
        // Configure the view for the selected state
    }

}
