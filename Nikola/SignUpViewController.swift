//
//  SignUpViewController.swift
//  Alicia
//
//  Created by Sutharshan on 5/4/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController:UIViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate {
    
    
//    @IBOutlet weak var countryName: UILabel!
//    @IBOutlet weak var countryCode: UILabel!
//    @IBOutlet weak var countryFlag: UIImageView!
//    @IBOutlet weak var phoneCode: UILabel!
    @IBOutlet weak var countryBtn: UIButton!
    
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var mobileLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    @IBOutlet weak var maleRadioBtn: SSRadioButton!
    
    @IBOutlet weak var femaleRadioBtn: SSRadioButton!
    
    var radioButtonController: SSRadioButtonsController?

    @IBOutlet weak var profileImage: UIImageView!
    
    var gender: String = "male"
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameLabel.delegate = self
        firstNameLabel.tag = 0
        lastNameLabel.delegate = self
        lastNameLabel.tag = 1
        emailLabel.delegate = self
        emailLabel.tag = 2
        mobileLabel.delegate = self
        mobileLabel.tag = 3
        passwordLabel.delegate = self
        passwordLabel.tag = 4
        
        radioButtonController = SSRadioButtonsController(buttons: maleRadioBtn, femaleRadioBtn)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func didSelectButton(selectedButton: UIButton?)
    {
        NSLog(" \(selectedButton)" )
        gender = (selectedButton?.currentTitle)!
    }
    
    @IBAction func showCountryPickerPopup(_ sender: Any) {
        
        guard let countryPopupVC = UIStoryboard(name: "Main", bundle: nil ).instantiateViewController(withIdentifier: "CountryPopupController") as? CountryPopupController else {
            return
        }
        
        countryPopupVC.didSelectCountry = { [weak self](item) in
            if let countryPopupVC = self {
                // Do something with the item.
                let btnTxt: String = "" + item
                self?.countryBtn.setTitle(btnTxt, for: UIControlState.normal)
            }
        }
        
        self.addChildViewController(countryPopupVC)
        countryPopupVC.view.frame = self.view.frame
        self.view.addSubview(countryPopupVC.view)
        countryPopupVC.didMove(toParentViewController: self)
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        
        if firstNameLabel.text?.length == 0 {
            self.view.makeToast(message: "Enter first name")
            return
        }
        
        if lastNameLabel.text?.length == 0 {
            self.view.makeToast(message: "Enter last name")
            return
        }
        
        if emailLabel.text?.length == 0 {
            self.view.makeToast(message: "Enter email id")
            return
        } else if !isValidEmailAddress(emailAddressString: emailLabel.text!){
            self.view.makeToast(message: "Enter valid email id")
            return
        }
        
        if mobileLabel.text?.length == 0 {
            self.view.makeToast(message: "Enter mobile number")
            return
        }
        
        if passwordLabel.text?.length == 0 {
            self.view.makeToast(message: "Enter password")
            return
        }else if (passwordLabel.text?.length)! < 8 {
            self.view.makeToast(message: "Password length must be greater than 7")
            return
        }
        
        let user_defaults = UserDefaults.standard
        var countryCode = user_defaults.string(forKey: "temp_phonecode")
        
        if (countryCode ?? "").isEmpty {
            countryCode = "+91"
        }
        
        API.signUp(firstname: firstNameLabel.text!, lastName: lastNameLabel.text!, email: emailLabel.text!, mobile: mobileLabel.text!, countryCode: countryCode!, currency: "USD", timezone: "IN", password: passwordLabel.text!, gender: gender) { json, error in
            
            
            let status = json![Const.STATUS_CODE].stringValue
            let statusMessage = json![Const.STATUS_MESSAGE].stringValue
            if(status == "false"){
                
                print(statusMessage)
                print(json ?? "json empty")
            }
            else{
                
                print("Full Login JSON")
                print(json ?? "json null")
                print(json!["response"]["_id"].stringValue)
                print(json!["response"]["name"].stringValue)
                print(json!["response"]["mobile"].stringValue)
                print(json!["response"]["token"].stringValue)
                
                let defaults = UserDefaults.standard
                
                defaults.set(json![Const.Params.ID].stringValue, forKey: Const.Params.ID)
                defaults.set(json![Const.Params.TOKEN].stringValue, forKey: Const.Params.TOKEN)
                defaults.set(json![Const.Params.FIRSTNAME].stringValue, forKey: Const.Params.FIRSTNAME)
                defaults.set(json![Const.Params.LAST_NAME].stringValue, forKey: Const.Params.LAST_NAME)
                defaults.set(json![Const.Params.REFERRAL_CODE].stringValue, forKey: Const.Params.REFERRAL_CODE)
                defaults.set(json![Const.Params.REFERRAL_BONUS].stringValue, forKey: Const.Params.REFERRAL_BONUS)
                defaults.set(json![Const.Params.CURRENCEY].stringValue, forKey: Const.Params.CURRENCEY)
                defaults.set(json![Const.Params.GENDER].stringValue, forKey: Const.Params.GENDER)
                defaults.set(json![Const.Params.EMAIL].stringValue, forKey: Const.Params.EMAIL)
                defaults.set(json![Const.Params.PHONE].stringValue, forKey: Const.Params.PHONE)
                defaults.set(json![Const.Params.TIMEZONE].stringValue, forKey: Const.Params.TIMEZONE)
                defaults.set(json![Const.Params.PICTURE].stringValue, forKey: Const.Params.PICTURE)
                defaults.set(json![Const.Params.LOGIN_BY].stringValue, forKey: Const.Params.LOGIN_BY)
                defaults.set(json![Const.Params.COUNTRY].stringValue, forKey: Const.Params.COUNTRY)
                defaults.set(json![Const.Params.PAYMENT_MODE_STATUS].stringValue, forKey: Const.Params.PAYMENT_MODE_STATUS)
                
                 defaults.set(json![Const.Params.WALLET_BAY_KEY].stringValue, forKey: Const.Params.WALLET_BAY_KEY)

                
                print("LOGIN SUCCESS GOING TO MAIN")
                self.goToDashboard()
            }
        }
        
    }
    
    @IBOutlet weak var goToSignIn: UIButton!
    
    
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
    
    func goToSignInController(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
 
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
}
