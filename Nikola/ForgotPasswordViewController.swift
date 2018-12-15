//
//  ForgotPasswordViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/23/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
//import Material


class ForgotPasswordViewController :BaseViewController, UITextFieldDelegate {
                
    @IBOutlet weak var emailTextField: UITextField!
        
        var is_sentry: Bool! = false
        let loginAuto: Bool = false
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            self.setupNavigationBar(with: "Forgot Password")
            
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
            
            prepareEmailField()
            
            emailTextField.delegate = self
            emailTextField.setBottomBorder()
            emailTextField.tag = 0
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        @IBAction func requestPasswordAction(_ sender: UIButton) {
            self.showLoader(str: "Requesting Password")
            
            API.forgotPassword(email: emailTextField.text!){ json, error in
                
                if (error != nil) {
                    print(error.debugDescription)
                    self.view.makeToast(message: (error?.localizedDescription)!)
                }else{
                    if let json = json {
                        
                        let status = json[Const.STATUS_CODE].boolValue
                        let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                            if(status){
                                self.hideLoader()
                                print("Full Login JSON")
                                    print(json ?? "json null")
                                    self.view.makeToast(message: "Password Sent successfully to Registered Mail Id!")
                                    print("forgot password SUCCESS GOING TO MAIN")
                                                    //self.goToDashboard()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                                        self.goToSignIn()
                                            })
                        
                                }else{
                                
                                self.hideLoader()
                                    print(statusMessage)
                                    print(json ?? "json empty")
                                
                                if let msg : String = json["error"].stringValue {
                                     self.view.makeToast(message: msg)
                                    
                                }
                                
                                  //  var msg = try json!["error"].stringValue
                        
                                                  //  self.view.makeToast(message: msg)
                                }
                        
                    }
                    
                    

                }
            }
            
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
        
        
        
        func goToSignIn(){
            _ = navigationController?.popViewController(animated: true)
            
        }
        
        func goToDashboard(){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SignInNewViewController") as? UIViewController
            self.present(secondViewController!, animated: true, completion: nil)
        }
        
    }
    
    
extension ForgotPasswordViewController{
        fileprivate func prepareEmailField() {
            
            emailTextField.placeholder = "Email"
//            self.showAlert(with: "incorrect email")
//            emailTextField.errorMessage = "incorrect email"
//            emailTextField.retain = "Error, incorrect email"
//            emailTextField.isClearIconButtonEnabled = true
//            emailTextField.delegate = self
            
            // Set the colors for the emailField, different from the defaults.
            //        emailField.placeholderNormalColor = Color.amber.darken4
            //        emailField.placeholderActiveColor = Color.pink.base
            //        emailField.dividerNormalColor = Color.cyan.base
            //        emailField.dividerActiveColor = Color.green.base
            // Set the text inset
            //        emailField.textInset = 20
            
            //        let leftView = UIImageView()
            //        leftView.image = Icon.cm.audio
            //        emailField.leftView = leftView
            //view.layout(emailField).center().left(20).right(20)
            //view.layout(emailField).top(+100).left(20).right(20)
            //view.layout(emailField).center(offsetY: -passwordField.height - 60).left(20).right(20)
            
        }
        
}
