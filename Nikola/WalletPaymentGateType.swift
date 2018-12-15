//
//  WalletPaymentGateType.swift
//  Nikola
//
//  Created by sudharsan s on 04/11/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import Stripe

class WalletPaymentGateType: BaseViewController,PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate {

    
    @IBOutlet weak var tableview: UITableView!
    var walletPaymentGatewayTypeArray : [String : AnyObject]!
    var gatewayNameArray = [String]()
    
    var paypalKey : String = ""
    var paypalMode : Bool = false
    var payPalConfig = PayPalConfiguration()
    var walletMoney : Int!
    var delegate : paymentconfimationprotocaldelegate!
    var delegatestripe : stripepaymentshowdelegate!
    
    var stripekey : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        let json = self.jsonParser.jsonParser(dicData: walletPaymentGatewayTypeArray)
        
        let gateways = json["data"].dictionary
        
        let array = (gateways!["gateways"]?.array)!
        
        print(array)
        
        
        
        for  i in (0..<array.count){
            
           let data = array[i].dictionary

          
            
            let name : String = (data!["gateway_name"]?.string)!
            
            print(name)
            
            gatewayNameArray.append(name)
            
             let settings = data!["settings"]?.dictionary
            
            if  name == "PAYPAL" {
                
               
                
                paypalKey = (settings!["PAYPAL_CLIENT_ID"]?.string)!
                
                 paypalMode = (settings!["PAYPAL_LIVE_MODE"]?.bool)!
                
                print(settings ?? "settings")
                
            }
            if name == "STRIPE" {
                stripekey = (settings!["stripe_api_publishable_key"]?.string)!
                
                
            }

        }
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView()
        tableview.separatorStyle = .none
        tableview.reloadData()
      
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        self.view.addGestureRecognizer(tap)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        print("Hello World")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    func selectedPaymentMethod(sender: UIButton!) {
        
        
        print(gatewayNameArray[sender.tag])
        
        let name : String = gatewayNameArray[sender.tag]
        
        if name == "PAYPAL" {
            
            
            
            if paypalMode == true {
                
                PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: paypalKey])
                PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentProduction)
            }
            else {
                
                print(paypalKey)
               
                PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox: paypalKey])
                
                 PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentSandbox)
                let d = NSDecimalNumber(value: walletMoney)
                
                let payment = PayPalPayment(amount: d, currencyCode: "USD", shortDescription: "Wallet Money", intent: .sale)
              
                if (payment.processable) {
                    let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
                    present(paymentViewController!, animated: true, completion: nil)
                }
                else {
                    // This particular payment will always be processable. If, for
                    // example, the amount was negative or the shortDescription was
                    // empty, this payment wouldn't be processable, and you'd want
                    // to handle that here.
                    print("Payment not processalbe: \(payment)")
                }
                
                
            }
            }
        else if name == "STRIPE" {
            Stripe.setDefaultPublishableKey(stripekey)
            
            self.view.removeFromSuperview()
            delegatestripe.stripepaymentVCShow()
  
        }
    
    }

   
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        
        self.showAlert(with: "You have cancelled the payment")
         self.view.removeFromSuperview()
//        resultText = ""
//        successView.isHidden = true
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            
            let paymentResultDic = completedPayment.confirmation as NSDictionary
            
            
            let dicResponse: AnyObject? = paymentResultDic.object(forKey: "response") as AnyObject
            
            print(dicResponse!["id"] as! String)
            
            let payment_Id : String = dicResponse!["id"] as! String
            
            let amount : String = String(self.walletMoney)
            
            print("\(payment_Id) \(amount)")
            
            self.showLoader(str: "Adding Money to your wallet")
            
            API.walletPaymentCredit(with: "paypal", paymentId: payment_Id, amount: amount) { responseObject,error in
                
              
                
                if responseObject == nil {
                   
                }
                else {
                    let json = self.jsonParser.jsonParser(dicData: responseObject)
                    
                    let status = json[Const.STATUS_CODE].boolValue

                    if(status){
                        self.hideLoader()
                        var msg = json["text"].rawString()!
                        
                        
                         self.view.removeFromSuperview()
                        self.delegate.paymentconfimationmethod()
                        self.showAlert(with: msg)
                    }else {
                         self.hideLoader()
                        var msg = json["text"].rawString()!
                        self.view.removeFromSuperview()
                        self.showAlert(with: msg)
                        
                    }
                    
                    
                }
                
            }
            
            
//            self.resultText = completedPayment.description
//            self.showSuccess()
        })
    }
    
    
    // MARK: Future Payments
    
    @IBAction func authorizeFuturePaymentsAction(_ sender: AnyObject) {
        let futurePaymentViewController = PayPalFuturePaymentViewController(configuration: payPalConfig, delegate: self)
        present(futurePaymentViewController!, animated: true, completion: nil)
    }
    
    
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
      //  successView.isHidden = true
         self.view.removeFromSuperview()
        futurePaymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        print("PayPal Future Payment Authorization Success!")
        // send authorization to your server to get refresh token.
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
            
            print(futurePaymentAuthorization.description)
            
//            self.resultText = futurePaymentAuthorization.description
//            self.showSuccess()
        })
    }
    
    // MARK: Profile Sharing
    
    @IBAction func authorizeProfileSharingAction(_ sender: AnyObject) {
        let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]
        let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
        present(profileSharingViewController!, animated: true, completion: nil)
    }
    
    // PayPalProfileSharingDelegate
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
        print("PayPal Profile Sharing Authorization Canceled")
        //successView.isHidden = true
         self.view.removeFromSuperview()
        profileSharingViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable: Any]) {
        print("PayPal Profile Sharing Authorization Success!")
        
        // send authorization to your server
        
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
//            self.resultText = profileSharingAuthorization.description
//            self.showSuccess()
        })
        
    }

}

extension WalletPaymentGateType : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.total
        return gatewayNameArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: WalletPaymetTypeCell = tableView.dequeueReusableCell(withIdentifier: "WalletPaymetTypeCell", for: indexPath) as! WalletPaymetTypeCell

        cell.gatewayTypeBtn.tag = indexPath.row
        
        cell.gatewayTypeBtn.setTitle(self.gatewayNameArray[indexPath.row], for: .normal)
       cell.gatewayTypeBtn.addTarget(self, action:#selector(self.selectedPaymentMethod), for: .touchUpInside)
//        cell.lblName.text = self.descriptionArray[indexPath.row]
        
        return cell
    }
    
    
}
