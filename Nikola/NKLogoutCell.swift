//
//  NKLogoutCell.swift
//  Nikola
//
//  Created by sudharsan s on 04/12/17.
//  Copyright © 2017 Nikola. All rights reserved.
//

import UIKit
import Localize_Swift

class NKLogoutCell: UITableViewCell {

    @IBOutlet weak var lblTittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        lblTittle.text = "Logout".localized()
        // Configure the view for the selected state
    }

}
