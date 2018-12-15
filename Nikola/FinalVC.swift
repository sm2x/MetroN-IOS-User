//
//  FinalVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 8/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
//import Material
import BraintreeDropIn
import Braintree

class FinalVC: BaseViewController,UITextFieldDelegate {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtReferralCode: UITextField!
    
    var strPhoneNumber : String!
    var strFirtName : String!
    var strLastName : String!
    var strEmail : String!
    @IBOutlet weak var finsh: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(with: "Sign Up".localized())
        txtPassword.placeholder = "Password".localized()
         txtReferralCode.placeholder = "Enter Referral code".localized()
        finsh.setTitle("FINISH".localized(), for: .normal)
        txtPassword.delegate = self
        txtReferralCode.delegate = self
        txtPassword.setBottomBorder()
        txtReferralCode.setBottomBorder()
        
        if let str = UserDefaults.standard.string(forKey: "user_PhoneNumber") {
            
            strPhoneNumber = str
            
            print(strPhoneNumber)
            
        }
       
        if let str = UserDefaults.standard.string(forKey: "user_FirstName") {
            
            strFirtName = str
            
            print(strFirtName)
            
        }

        if let str = UserDefaults.standard.string(forKey: "user_LastName") {
            
            strLastName = str
            
            print(strLastName)
            
        }

