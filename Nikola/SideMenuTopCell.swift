//
//  SideMenuTopCell.swift
//  Nikola
//
//  Created by Sutharshan on 5/23/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation


import UIKit
import Toucan
import AlamofireImage
import SDWebImage

class SideMenuTopCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //imgView.image = Toucan(image: imgView.image!).maskWithEllipse().image
        
      
        imgView.layer.masksToBounds=true
        imgView.layer.borderWidth=1.5
        imgView.layer.borderColor = UIColor.orange.cgColor
        imgView.layer.cornerRadius=imgView.bounds.width/2
        
        
        let defaults = UserDefaults.standard
        var pic: String = defaults.string(forKey: Const.Params.PICTURE)!
        
        if !pic.isEmpty{
            pic = pic.decodeUrl()
            
            let url = URL(string: pic)!
            
            print(url)
            
           imgView.sd_setImage(with: url as URL?, placeholderImage:  UIImage(named: "defult_user")!)
            
//            let placeholderImage = UIImage(named: "ellipse_contacting")!
//            
//            imgView?.af_setImage(
//                withURL: url,
//                placeholderImage: placeholderImage,
//                filter: filter
//            )
        }else{
            imgView.image = Toucan(image: UIImage(named: "defult_user")!).maskWithEllipse().image
        }
        
        lblName.text = defaults.string(forKey: Const.Params.FIRSTNAME)!

        
        //imgView.center = CGPoint(x:150, y:150); // set center

    }
    
}
