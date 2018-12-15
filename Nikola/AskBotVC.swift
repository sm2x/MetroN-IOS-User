//
//  AskBotVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 9/4/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit

class AskBotVC: BaseViewController,UIWebViewDelegate {

  
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }

        
        
        let defaults = UserDefaults.standard
    
        let token: String = defaults.string(forKey: Const.Params.ID)!
        let sessionToken: String = defaults.string(forKey: Const.Params.TOKEN)!
        
        let str : String = "http://prevue.info/web-view/?token=\(token)&session_token=\(sessionToken)"
        
        print(str)  
        
        self.showLoader(str: "Loading bot please wait...")
        
        webView.delegate = self
        
        let url = URL (string:str)
        let requestObj = URLRequest(url: url!);
        self.webView.loadRequest(requestObj)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        webView.scrollView.contentInset = UIEdgeInsets.zero;
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        
        self.hideLoader()
        
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
