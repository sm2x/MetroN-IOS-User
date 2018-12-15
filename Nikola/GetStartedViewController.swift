//
//  GetStartedViewController
//  Nikola
//
//  Created by Sutharshan on 5/22/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import Crashlytics


class GetStartedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()



        // Do any additional setup after loading the view, typically from a nib.
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         UserDefaults.standard.set(false, forKey: "loggedIn")
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.isStatusBarHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//        UIApplication.shared.isStatusBarHidden = false
        
    }
    
    @IBAction func getStartedBtn(_ sender: UIButton) {
        let user_defaults = UserDefaults.standard
        let userId = user_defaults.string(forKey: Const.Params.ID)
        
        
        
         if let devicetoken = UserDefaults.standard.string(forKey: "deviceToken") {
            
            print(devicetoken)
       
        }
         else {
            
            
             DATA().putDeviceToken(data: "sdljf234001")
            
            print("no devicetoken")
            
        }
        
        
        
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "MobileNumberValVC") as! MobileNumberValidationVC
//        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)

        
        //let mobileVerified = user_defaults.string(forKey: Const.MOBILE_VERIFIED)
        
//        if (userId ?? "").isEmpty  {
//            goToSignIn()
//        }else{
//            goToDashboard()
//        }        
    }
    func goToSignIn(){        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
        
    }

    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
//        self.present(secondViewController, animated: true, completion: nil)
        
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}

