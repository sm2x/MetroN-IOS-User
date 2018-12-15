//
//  SidemenuNavigationViewController.swift
//  Alicia
//
//  Created by Sutharshan on 5/12/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import BraintreeDropIn
import Braintree


class SidemenuNavigationViewController: UITableViewController {
    
    var menu = ["SideMenuTopCell","Home","Add Payment Options","Torn wallet","Ride History", "Your scheduled rides", "Rentals","Airport ride booking", "Refer and Earn","Help", "Logout"]
      var hud : MBProgressHUD = MBProgressHUD()
//    @IBOutlet weak var profileImage: UIImageView!
//    @IBOutlet weak var userName: UILabel!
//   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 200.0;//Choose your custom row height
        }else {
            return tableView.rowHeight
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cellIdentifier = menu[indexPath.row]
        
        if indexPath.row == 0 {
            let cell: SideMenuTopCell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTopCell", for: indexPath) as! SideMenuTopCell
//            cell.imgView.setRandomDownloadImage(128, height: 128)
//            cell.lblName.text = "Sutharshan"
            return cell
        }else
        {
            let cellIdentifier = menu[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        return cell
        }
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        
//        return cell
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue .isKind(of: SWRevealViewControllerSeguePushController.self()){
//            
//            let swSegue = segue as! SWRevealViewControllerSeguePushController
//            
//        }
//    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        switch indexPath.row
        {
//        case 0:
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DummyDashViewController") as? DummyDashViewController
//            let navController = UINavigationController(rootViewController: secondViewController!)
//            navController.setViewControllers([secondViewController!], animated:true)
//            self.revealViewController().pushFrontViewController(navController, animated: false)
//            ////self.revealViewController.pushFrontViewController:navController animated:YES];
//            break;
//            
//        case 1:
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DummyDashViewController") as? DummyDashViewController
//            let navController = UINavigationController(rootViewController: secondViewController!)
//            navController.setViewControllers([secondViewController!], animated:true)
//            self.revealViewController().pushFrontViewController(navController, animated: false)
//            
//            break;
        case 1:
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
//            self.present(secondViewController!, animated: true, completion: nil)
            break
        case 2:
            getBrainTreeClientToken()
        case 7:
            self.revealViewController().revealToggle(animated: true)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "referSBID") as? ReferandEarnViewController
                    self.present(secondViewController!, animated: true, completion: nil)
            break;
        case 10:
            
            self.revealViewController().revealToggle(animated: true)
            
            let refreshAlert = UIAlertController(title: "Logout".localized(), message: "Are sure you want to logout.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { (action: UIAlertAction!) in
                
               self.logoutUser()
                print("Handle Ok logic here")
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
            break
        default:
            break;
            
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        
//        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
//        profileImage.clipsToBounds = true
//        
//    }
    
    func getBrainTreeClientToken(){
        
        //let phone : String = self.countryCodeString + self.mobileTextField.text!
        
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
                    //                    self.codeString = otp
                    
                    //BTPaymentRequest.init().clientto
                    print(json ?? "error in getBrainTreeClientToken json")
                    //self.goToDashboard()
                    
                    self.showDropIn(clientTokenOrTokenizationKey: clientToken)
                    
                    //self.view.makeToast(message: "OTP Resent. Please enter the new OTP")
                    
                }else{
                    print(statusMessage)
                    print(json ?? "getBrainTreeClientToken json empty")
                    var msg = json![Const.ERROR].rawString()!
                    msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                    self.view.makeToast(message: msg)
                }
            }
        }
    }
    func logoutUser(){
        
        
        API.userLogout{ json, error in
            
            if json == nil {
                print("json nil")
                //self.hideLoader()
                print(error?.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    let defaults = UserDefaults.standard
                    
                    defaults.set(false, forKey: "isloggedin")
                    
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    
                    let queue = DispatchQueue(label: "com.prov.nikola.timer2")  // you can also use
                    //            queue.suspend()
                    
                    
                    if Const.nikola {
                        
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedNavigationController") //as! GetStartedNavigationController
                        self.present(nextViewController, animated: true, completion: nil)
                    }else {
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedRideyNavigationController")// as! GetStartedRideyNavigationController
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                    
                }
                return
            }
            
            let status = json![Const.STATUS_CODE].boolValue
            let statusMessage = json![Const.STATUS_MESSAGE].stringValue
            if(status){
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    let defaults = UserDefaults.standard
                    
                    defaults.set(false, forKey: "isloggedin")
                    
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    
                    let queue = DispatchQueue(label: "com.prov.nikola.timer2")  // you can also use
                    //            queue.suspend()
                    
                    
                    if Const.nikola {
                        
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedNavigationController") //as! GetStartedNavigationController
                        self.present(nextViewController, animated: true, completion: nil)
                    }else {
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedRideyNavigationController")// as! GetStartedRideyNavigationController
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                    
                }
            }else{
                print(statusMessage)
                self.hideLoader()
                print(json ?? "json empty")
                var msg = json![Const.ERROR].rawString()!
                self.view.makeToast(message: msg)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    let defaults = UserDefaults.standard
                    
                    defaults.set(false, forKey: "isloggedin")
                    
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    
                    let queue = DispatchQueue(label: "com.prov.nikola.timer2")  // you can also use
                    //            queue.suspend()
                    
                    
                    if Const.nikola {
                        
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedNavigationController") //as! GetStartedNavigationController
                        self.present(nextViewController, animated: true, completion: nil)
                    }else {
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedRideyNavigationController")// as! GetStartedRideyNavigationController
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                    
                }
            }
        }
        
    }

    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                let selectedPaymentOptionType = result.paymentOptionType
                let selectedPaymentMethod = result.paymentMethod
                let selectedPaymentMethodIcon = result.paymentIcon
                let selectedPaymentMethodDescription = result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        //self.present(dropIn!, animated: true, completion: nil)
        dropIn?.showCardForm(self)
    }

    
}
extension SidemenuNavigationViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            hud = MBProgressHUD.showAdded(to:window, animated: true)
            hud.mode = MBProgressHUDModeIndeterminate
            hud.labelText = str
        }
        //        let window = overKeyboard ? UIApplication.sharedApplication().windows.last!
        //            : UIApplication.sharedApplication().delegate!.window!
        
    }
    
    func hideLoader() {
        hud.hide(true)
    }
}
