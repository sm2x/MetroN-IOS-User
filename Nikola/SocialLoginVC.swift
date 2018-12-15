//
//  SocialLoginVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 10/13/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyJSON
import GoogleSignIn

class SocialLoginVC: BaseViewController,GIDSignInUIDelegate {
    var dict : [String : AnyObject]!
    var sUserName : String = ""
    var sEmailId : String = ""
    var sSocialUniqueId : String = ""
    var sPictureUrl : String = ""
    var sFirstName : String = ""
    var sLastName : String = ""
    var isBoolGoogleCalled: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar(with: "Choose an account".localized())
        UserDefaults.standard.set(false, forKey: "loggedIn")
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(SocialLoginVC.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifierGooglePlusLoginDetailsForSignUp"), object: nil)
        
    }
    
    @IBAction func facebookLoginActionMethod(_ sender: Any) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        //fbLoginManager.logOut()
                        
                    }
                }
            }
        }
        
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    print(self.dict)
                    
                    self.sUserName = self.dict["name"] as! String
                    self.sEmailId = self.dict["email"] as! String
                    self.sSocialUniqueId = self.dict["id"] as! String
                    self.sPictureUrl = "https://graph.facebook.com/" + self.sSocialUniqueId + "/picture?type=large"
                    
                    let fullName    = self.sUserName
                    let fullNameArr = fullName.components(separatedBy: " ")
                    
                    self.sFirstName    = fullNameArr[0]
                    self.sLastName = fullNameArr[1]
                    
                    
                    
                    self.showLoader( str: "Signing In")
                    API.signInWithFacebook(socialId: self.dict["id"] as! String){ json, error in
                        if let error = error {
                            self.showAlert(with :error.localizedDescription)
                            // print(error.debugDescription)
                            return
                        }else {
                            if let json = json {
                                let status = json[Const.STATUS_CODE].boolValue
                                let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                                if(status){
                                    
                                    print("Full Login JSON")
                                    print(json ?? "json null")
                                    print(json["response"]["_id"].stringValue)
                                    print(json["response"]["name"].stringValue)
                                    print(json["response"]["mobile"].stringValue)
                                    print(json["response"]["token"].stringValue)
                                    
                                    let defaults = UserDefaults.standard
                                    defaults.set(json[Const.Params.ID].stringValue, forKey: Const.Params.ID)
                                    defaults.set(json[Const.Params.TOKEN].stringValue, forKey: Const.Params.TOKEN)
                                    defaults.set(self.sFirstName, forKey: Const.Params.FIRSTNAME)
                                    defaults.set(self.sLastName, forKey: Const.Params.LAST_NAME)
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
                                }
                                else
                                {
                                    if (json["error_code"].stringValue == "125")
                                    {
                                        
                                        self.SignUPFaceBook()
                                        
                                    }
                                    else
                                        
                                    {
                                        print(statusMessage)
                                        print(json ?? "json empty")
                                        var msg =  json["error"].stringValue
                                        //                            msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                                        self.showAlert(with: msg)
                                    }
                                    
                                    
                                }
                                
                            }else {
                                print("invald json :(")
                                
                            }
                            
                        }
                         
                    }
                }
            })
        }
    }
    func SignUPFaceBook()
    {
        
        API.signUpFaceBook(firstname: self.sFirstName, lastName: self.sLastName, email: self.sEmailId, mobile: "", countryCode: "", currency: "USD", timezone: TimeZone.current.identifier, password: "", gender: "",socialId:self.sSocialUniqueId) { json, error in
            
            
            if let error = error {
                self.showAlert(with :error.localizedDescription)
                // print(error.debugDescription)
                
                return
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].stringValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status == "false"){
                        self.hideLoader()
                        print(statusMessage)
                        print(json ?? "json empty")
                    }
                    else{
                        
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
                        defaults.set(json[Const.Params.REFERRAL_CODE].stringValue, forKey: Const.Params.REFERRAL_CODE)
                        defaults.set(json[Const.Params.REFERRAL_BONUS].stringValue, forKey: Const.Params.REFERRAL_BONUS)
                        defaults.set(json[Const.Params.CURRENCEY].stringValue, forKey: Const.Params.CURRENCEY)
                        defaults.set(json[Const.Params.GENDER].stringValue, forKey: Const.Params.GENDER)
                        defaults.set(json[Const.Params.EMAIL].stringValue, forKey: Const.Params.EMAIL)
                        defaults.set(json[Const.Params.PHONE].stringValue, forKey: Const.Params.PHONE)
                        defaults.set(json[Const.Params.TIMEZONE].stringValue, forKey: Const.Params.TIMEZONE)
                        defaults.set(json[Const.Params.PICTURE].stringValue, forKey: Const.Params.PICTURE)
                        defaults.set(json[Const.Params.LOGIN_BY].stringValue, forKey: Const.Params.LOGIN_BY)
                        defaults.set(json[Const.Params.COUNTRY].stringValue, forKey: Const.Params.COUNTRY)
                        defaults.set(json[Const.Params.WALLET_BAY_KEY].stringValue, forKey: Const.Params.WALLET_BAY_KEY)
                        defaults.set(json[Const.Params.PAYMENT_MODE_STATUS].stringValue, forKey: Const.Params.PAYMENT_MODE_STATUS)
                        
                        print("LOGIN SUCCESS GOING TO MAIN")
                        self.goToDashboard()
                        //                self.hideLoader()
                    }
                    
                    
                }else {
                    
                    print("invalid json :(")
                    
                }
            }
            
            
            
            
            
        }
    }
    func goToDashboard(){
        //        self.viewLoaded()
        self.hideLoader()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController")
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    @IBAction func googleLoginActionMethod(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    func methodOfReceivedNotification(notification: Notification){
        
        
        let defaults = UserDefaults.standard
        
        if self.isBoolGoogleCalled  {
            print("no value")
        }else {
            
            if notification.userInfo == nil {
                self.hideLoader()
                return
            }
            else {
                let googleJson = self.jsonParser.jsonParser(dicData: notification.userInfo! as! [String : AnyObject])
                
                self.sUserName = googleJson["givenName"].string!
                self.sEmailId = googleJson["email"].string!
                self.sSocialUniqueId = googleJson["userId"].string!
                //self.sPictureUrl = "https://graph.facebook.com/" + self.sSocialUniqueId + "/picture?type=large"
                
                let fullName    = googleJson["fullName"].string!
                let fullNameArr = fullName.components(separatedBy: " ")
                
                self.sFirstName    = fullNameArr[0]
                self.sLastName = fullNameArr[1]
                
                self.showLoader( str: "Signing In")
                
                defaults.removeObject(forKey: Const.Params.ID)
                defaults.removeObject(forKey: Const.Params.TOKEN)
                
                NotificationCenter.default.removeObserver(self)
                
                API.signInWithGoogle(socialId: self.sSocialUniqueId){ json, error in
                    if let error = error {
                        self.hideLoader()
                        self.showAlert(with :error.localizedDescription)
                        //print(error.debugDescription)
                        print(error)
                        return
                    }
                    else {
                        if let json = json {
                            
                            self.isBoolGoogleCalled = true
                            let status = json[Const.STATUS_CODE].boolValue
                            let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                            if(status){
                                
                                print("Full Login JSON")
                                print(json ?? "json null")
                                print(json["response"]["_id"].stringValue)
                                print(json["response"]["name"].stringValue)
                                print(json["response"]["mobile"].stringValue)
                                print(json["response"]["token"].stringValue)
                                
                                
                                defaults.set(json[Const.Params.ID].stringValue, forKey: Const.Params.ID)
                                defaults.set(json[Const.Params.TOKEN].stringValue, forKey: Const.Params.TOKEN)
                                defaults.set(self.sFirstName, forKey: Const.Params.FIRSTNAME)
                                defaults.set(self.sLastName, forKey: Const.Params.LAST_NAME)
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
                                self.goToDashboard()
                               
                                print("LOGIN SUCCESS GOING TO MAIN")
                                
                            }
                            else
                            {
                                if (json["error_code"].stringValue == "125")
                                {
                                    
                                    self.SignUPGoogle()
                                    
                                }
                                else
                                    
                                {
                                    self.hideLoader()
                                    
                                    print(statusMessage)
                                    print(json ?? "json empty")
                                    var msg =  json["error"].stringValue
                                    //                            msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                                    self.showAlert(with: msg)
                                }
                                
                            }
                           
                        }else {
                            debugPrint("invalid json :(")
                        }
                    }
                    
                    
                }
                
            }
        }
        
    }
    func SignUPGoogle()
    {
        API.signUpGoogle(firstname: self.sFirstName, lastName: self.sLastName, email: self.sEmailId, mobile: "", countryCode: "", currency: "USD", timezone: TimeZone.current.identifier, password: "", gender: "",socialId:self.sSocialUniqueId) { json, error in
            
            if let error = error {
                self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                //  print(error.debugDescription)
                return
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].stringValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status == "false"){
                        self.hideLoader()
                        print(statusMessage)
                        print(json)
                    }
                    else{
                        
                        print("Full Login JSON")
                        print(json )
                        
                        
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
                        
                        
                        
                        print("LOGIN SUCCESS GOING TO MAIN")
                        self.goToDashboard()
                        self.hideLoader()
                    }
                    
                }else {
                    print("invalid json :(")
                    
                }
                
                
            }
            
            print(json)
            
            
        }
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

