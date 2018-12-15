//
//  RequestAnimationViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/31/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class RequestAnimationViewController: UIViewController  {
    
    
    @IBOutlet weak var buttonBottomSpaceConstrans: NSLayoutConstraint!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    var activityIndicatorView: NVActivityIndicatorView? = nil
    
    var isViewTypeHour : Bool!
    
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        let cellWidth = Int(self.view.frame.width)
        let cellHeight = Int(self.view.frame.height)

        
            let x = 0//Int(self.view.frame.size.width/2)
            let y = 0//Int(self.view.frame.size.height/2)
        
            let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
            activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                type: NVActivityIndicatorType.ballScaleMultiple)
        
        
        
            
            activityIndicatorView?.color = UIColor(red:0.22, green:0.61, blue:0.68, alpha:1.0)
            let animationTypeLabel = UILabel()//UILabel(frame: frame)
        
        statusLabel.text = "Requesting...".localized()
            animationTypeLabel.text = "Requesting...".localized()
            animationTypeLabel.sizeToFit()
            animationTypeLabel.textColor = UIColor.white
            //animationTypeLabel.frame.origin.x += self.view.frame.width/2
            //animationTypeLabel.frame.origin.y += CGFloat(cellHeight/2) - animationTypeLabel.frame.size.height
            
            activityIndicatorView?.padding = 20
//            if $0 == NVActivityIndicatorType.orbit.rawValue {
//                activityIndicatorView.padding = 0
//            }
            self.view.addSubview(activityIndicatorView!)
            self.view.addSubview(animationTypeLabel)
        
        
        
            activityIndicatorView?.startAnimating()
        //startAnimating()
            
//            let button: UIButton = UIButton(frame: frame)
//            button.tag = 1
//            button.addTarget(self,
//                             action: #selector(buttonTapped(_:)),
//                             for: UIControlEvents.touchUpInside)
//            self.view.addSubview(button)
        
           self.view.bringSubview(toFront: carImage)
            self.view.bringSubview(toFront: cancelBtn)
        

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if UserDefaults.standard.bool(forKey: "viewHour") {
            
             buttonBottomSpaceConstrans.constant = 52.0
        }
        else {
            buttonBottomSpaceConstrans.constant = 4.0
        }

        
    }
    
    func buttonTapped(_ sender: UIButton) {
        let size = CGSize(width: 30, height: 30)
        
        //startAnimating(size, message: "Loading...", type: NVActivityIndicatorType(rawValue: sender.tag)!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
          //  self.stopAnimating()
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
            cancelCreatedRequest()
    }
    
    func cancelCreatedRequest(){
        
        statusLabel.text = "Cancelling...".localized()
        API.cancelCreateRequest{ json, error in
            //null error here fix it
            
            if let error = error {
                //self.hideLoader()
                 self.view.removeFromSuperview()
                 self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                    
                            DATA().clearRequestData()
                          print(json ?? "error in cancel created request json")
                                    //self.dismiss(animated: true, completion: nil)
                            self.activityIndicatorView?.stopAnimating()
                                    //self.presentedViewController?.dismiss(animated: true, completion: nil)
                    //                self.dismiss(animated: true, completion: nil)
                    //                self.removeFromParentViewController()
                    
                            self.view.removeFromSuperview()
                            self.statusLabel.text = "Cancelled".localized()
                        }else{
                            print(statusMessage)
                           print(json ?? "json empty")
                        
                        if let msg : String = json[Const.DATA].rawString() {
                            self.view.makeToast(message: msg)
                        }
                        

                        }
                    
                }else {
                    debugPrint("Invalid Json :(")
                    
                }
                
            }
            
            
//            if json != nil && (json?.exists())!{
//            let status = json![Const.STATUS_CODE].boolValue
//            let statusMessage = json![Const.STATUS_MESSAGE].stringValue
//            if(status){
//
//                DATA().clearRequestData()
//                print(json ?? "error in cancel created request json")
//                //self.dismiss(animated: true, completion: nil)
//                self.activityIndicatorView?.stopAnimating()
//                //self.presentedViewController?.dismiss(animated: true, completion: nil)
////                self.dismiss(animated: true, completion: nil)
////                self.removeFromParentViewController()
//
//                self.view.removeFromSuperview()
//                self.statusLabel.text = "Cancelled"
//            }else{
//                print(statusMessage)
//                print(json ?? "json empty")
//                var msg = json![Const.DATA].rawString()!
//                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
//                self.statusLabel.text = "Cancel Failed. Continuing "
////                self.view.makeToast(message: msg)
//            }
//            }
        }
    }

    
}
