//
//  NextEmailVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 8/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
//import Material
class NextEmailVC: BaseViewController,UITextFieldDelegate {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var nextbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

         self.setupNavigationBar(with: "Sign Up")
        
        txtEmail.delegate = self
        txtEmail.setBottomBorder()
        
        self.setupNavigationBar(with: "Sign Up".localized())
        txtEmail.placeholder = "Email Id".localized()
        nextbtn.setTitle("NEXT".localized(), for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    

    
    func navigationMethod() {
        
        
        UserDefaults.standard.set(self.txtEmail.text!, forKey: "user_Email")
       
        
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FinalVC") as! FinalVC
        self.navigationController?.pushViewController(myVC, animated: true)
        
    }
    
    
    @IBAction func nextButtonActionMethod(_ sender: Any) {
        
        if (txtEmail.text?.isEmpty)! || !isValidEmailAddress(emailAddressString: txtEmail.text!){
            self.showAlert(with: "Please Enter Valid Email Id")
//            txtEmail.errorMessage = "Please Enter Valid Email Id"
           
        }

        else {
//            txtEmail.errorMessage = nil
            navigationMethod()
        }
        
        
    }
   
}
//extension NextEmailVC: TextFieldDelegate {
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