        if let str = UserDefaults.standard.string(forKey: "user_Email") {
            
            strEmail = str
            
            print(strEmail)
            
        }

        

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    
    func doregistration() {
        
          self.showLoader( str: "Please wait...")
        
        API.register2(firstName: strFirtName, lastName: strLastName, email: strEmail, password: self.txtPassword.text!, mobile: strPhoneNumber) { json, error in
            
            if let error = error {
                self.showAlert(with :error.localizedDescription)
               // print(error.debugDescription)
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        print(json ?? "error in register2 json")
                        
                        let defaults = UserDefaults.standard
                        
                        defaults.set(json[Const.Params.ID].stringValue, forKey: Const.Params.ID)
                        defaults.set(json[Const.Params.TOKEN].stringValue, forKey: Const.Params.TOKEN)
                        defaults.set(json[Const.Params.FIRSTNAME].stringValue, forKey: Const.Params.FIRSTNAME)
                        defaults.set(json[Const.Params.LAST_NAME].stringValue, forKey: Const.Params.LAST_NAME)
                        defaults.set(json[Const.Params.CURRENCEY].stringValue, forKey: Const.Params.CURRENCEY)
                        defaults.set(json[Const.Params.REFERRAL_CODE].stringValue, forKey: Const.Params.REFERRAL_CODE)
                        defaults.set(json[Const.Params.REFERRAL_BONUS].stringValue, forKey: Const.Params.REFERRAL_BONUS)
                        defaults.set(json[Const.Params.GENDER].stringValue, forKey: Const.Params.GENDER)
                        defaults.set(json[Const.Params.EMAIL].stringValue, forKey: Const.Params.EMAIL)
                        defaults.set(json[Const.Params.PHONE].stringValue, forKey: Const.Params.PHONE)
                        defaults.set(json[Const.Params.TIMEZONE].stringValue, forKey: Const.Params.TIMEZONE)
                        defaults.set(json[Const.Params.PICTURE].stringValue, forKey: Const.Params.PICTURE)
                        defaults.set(json[Const.Params.LOGIN_BY].stringValue, forKey: Const.Params.LOGIN_BY)
                        defaults.set(json[Const.Params.COUNTRY].stringValue, forKey: Const.Params.COUNTRY)
                        defaults.set(json[Const.Params.PAYMENT_MODE_STATUS].stringValue, forKey: Const.Params.PAYMENT_MODE_STATUS)
                        defaults.set(json[Const.Params.WALLET_BAY_KEY].stringValue, forKey: Const.Params.WALLET_BAY_KEY)
                        
                        
                        //self.view.makeToast(message: "OTP Resent. Please enter the new OTP")
                        //                    self.getBrainTreeClientToken()
                        self.goToDashboard()
                        
                        
                    }else{
                        self.hideLoader()
                        print(statusMessage)
                        print(json ?? "register2 json empty")
                        
                        let error_code = json[Const.ERROR_CODE].int
                        
                        
                        guard error_code == 101 else {
                            
                            var msg = json[Const.ERROR].rawString()!
                            //                    self.view.makeToast(message: msg)
                            self.showAlert(with: msg)
                            
                            return
                        }
                        
                        
                        var msg = json[Const.NEW_ERROR].rawString()!
                        //                    self.view.makeToast(message: msg)
                        self.showAlert(with: msg)
                        
                    }
                    
                }else {
                    print("invalid json :(")
                }
            }
            
            
          
        }

        
        
    }
    
    
    
    func getBrainTreeClientToken(){
        
        API.getBrainTreeClientToken { json, error in
            
            if (error != nil) {
                print(error.debugDescription)
                self.view.makeToast(message: (error?.localizedDescription)!)
                return
            }
            if json != nil {
                let status = json![Const.STATUS_CODE].boolValue
                let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                if(status){
                    let clientToken: String = json!["client_token"].stringValue
                    print(json ?? "error in getBrainTreeClientToken json")
                    self.showDropIn(clientTokenOrTokenizationKey: clientToken)
                }else{
                    print(statusMessage)
                    print(json ?? "getBrainTreeClientToken json empty")
                    var msg = json![Const.ERROR].rawString()!
//                    self.view.makeToast(message: msg)
                    
                     self.showAlert(with: msg)
                }
            }
        }
    }

    
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
            
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
//                self.view.makeToast(message: (error?.localizedDescription)!)
                self.hideLoader()
                 self.showAlert(with: (error?.localizedDescription)!)
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
                self.view.makeToast(message: "Please enter payment information to proceed")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                
                self.sendNonce(nonce: (result.paymentMethod?.nonce)!)
                //self.goToDashboard()
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    
    func sendNonce(nonce: String){
        API.sendNonce(nonce: nonce, completionHandler: { json, error in
            if (error != nil) {
                print(error.debugDescription)
                self.view.makeToast(message: (error?.localizedDescription)!)
                return
            }
            if json != nil {
                let status = json![Const.STATUS_CODE].boolValue
                let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                if(status){
                    print(json ?? "error in sendNonce json")
                    self.goToDashboard()
                }else{
                    self.hideLoader()
                    print(statusMessage)
                    print(json ?? "sendNonce json empty")
                    var msg = json![Const.ERROR].rawString()!
//                    self.view.makeToast(message: msg)
                     self.showAlert(with: msg)
                    
                }
            }
        })
    }

    
    func goToDashboard() {
         self.hideLoader()
     
//        let homeNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as! UIViewController
//        
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        let nav = UINavigationController(rootViewController: homeNav)
//        
//        appDelegate.window?.rootViewController = nav
        
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
        

        
    }
     @IBAction func applyPromoCode(_ sender: Any) {
        
        txtReferralCode.resignFirstResponder()
        
        if (txtReferralCode.text?.isEmpty)! || (txtReferralCode.text?.length)! < 2 {
            self.showAlert(with: "Promo code not correct/Promo code is empty")
        }
        else{
        self.showLoader( str: "Please wait...")
        API.applyReferralCode(referalCode: txtReferralCode.text!, completionHandler:{ json, error in
            if (error != nil) {
                     self.hideLoader()
                print(error.debugDescription)
                self.view.makeToast(message: (error?.localizedDescription)!)
                return
            }
            if json != nil {
                     self.hideLoader()
                let status = json![Const.STATUS_CODE].boolValue
                let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                if(status){
                  let statusMessage = json![Const.MESSAGE].stringValue
                    
                 self.view.makeToast(message: statusMessage)
                }else{
                    self.hideLoader()
                    print(statusMessage)
                    let msg = json![Const.ERROR].rawString()!
                    self.view.makeToast(message: msg)
                    self.showAlert(with: msg)
                    
                }
            }
        })
        }
    }
    
    @IBAction func registrationButtonActionMethod(_ sender: Any) {
        
        if (txtPassword.text?.isEmpty)! || (txtPassword.text?.length)! < 8 {
            
            self.showAlert(with: "Password Should be Mininum 8 Characters")
            
//            txtPassword.errorMessage = "Password Should be Mininum 8 Characters"
            
        }
            
        else {
         
//             txtPassword.errorMessage = nil
            doregistration()
            
        }

        
    }
 

}
//extension FinalVC: TextFieldDelegate {
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        (textField as? ErrorTextField)?.isErrorRevealed = false
//    }
//
//    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        (textField as? ErrorTextField)?.isErrorRevealed = false
//        return true
//    }
//
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        (textField as? ErrorTextField)?.isErrorRevealed = false
//        return true
//    }
//}


