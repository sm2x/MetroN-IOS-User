//
//  GetStartedRideyViewController.swift
//  Nikola
//
//  Created by Sutharshan Ram on 21/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class GetStartedRideyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwindToGetStartedRideyViewController(segue:UIStoryboardSegue) { }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.isStatusBarHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
