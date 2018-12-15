//
//  MobileNumberValidationVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 8/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.telestratum
//

import UIKit
import MRCountryPicker
//import Material

protocol updateCountryCodeProtocal {
    
    func updateCountryCodeMethod(with dic: [String: String])
}


class MobileNumberValidationVC: BaseViewController, UITextFieldDelegate {

    
    @IBOutlet weak var countryPicker: MRCountryPicker!
   
    @IBOutlet weak var countryFlag: UIImageView!
   
    
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var confimBtn: UIButton!
    
    var countryCodeString : String = ""
    var phoneNumberString : String = ""
    
    var fullPhoneString : String = ""
    var otpString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.setupNavigationBar(with: "Sign Up".localized())
        mobileTextField.placeholder = "Phone Number".localized()
        confimBtn.setTitle("CONFIRM PHONE NUMBER".localized(), for: .normal)
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        
//        countryPicker.countryPickerDelegate = self
//        countryPicker.showPhoneNumbers = true
        
//        mobileTextField.detail = "Enter valid mobile number"
//        mobileTextField.delegate = self
//        mobileTextField.tag = 0
//        
//        mobileTextField.borderStyle = .none
//        mobileTextField.layer.masksToBounds = false
//        mobileTextField.layer.shadowColor = UIColor.darkGray as! CGColor
//        mobileTextField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//        mobileTextField.layer.shadowOpacity = 2.0
//        mobileTextField.layer.shadowRadius = 0.0
        
        mobileTextField.setBottomBorder()
        
        
//        mobileTextField.borderStyle = .none
//        mobileTextField.layer.backgroundColor = UIColor.white.cgColor
//
//        mobileTextField.layer.masksToBounds = false
//        mobileTextField.layer.shadowColor = UIColor.darkGray.cgColor
//        mobileTextField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//        mobileTextField.layer.shadowOpacity = 1.0
//        mobileTextField.layer.shadowRadius = 0.0
        
        let regionCode: String = Locale.current.regionCode!
        
        if (regionCode ?? "").isEmpty{
            countryPicker.setCountry("US")
        }else{
            countryPicker.setCountry(regionCode)
        }
        // set country by its code
        
        
        countryPicker.isHidden = true
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MobileNumberViewController.imageTapped(gesture:)))
        
        // add it to the image view;
//        countryFlag.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        countryFlag.isUserInteractionEnabled = true
        
        mobileTextField.addDoneButtonOnKeyboard()
        
        print("region code")
        print(Locale.current.regionCode)

        
        
        
        // Do any additional setup after loading the view.
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        //        self.navigationController?.isNavigationBarHidden = true
        
//                  readJson()
        
          UIApplication.shared.isStatusBarHidden = false
    }

    
    
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "countryCodes", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as? [Any] {
                    // json is an array
                    print(object)
                    
                
                    for arry  in object {
                        
                        
                        let dic : [String: String] = arry as! [String : String]                        
                       print(dic["name"]!)
                        
                       
                        
                    }
                    
                    
                    
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    
    
    
//    // a picker item was selected
//    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
//        //        self.countryName.text = name
//        //        self.countryCode.text = countryCode
//        //        self.phoneCode.text = phoneCode
//
//        self.countryCodeString = phoneCode
//        self.countryFlag.image = flag
//        self.countryBtn.setTitle("\(countryCode) \(phoneCode)", for: .normal)
//        self.countryBtn.imageView?.image = flag
//
//
//    }
    
    
    
    @IBAction func countryBtn(_ sender: UIButton) {
//        countryPicker.isHidden = false
    }

    
    
    func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            //Here you can initiate your new ViewController
            
            self.countryPicker.isHidden = false
        }
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

    
    
    @IBAction func confirmAction(_ sender: UIButton) {
        
        
        
        if (mobileTextField.text?.characters.isEmpty)! {
            
           self.showAlert(with: "Please Enter Valid Phone No")
//            mobileTextField.errorMessage = "Please Enter Valid Phone No"
        } else if !validateEmail(mobileTextField.text!) {
            self.showAlert(with: "Please Enter Valid Phone No")
//             mobileTextField.errorMessage = "Please Enter Valid Phone No"
        } else {
            countryPicker.isHidden = true
            getOTP()
//            mobileTextField.errorMessage = nil
        }
        
        
        
       
        
//        if (mobileTextField.text?.isEmpty)! || !(mobileTextField.text?.isNumeric)! {
//             countryPicker.isHidden = true
//           mobileTextField.errorMessage = "Please Enter Valid Email Id"
//        }else{
////            mobileTextField.isErrorRevealed = false
//             countryPicker.isHidden = true
//            getOTP()
//        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CountryCodeVC" {
            if let destVC = segue.destination as? CountryCodeVC {
                destVC.delegate = self
            }
        }
    }
    
    // MARK: - validation
    
    func validateEmail(_ candidate: String) -> Bool {
        
        // NOTE: validating email addresses with regex is usually not the best idea.
        // This implementation is for demonstration purposes only and is not recommended for production use.
        // Regex source and more information here: http://emailregex.com
        
        let emailRegex = "^[0-9]{6,13}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    
    func getOTP(){
        
        let phone : String = self.countryCodeString + self.mobileTextField.text!
        
         self.showLoader( str: "Getting OTP")
               
        API.getOTP(mobile: phone ){ json, error in
            
            if let error = error {
                 self.showAlert(with :error.localizedDescription)
                //print(error.debugDescription)
               // self.view.makeToast(message: (error?.localizedDescription)!)
            }else {
                
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                      
                        let otp: String = json["code"].stringValue
                        self.fullPhoneString = phone
                        self.otpString = otp
                        
                        //   self.performSegue(withIdentifier: "gotoOtp", sender: self)
                        
                        self.hideLoader()
                        //
                        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVC") as! OTPVC
                        myVC.strPhoneNumber = phone
                        myVC.strOTPCode = otp
                        
                        self.navigationController?.pushViewController(myVC, animated: true)
                        //
                        //                    print(json ?? "error in getOTP json")
                        
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MobileNumberValidationVC: updateCountryCodeProtocal {
    
    
    func updateCountryCodeMethod(with dic: [String: String]) {
        
        let code : String = dic["dial_code"]!
    
        let str : String = "\(dic["code"]!) \(dic["dial_code"]!)"
        
        countryBtn.setTitle(str, for: .normal)
        
//        countryPicker.setCountry(code)
        
        countryFlag.image = UIImage(named: dic["code"]!)
        
    }
    
}
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

