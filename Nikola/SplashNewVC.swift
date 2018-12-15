//
//  SplashNewVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 05/01/18.
//  Copyright © 2018 Nikola. All rights reserved.
//

import UIKit

class SplashNewVC: UIViewController {
    
    @IBOutlet weak var view1: UIView!
    
    
    lazy var timer : Timer? = nil
    private lazy var width: CGFloat? = nil
    private lazy var height: CGFloat? = nil
    
    private lazy var topView: UIView? = nil
    private lazy var bottomView: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = self.view.frame.size.width
        height = self.view.frame.size.height/2

        topView = CarAnimView(frame: CGRect(x: self.view.frame.size.width/2 - width!/2, y: self.view.frame.size.height/4 - height!/2, width: width!, height:height!))
       bottomView = CarAnimView(frame: CGRect(x: self.view.frame.size.width/2 - width!/2, y: self.view.frame.size.height/2, width: width!, height:height!))


        self.view1.addSubview(topView!)
        self.view1.addSubview(bottomView!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.timer = Timer.scheduledTimer(timeInterval:  2.0, target: self,  selector: #selector(navigationMethod), userInfo: nil, repeats: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer = nil
        topView = nil
        bottomView = nil
        width = nil
        height = nil
    }
    
    func navigationMethod() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        
        var signInViewController: UIViewController
        
        signInViewController = storyboard.instantiateViewController(withIdentifier: "GetStartedNavigationController")
        
        
        if UserDefaults.standard.bool(forKey: "loggedIn") {
            
            self.present(mainViewController, animated: true, completion: nil)
            
        }
        else {
            
            
            self.present(signInViewController, animated: true, completion: nil)
            
        }
    }
    
}
