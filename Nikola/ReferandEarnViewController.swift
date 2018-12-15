//
//  ReferandEarnViewController.swift
//  Nikola
//
//  Created by Mac on 19/09/18.
//  Copyright © 2018 Nikola. All rights reserved.
//

import UIKit

class ReferandEarnViewController: UIViewController {
 @IBOutlet weak var referralCodeBtn: UIButton!
     @IBOutlet weak var referreeBonusLabel: UILabel!
    
    var referralCodeTxt : String = ""
    var referreeBonus : String = "00"
      var currency : String = "$"
    
    override func viewDidLoad() {
        super.viewDidLoad()
               let defaults = UserDefaults.standard
        if defaults.object(forKey: Const.Params.REFERRAL_CODE) != nil {
            referralCodeTxt = defaults.string(forKey: Const.Params.REFERRAL_CODE)!
        }
        if let curr: String = UserDefaults.standard.string(forKey: "currency") {
            
            currency = curr
            
        }
        if defaults.object(forKey: Const.Params.REFERRAL_BONUS) != nil {
          referreeBonus = defaults.string(forKey: Const.Params.REFERRAL_BONUS)!
        }
       
         referreeBonusLabel.text = "\(currency)"  + referreeBonus
  
        referralCodeBtn.setTitle(referralCodeTxt, for: .normal)

    }
    
  
    @IBAction func copyReferralCode(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = referralCodeTxt
        self.view.makeToast(message: "Copied Referral code")
    }

    @IBAction func inviteRefetrralActionMethod(_ sender: Any) {
        let items = [referralCodeTxt]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
           self.dismiss(animated: true, completion: nil)
    }


}
