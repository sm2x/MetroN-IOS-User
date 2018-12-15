//
//  OTPVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 8/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
//import Material

class OTPVC: BaseViewController,UITextFieldDelegate  {

    
    var strPhoneNumber : String!
    var strOTPCode : String!
    
    
    @IBOutlet weak var mobileTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var otpTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var lblNotRecive: UILabel!
    @IBOutlet weak var lblPhonenumber: UILabel!
    
    @IBOutlet weak var lblOTP: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(with: "Sign Up".localized())
        
        lblOTP.text = "Please Enter Valid OTP!".localized()
        lblPhonenumber.text = "You will have your OTP sent to the following mobile number!".localized()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        
        
        mobileTextField.delegate = self
        mobileTextField.text = strPhoneNumber
        mobileTextField.tag = 0
        
      
        otpTextField.delegate = self
        otpTextField.text = strOTPCode
        otpTextField.tag = 1
        
        mobileTextField.addDoneButtonOnKeyboard()
        otpTextField.addDoneButtonOnKeyboard()

        NotificationCenter.default.addObserver(self, selector: #selector(OTPVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OTPVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        
        // Do any additional setup after loading the view.
    }

    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 100
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 100
            }
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    

    func navigationMethod() {
        
         UserDefaults.standard.set(self.strPhoneNumber, forKey: "user_PhoneNumber")
        
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "NextNameVC") as! NextNameVC
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    
    
    func getOTP(){
        
        self.strPhoneNumber = self.mobileTextField.text!
        
        self.showLoader( str: "Resending OTP")
        
        API.getOTP(mobile: self.strPhoneNumber ){ json, error in
            
            if let error = error {
                self.showAlert(with :error.localizedDescription)
                //print(error.debugDescription)
                //self.view.makeToast(message: (error?.localizedDescription)!)
            }
            else {
                
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        self.hideLoader()
                        let otp: String = json["code"].stringValue
                        self.strOTPCode = otp
                        
                        print(json ?? "error in getOTP json")
                        
                        self.view.makeToast(message: "OTP Resent. Please enter the new OTP")
                        
                    }else{
                        self.hideLoader()
                        print(statusMessage)
                        print(json ?? "getOTP json empty")
                        var msg = json[Const.DATA].rawString()!
                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        //                    self.view.makeToast(message: msg)
                        
                        self.showAlert(with: msg)
                    }
                }else{
                    self.hideLoader()
                    self.showAlert(with: (error?.localizedDescription)!)
                }
                }
               
        }
    }

    
    
    @IBAction func resendOTPButtonAction(_ sender: Any) {
    }
    
    
    @IBAction func proceedButtonActionMethod(_ sender: Any) {
        
        
        if (mobileTextField.text?.isEmpty)! {
            mobileTextField.errorMessage = "Please Enter Proper Phone Number"
        }else if(otpTextField.text?.isEmpty)! {
      
            mobileTextField.errorMessage = nil
            otpTextField.errorMessage = "Please Enter Valid OTP"
        }else if(otpTextField.text == strOTPCode) {
            mobileTextField.errorMessage = nil
            otpTextField.errorMessage = nil
            
            navigationMethod()
            
        }
        else{
            mobileTextField.errorMessage = "Please Enter Proper Phone Number"
        }

        
    }
    
    
    
    
    func validatePhoneNo(_ candidate: String) -> Bool {
        
        // NOTE: validating email addresses with regex is usually not the best idea.
        // This implementation is for demonstration purposes only and is not recommended for production use.
        // Regex source and more information here: http://emailregex.com
        
         let emailRegex = "^((\\+)|(00))[0-9]{6,14}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
      
}

//extension OTPVC: TextFieldDelegate {
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


