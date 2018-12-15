//
//  SignInViewController.swift

//  Alicia
//
//  Created by Sutharshan on 5/4/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import Localize_Swift
//import FacebookCore
//import FacebookLogin

class SignInViewController:BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    var is_sentry: Bool! = false
    let loginAuto: Bool = false
    var actionSheet: UIAlertController!
    
    @IBOutlet weak var btnNewUser: UIButton!
    
    @IBOutlet weak var socialbtn: UIButton!
    
    @IBOutlet weak var changelanguageBtn: UIButton!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var forgotpasswordBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.setText()
       // self.setupNavigationBar(with: "Sign In")
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        mobileNumber.delegate = self
        mobileNumber.tag = 0
        password.delegate = self
        password.tag = 1
        
        UserDefaults.standard.set(false, forKey: "loggedIn")
        
        
        
        //        // Add a custom login button to your app
        //        let myLoginButton = UIButton(type: .custom)
        //        myLoginButton.backgroundColor = UIColor.darkGray
        //        myLoginButton.frame = CGRect(x:0, y:0, width:180, height:40)
        //        myLoginButton.center = view.center
        //        myLoginButton.setTitle("My Login Button", for: .normal)
        //
        //        myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        // Handle clicks on the button
        //   myLoginButton.addTarget(self, action:  forControlEvents: .TouchUpInside)
        
        // Add the button to the view
        //  view.addSubview(myLoginButton)
        
        //        if loginAuto {
        //            mobileNumber.text = "sutharshan@provenlogic.net"
        //            password.text = "password"
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    //MARK: UITextFieldDelegate
    //    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
    //        //Hide the keyboard
    //
    //        switch textField.restorationIdentifier! {
    //        case "mobileNumber":
    //                mobileNumber.resignFirstResponder()
    //        case "password":
    //                password.resignFirstResponder()
    //
    //        default: break
    //        }
    //
    //
    //        return true
    //    }
    
    @IBAction func FacebookBtn(_ sender: Any) {
        //self.view.makeToast(message: "Mod in progress. Use direct signup and login pls")
        self.loginButtonClicked()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        //        self.navigationController?.isNavigationBarHidden = true
    //        UIApplication.shared.isStatusBarHidden = false
    //    }
    
    @objc func setText(){
        
        
        self.setupNavigationBar(with: "Sign In".localized())
        
        mobileNumber.placeholder = "Email Id".localized();
        password.placeholder = "Password".localized();
        
        btnNewUser.setTitle("NEW USER?".localized(), for: .normal)
        socialbtn.setTitle("Or connect using a social account".localized(), for: .normal)
        
        forgotpasswordBtn.setTitle("Forgot Password?".localized(), for: .normal)
        signinBtn.setTitle("Sign In".localized(), for: .normal)
        changelanguageBtn.setTitle("Change Language".localized(), for: .normal)
        
    }
    
    @IBAction func doChangeLanguage(_ sender: AnyObject) {
        actionSheet = UIAlertController(title: nil, message: "Switch Language", preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in availableLanguages {
            
            print(language)
            if language == "Base" || language == "km-KH"{
                print("not a language")
                
            }else {
                let displayName = Localize.displayNameForLanguage(language)
                let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Localize.setCurrentLanguage(language)
                })
                
                actionSheet.addAction(languageAction)
            }
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func SignInBtn(_ sender: Any) {
        
        
        if ((mobileNumber.text?.isEmpty)! || (password.text?.isEmpty)!){
            
            self.showAlert(with: "Please fill all the required fields")
            
        }
            
        else {
            
            self.showLoader( str: "Signing In")
            
            API.signIn( email: mobileNumber.text!, password: password.text!){ json, error in
                
                if let error = error {
                    self.hideLoader()
                    self.showAlert(with :error.localizedDescription)
                    debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                }else {
                    if let json = json {
                        let status = json[Const.STATUS_CODE].boolValue
                        
                        
                        let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                            
                            self.hideLoader()
                            
                            print("Full Login JSON")
                            print(json ?? "json null")
                            print(json["response"]["_id"].stringValue)
                            print(json["response"]["name"].stringValue)
                            print(json["response"]["mobile"].stringValue)
                            print(json["response"]["token"].stringValue)
                            
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
                            defaults.set(json[Const.Params.WALLET_BAY_KEY].stringValue, forKey: Const.Params.WALLET_BAY_KEY)
                            defaults.set(json[Const.Params.PAYMENT_MODE_STATUS].stringValue, forKey: Const.Params.PAYMENT_MODE_STATUS)
                            
                            if json[Const.Params.LOGIN_BY].stringValue != Const.MANUAL {
                                defaults.set(json[Const.Params.SOCIAL_ID].stringValue, forKey: Const.Params.SOCIAL_ID)
                            }
                            
                            if json[Const.Params.PAYMENT_MODE_STATUS].exists() {
                                defaults.set(json[Const.Params.PAYMENT_MODE_STATUS].stringValue, forKey: Const.Params.PAYMENT_MODE_STATUS)
                            }
                            
                            
                            print("LOGIN SUCCESS GOING TO MAIN")
                            self.goToDashboard()
                            //self.view.makeToast(message: "Logged In")
                        }else{
                            
                            self.hideLoader()
                            
                            print(statusMessage)
                            print(json ?? "json empty")
                            
                            
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
                            
                            
                            //                        self.view.makeToast(message: msg)
                        }
                        
                    }else {
                        self.hideLoader()
                        debugPrint("Invalid Json :(")
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func goToOTP(){
        
        /*
         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
         self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
         */
    }
    
    func goToDashboard(){
        self.hideLoader()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") 
        self.present(secondViewController, animated: true, completion: nil)
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
    
    
    // Once the button is clicked, show the login dialog
    @objc func loginButtonClicked() {
        /*
         let loginManager = LoginManager()
         loginManager.logIn([ .publicProfile, .email, .custom("user_birthday"),.custom("user_photos"),.custom("user_location") ], viewController: self) { loginResult in
         switch loginResult {
         case .failed(let error):
         print(error)
         case .cancelled:
         print("User cancelled login.")
         case .success(let grantedPermissions, let declinedPermissions, let accessToken):
         self.handleFacebookResponse(accessToken: accessToken.authenticationToken)
         //self.signInToFacebook(accessToken: accessToken.authenticationToken)
         print("Logged in!")
         }
         }
         */
        
    }
    
    var sUserName : String = ""
    var sEmailId : String = ""
    var sSocialUniqueId : String = ""
    var sPictureUrl : String = ""
    var sFirstName : String = ""
    var sLastName : String = ""
    
    
    
    
    
    @IBAction func backActionButton(_ sender: Any) {
        
        
        self.navigationController?.popViewController(animated: true)
        
    }
}
