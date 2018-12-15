//
//  NKReferandEarnTableViewCell.swift
//  Nikola
//
//  Created by Sreedeep Paul on 19/09/18.
//  Copyright © 2018 Nikola. All rights reserved.
//

import UIKit
import Localize_Swift
class NKReferandEarnTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
 lblTittle.text = "Refer and Earn".localized()
        // Configure the view for the selected state
    }

}
