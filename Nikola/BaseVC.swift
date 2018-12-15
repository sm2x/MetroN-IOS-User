//
//  BaseVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 8/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import Localize_Swift

class BaseViewController: UIViewController {
    
     var hud : MBProgressHUD = MBProgressHUD()
     var jsonParser = JsonParser()
     public let availableLanguages = Localize.availableLanguages()
    func setupNavigationBar(with tittle: String) {
        
        self.title = tittle
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "backArrow"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(BaseViewController.btnBackActionMethod), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        
        self.navigationItem.setLeftBarButton(item1, animated: true)
        
    }
    
    func homeNavigationBarSetup(with tittle: String) {
        
        self.title = tittle
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Burger"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
             btn1.addTarget(self, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        
        self.navigationItem.setLeftBarButton(item1, animated: true)

        
        
    }
    
    
    
    func btnBackActionMethod(sender: Any) {
        
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    func slideMenuActionMethod(sender: Any){
        
    }
    
 

}



extension BaseViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }


}


