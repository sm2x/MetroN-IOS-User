//
//  WalletVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 9/29/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import Stripe

protocol paymentconfimationprotocaldelegate {
    
    func paymentconfimationmethod()
    
}
protocol stripepaymentshowdelegate {
   
    func stripepaymentVCShow()
    
}


class WalletVC: BaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    
    @IBOutlet weak var lblWalletMoney: UILabel!
    
    var isBackBoolVal : Bool?
    
    @IBOutlet weak var lblYouget: UILabel!
    
    @IBOutlet weak var lblTRXValueGet: UILabel!
    
    @IBOutlet weak var lblDescCurrentMarket: UILabel!
    
    @IBOutlet weak var lblCurrentValue: UILabel!
    
    @IBOutlet weak var lblTornAddress: UILabel!
    
    
    @IBOutlet weak var btnHere: UIButton!
    
    
    @IBOutlet weak var BtnBookaCab: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    
     var usdToReceive = 0.0
    var fiatWithdrawFee = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
        
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        if let boolValue = isBackBoolVal {
            if boolValue == true {
                
                burgerMenu.image = UIImage(named: "blackBackIcon")
            }
            else {
                burgerMenu.image = UIImage(named: "Burger")
                
            }

        }
        else {
            burgerMenu.image = UIImage(named: "Burger")
        }

        txtAmount.delegate = self
        
        txtAmount.layer.masksToBounds = false
        txtAmount.layer.shadowRadius = 1.0
        txtAmount.layer.shadowColor = UIColor.black.cgColor
        txtAmount.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtAmount.layer.shadowOpacity = 1.0
        
        
        self.getBalance()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(WalletVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(WalletVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.bgView.frame.origin.y == 0{
                self.bgView.frame.origin.y -= 50
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.bgView.frame.origin.y != 0{
                self.bgView.frame.origin.y += 50
            }
        }
    }
    
    func backButton(sender: Any) {
        
        
        revealViewController().revealToggle(sender)
        
        
        
    }
    
    func backNewMethod(sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtAmount
        {
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            let components = string.components(separatedBy: inverseSet)
            
            let filtered = components.joined(separator: "")
            
            if filtered == string {
                let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
                typingName(textField: textField,str:updatedString!)
                return true
            } else {
                if string == "." {
                    let countdots = textField.text!.components(separatedBy:".").count - 1
                    if countdots == 0 {
                        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
                        typingName(textField: textField,str:updatedString!)
                        return true
                    }else{
                        if countdots > 0 && string == "." {
                            return false
                        } else {
                            let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
                            typingName(textField: textField,str:updatedString!)
                            return true
                        }
                    }
                }else{
                    return false
                }
            }
        }
        return true
    }
    
    func typingName(textField:UITextField,str:String){
        if textField == txtAmount
        {
            let typedText = str //{
            let tempName = typedText
            if tempName != "" && self.txtAmount.text! != "." && tempName != "."
            {
                var amount = Double(tempName)!
                amount = Double(tempName)!
                self.usdToReceive = amount / self.fiatWithdrawFee
                
//                self.lblUSDToReceive.text = "TRX \(self.usdToReceive.rounded(toPlaces: 2))"
                self.lblTRXValueGet.text = "TRX \(self.usdToReceive)"
            }
            else
            {
                self.lblTRXValueGet.text = "TRX 0"
            }
            //}
        }
        
    }
    
    
    
    
    func getBalance() {
        self.showLoader(str: "fetching your balance")
        
        API.TornWalletBalance() { responseObject, error in
            
            
            if responseObject == nil {
                self.hideLoader()
                return
            }
            else {
                
                let json = self.jsonParser.jsonParser(dicData: responseObject)
                
                let status = json[Const.STATUS_CODE].boolValue
                print(json)
                
                //                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                if(status){
                    
                    let data  = json["wallet"].dictionary
                    
                    let user_Balance : String = (json["balance"].stringValue)
                    
                    let myString = "TRX "
                    let  myAttrString = NSMutableAttributedString(string: myString, attributes: [ NSForegroundColorAttributeName: UIColor.white ])
                    let My_user_Balance = NSAttributedString(string: user_Balance, attributes: [ NSForegroundColorAttributeName: UIColor.black ])
                    
                    // set attributed text on a UILabel
//                    .attributedText = myAttrString
                    
                    myAttrString.append(My_user_Balance)
                    self.lblWalletMoney.attributedText = myAttrString
                    self.lblTornAddress.text = data!["address_base58"]?.stringValue
                    self.lblCurrentValue.text = "$ \(json["market_price"].stringValue)"
                    self.fiatWithdrawFee = json["market_price"].doubleValue
                    
                    
                    self.hideLoader()
                    
                }
                else {
                    self.hideLoader()
                    var msg = json["text"].rawString() ?? "Something went worng"
                    
                    self.showAlert(with: msg)
                }
                
                
            }
            
            
            
            
            
            
        }
        
        
    }
    
    @IBAction func firstMoneyButtonAction(_ sender: Any) {
        
        txtAmount.text = "  200"
        
    }
    
    
    @IBAction func secondMoneyButtonAction(_ sender: Any) {
        
        txtAmount.text = "  500"
        
    }
    
    
    @IBAction func thirdMoneyButtionAction(_ sender: Any) {
        
        txtAmount.text = "  1000"
        
    }
    
    @IBAction func BackActionMethod(_ sender: Any) {
        
        if let boolValue = isBackBoolVal {
            if boolValue == true {
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }else {
                revealViewController().revealToggle(sender)
            }
  
        }else {
            revealViewController().revealToggle(sender)
        }
       
 
    }
    
    
    @IBAction func btnHerePressed(_ sender: Any) {
        
//        live :  https://tronscan.org/#/address/ "append address here"
//        test:  https://explorer.shasta.trongrid.io/address/ "append address here"
        
        let url = URL(string: "https://explorer.shasta.trongrid.io/address/\(self.lblTornAddress.text!)")
        print(url)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url!, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
        
        
        
    }
    
    @IBAction func btnBookAcabPressed(_ sender: Any) {
        if let boolValue = isBackBoolVal {
            if boolValue == true {
                self.navigationController?.popViewController(animated: true)
            }else {
              goToDashboard()
            }
            
        }else {
           goToDashboard()
        }
        
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    @IBAction func btnRefreshPressed(_ sender: Any) {
        getBalance()
    }
    
    @IBAction func addAmountButtonAction(_ sender: Any) {
        
        if (txtAmount.text?.isEmpty)! {
            
            print("empty")
            self.showAlert(with: "please Enter Amount")
            
        }
        else {
            
//            self.showLoader(str: "Please wait")
//
//            API.walletPaymentgateType() { [weak self] responseObject, error in
//
//                if responseObject == nil {
//                    self?.hideLoader()
//                    self?.showAlert(with: (error?.localizedDescription)!)
//                    return
//                }
//                else {
//                        let json = self?.jsonParser.jsonParser(dicData: responseObject)
//                if let json = json {
//                        let status = json[Const.STATUS_CODE].boolValue
//                        let statusMessage = json[Const.STATUS_MESSAGE].stringValue
//                        if(status){
//                            print(json)
//                            let str : String = (self?.txtAmount.text!)!
//                            let trimmedString = str.trimmingCharacters(in: .whitespaces)
//
//                            let val : Int = Int(trimmedString)!
//
//                            print(val)
//
//                            self?.hideLoader()
//                            let gateways = json["data"].dictionary
//                            guard let array = (gateways!["gateways"]?.array), array.count > 0 else {
//                                self?.showAlert(with: "No Wallet Gateway found! Please Configure Payment Gateway from dashboard.")
//                                return
//                            }
//
//
//                            let popOverVC: WalletPaymentGateType   = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletPaymentGateTypeVC") as? WalletPaymentGateType)!
//
//                            popOverVC.walletPaymentGatewayTypeArray = responseObject
//                            popOverVC.walletMoney = val
//                            popOverVC.delegate = self
//                            popOverVC.delegatestripe = self
//                            popOverVC.view.frame = CGRect(x: 0, y: 0, width: (self?.view.frame.width)!, height: (self?.view.frame.height)! + 70)
//
//
//                            //
//                            popOverVC.willMove(toParentViewController: self)
//                            self?.view.addSubview(popOverVC.view)
//                            self?.addChildViewController(popOverVC)
//                            popOverVC.didMove(toParentViewController: self)
//
//                            // UIApplication.shared.keyWindow?.addSubview(popOverVC.view)
//
//                        }
//                        else {
//
//                            print(statusMessage)
//
//
//                            self?.hideLoader()
//
//                            if let msg = json["text"].rawString() {
//                                self?.showAlert(with: msg)
//                            }
//
//                        }
//                    }
//                }
//            }
            
            
          gotoAddpayment()
            
        }
        print("no empty")
        
        
    }
    func gotoAddpayment()
    {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController
//        let navController = UINavigationController(rootViewController: secondViewController!)
//        navController.setViewControllers([secondViewController!], animated:true)
        self.revealViewController().pushFrontViewController(secondViewController, animated: false)
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

extension WalletVC : stripepaymentshowdelegate {
    
    func stripepaymentVCShow() {
        let str : String = self.txtAmount.text!
        
        let trimmedString = str.trimmingCharacters(in: .whitespaces)
        
        
        
                    let popOverVC: NKStripeVC   = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NKStripeVC") as? NKStripeVC)!
        
        
                    popOverVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + 70)
        
                    popOverVC.walletmoney = trimmedString
                    popOverVC.delegate = self
                    popOverVC.willMove(toParentViewController: self)
                    self.view.addSubview(popOverVC.view)
                    self.addChildViewController(popOverVC)
                    popOverVC.didMove(toParentViewController: self)
        
    }
}

extension WalletVC : paymentconfimationprotocaldelegate {
    
    func paymentconfimationmethod() {
        
        if let boolValue = isBackBoolVal {
            if boolValue == true {
                 self.dismiss(animated: true, completion: nil)
            }else {
                self.getBalance()
            }
        }else {
            self.getBalance()
        }
        
        
    }
    
}

