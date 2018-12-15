//
//  HelpViewController.swift
//  Nikola
//
//  Created by Sutharshan on 7/19/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class HelpViewController: BaseViewController,UIWebViewDelegate {
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    var urlPassed = ""
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if revealViewController() != nil {
//            
//            burgerMenu.target = revealViewController()
//            burgerMenu.action = "revealToggle:"
//            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//        }
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Burger"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(HelpViewController.backButton), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        self.navItem.setLeftBarButton(item1, animated: true)
        
        
        self.navBar.tintColor = UIColor.darkGray
        
        self.showLoader(str: "Please wait...")
        
        webView.delegate = self
        
        let url = URL (string: Const.Url.HOST_URL)
        let requestObj = URLRequest(url: url!);
        self.webView.loadRequest(requestObj)
    }
    
    
    func backButton(sender: Any) {
        
        
        revealViewController().revealToggle(sender)
        
        
        
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
    
    
}
