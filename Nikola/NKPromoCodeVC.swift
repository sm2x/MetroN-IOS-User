//
//  NKPromoCodeVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 15/12/17.
//  Copyright © 2017 Nikola. All rights reserved.
//

import UIKit

class NKPromoCodeVC: BaseViewController,UITextFieldDelegate {
    
    //MARK:- IVAR's
    @IBOutlet weak var txtPromoCode: UITextField!
    @IBOutlet weak var lblPromo: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var applypromoBtn: UIButton!
    
    let defaults = UserDefaults.standard
    
    weak var delegate: updatePromoCodeProtocalDelegate?
    //MARK:- Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElements()
    }
    
    //MARK:- SetUIElements
    fileprivate func setUIElements() {
        txtPromoCode.setBottomBorder()
        txtPromoCode.delegate = self
    }
    //MARK:- Remove keybord from UIView
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK:- Button Action Method
    @IBAction func cancelActionButton(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func applypromoActionButton(_ sender: Any) {
        
        if let promo_code : String = txtPromoCode.text {
            if promo_code.isEmpty {
                self.showAlert(with: "Please Enter PromoCode")
                debugPrint("Please Enter PromoCode")
            }else {
                self.showLoader(str: "Please Wait")
                API.promoCodeApply(with: txtPromoCode.text!){ json, error in
                    if let error = error {
                        self.hideLoader()
                        self.showAlert(with :error.localizedDescription)
                        debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                    }else {
                        if let json = json {
                            let status = json[Const.STATUS_CODE].boolValue
                            if(status){
                                self.hideLoader()
                                self.defaults.set(self.txtPromoCode.text!, forKey: "PROMOCODE")
                                self.view.removeFromSuperview()
                                self.delegate?.updatepromoCode()
                            }else {
                                self.hideLoader()
                                self.view.removeFromSuperview()
                                let msg: String = json[Const.ERROR_MSG].rawString()!
                                self.showAlert(with: msg)
                            }
                            
                        }else {
                            self.hideLoader()
                            debugPrint("invalid json :(")
                        }
                    }
                }
            }
            
        }
        
    }
    
}

