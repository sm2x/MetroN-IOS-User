//
//  NKDirectTopUpTornViewController.swift
//  Nikola
//
//  Created by Vinitha on 06/12/18.
//  Copyright © 2018 Nikola. All rights reserved.
//

import UIKit

class NKDirectTopUpTornViewController: BaseViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var imgQRCode: UIImageView!
    
    @IBOutlet weak var lblTornAddress: UILabel!
    
    @IBOutlet weak var txtAmount: UITextField!
    
    @IBOutlet weak var lblAmountValue: UILabel!
    
    @IBOutlet weak var lblCurrentValue: UILabel!
    
    
    @IBOutlet weak var btndone: UIButton!
    
    
    var usdToReceive = 0.0
    var fiatWithdrawFee = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()

         let defaults = UserDefaults.standard
        
           let id : String = defaults.string(forKey: Const.Torn_Wallet_Address)!
        
        btndone.layer.cornerRadius = 10
        btndone.layer.masksToBounds = true
        
        let image = generateQRCode(from: id)
        imgQRCode.image = image
        lblTornAddress.text = id
        let currentValue :String  = defaults.string(forKey: Const.Torn_Current_value)!
        lblCurrentValue.text = "$ \(currentValue)"
        self.fiatWithdrawFee = (currentValue as NSString).doubleValue
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func generateQRCode(from string: String) -> UIImage? {
//        self.showLoader(str: "Generating", details: "Please wait")
        self.showLoader(str: "Generating")
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                self.hideLoader()
                return UIImage(ciImage: output)
            }
        }
        self.hideLoader()
        return nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    @IBAction func btnBackPressed(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func btnDonepressed(_ sender: Any) {
        if (txtAmount.text?.isEmpty)! {
            
            print("empty")
            self.showAlert(with: "please Enter Amount")
            
        }
        else
        {
            self.showPopupDialog()
        }
//        else {
//            self.showLoader(str: "Loading...")
//            API.TornWalletAddBalance(Amount:txtAmount.text!) { responseObject, error in
//
//                if responseObject == nil {
//                    self.hideLoader()
//                    return
//                }
//                else {
//
//                    let json = self.jsonParser.jsonParser(dicData: responseObject)
//
//                    let status = json[Const.STATUS_CODE].boolValue
//                    print(json)
//
//                    //                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
//                    if(status){
//                        print(json)
//
////                        let data  = json["wallet"].dictionary
//
////                        let user_Balance : String = (json["balance"].stringValue)
////
////                        let myString = "TRX "
////                        let  myAttrString = NSMutableAttributedString(string: myString, attributes: [ NSForegroundColorAttributeName: UIColor.white ])
////                        let My_user_Balance = NSAttributedString(string: user_Balance, attributes: [ NSForegroundColorAttributeName: UIColor.black ])
////
////                        // set attributed text on a UILabel
////                        //                    .attributedText = myAttrString
////
////                        myAttrString.append(My_user_Balance)
////                        self.lblWalletMoney.attributedText = myAttrString
////                        self.lblTornAddress.text = data!["address_base58"]?.stringValue
////                        self.lblCurrentValue.text = "$ \(json["market_price"].stringValue)"
////                        self.fiatWithdrawFee = json["market_price"].doubleValue
//
//
//                        self.hideLoader()
//
//                    }
//                    else {
//                        self.hideLoader()
//                        let msg = json["error_messages"].stringValue
////                        self.showAlert(with: msg)
//                        self.showPopupDialog()
//
//                    }
//
//
//                }
//
//
//
//
//
//
//            }
//
//
//        }
        
    }
    
    func showPopupDialog()
    {
      
        let alert = UIAlertController(title: "", message: "TRX deposits may take a while to reflet in your wallet( this is normal). Atleast 19 network  confirmations are reqired. Please try hitting the refresh button in the tron wallet screen (Present pn top right corner )", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(
        title: "Ok", style: UIAlertActionStyle.default) { (action) in
            self.gotoWallet()
        }
        
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func gotoWallet()
    {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                self.navigationController?.pushViewController(myVC, animated: true)
//        self.present(myVC, animated: true, completion: nil)
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
                self.lblAmountValue.text = "TRX \(self.usdToReceive)"
            }
            else
            {
                self.lblAmountValue.text = "TRX 0"
            }
            //}
        }
        
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
