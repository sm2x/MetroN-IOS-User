//
//  NKStripeVC.swift
//  Nikola
//
//  Created by sudharsan s on 27/11/17.
//  Copyright © 2017 Nikola. All rights reserved.
//

import UIKit
import Stripe


class NKStripeVC: BaseViewController,STPPaymentCardTextFieldDelegate {

    
    @IBOutlet weak var cardUIview: UIView!
     let paymentTextField = STPPaymentCardTextField()
    var delegate : paymentconfimationprotocaldelegate!
     var walletmoney : String!
    let width = UIScreen.main.bounds.width
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if width > 320 {
            paymentTextField.frame = CGRect(x: 0, y: 10
                , width: self.cardUIview.frame.width - 50, height: 30)
        }else {
            paymentTextField.frame = CGRect(x: 0, y: 10
                , width: self.cardUIview.frame.width - 100, height: 30)
        }
        
       
        //paymentTextField.center = view.center
        
        paymentTextField.textColor = UIColor.white
       // paymentTextField.delegate = self
          let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        cardUIview.addSubview(paymentTextField)
        // Do any additional setup after loading the view.
    }

    func handleTap(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
      //  print("Hello World")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func paynowActionMethod(_ sender: Any) {
        view.endEditing(true)
        self.showLoader(str: "Please wait".localized())
        
        
        let card = paymentTextField.cardParams
        
        print(card)
        STPAPIClient.shared().createToken(withCard: card, completion: {(token, error) -> Void in
            if let error = error {
                
                self.hideLoader()
                self.showAlert(with: error.localizedDescription)
                print(error.localizedDescription)
            }
            else if let token = token {
                
                print(token)
                
                let payment_id : String = String(describing: token)
                
                print(payment_id)
                
                
                API.walletPaymentCredit(with: "stripe", paymentId: payment_id, amount: self.walletmoney) { responseObject,error in

                    if let error = error {
                        self.hideLoader()
                        self.showAlert(with: error.localizedDescription)
                        print(error.localizedDescription)

                    }else {
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
            
            }
            
        })
        
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
