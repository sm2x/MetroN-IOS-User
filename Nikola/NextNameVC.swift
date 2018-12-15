//
//  NextNameVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 8/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
//import Material

class NextNameVC: BaseViewController,UITextFieldDelegate  {

    
    
    @IBOutlet weak var txtFirstName: UITextField!
    
    @IBOutlet weak var txtLastName: UITextField!
     @IBOutlet weak var nextbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.setupNavigationBar(with: "Sign Up".localized())
        txtFirstName.placeholder = "First Name".localized()
        txtLastName.placeholder = "Last Name".localized()
        nextbtn.setTitle("NEXT".localized(), for: .normal)
        
        txtFirstName.delegate = self
        txtFirstName.tag = 0
        
        
        txtLastName.delegate = self
        txtLastName.tag = 1

        txtLastName.setBottomBorder()
        txtFirstName.setBottomBorder()
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

 
    func navigationMethod() {
        
        UserDefaults.standard.set(self.txtFirstName.text!, forKey: "user_FirstName")
        UserDefaults.standard.set(self.txtLastName.text!, forKey: "user_LastName")
        
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "NextEmailVC") as! NextEmailVC
        self.navigationController?.pushViewController(myVC, animated: true)
    }

    
    
    
    @IBAction func nextButtonActionMethod(_ sender: Any) {
        
        
        if (txtFirstName.text?.isEmpty)! {
            
            self.showAlert(with: "Please Enter the First Name")
//            txtFirstName.errorMessage = "Please Enter the First Name"
        }else if(txtLastName.text?.isEmpty)!  {
            self.showAlert(with: "Please Enter the Last Name")
//            txtFirstName.errorMessage = nil
//            txtLastName.errorMessage = "Please Enter the Last Name"
        }
        else {
              navigationMethod()
        }
        
        
    }
    
    
    
}

//extension NextNameVC: TextFieldDelegate {
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        (textField as? ErrorTextField)?.isErrorRevealed = false
//    }
//    
//    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        (textField as? ErrorTextField)?.isErrorRevealed = false
//        return true
//    }
//    
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        (textField as? ErrorTextField)?.isErrorRevealed = false
//        return true
//    }
//}



