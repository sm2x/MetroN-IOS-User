//
//  PaymentModeVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 9/18/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit

class PaymentModeVC: BaseViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var paymentUITableView: UITableView!
    
    var mode_Array = [String]()
    
    var selected_Mode : String!
    
    var delegate : UpdatePaymentMethodProtocalDelegate!
    fileprivate let defaults = UserDefaults.standard
    
    @IBOutlet weak var heightConstantTableView: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "blackBackIcon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(PaymentModeVC.backButton), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
         self.navItem.setLeftBarButton(item1, animated: true)
        
//        self.navItem.title = "lsklsdlf"
        
        print(mode_Array)
        if let paymentMode: String = defaults.string(forKey: "paymentmode") {
            if ("card" == paymentMode) {
                self.navItem.title = "Selected Payment Option: Card".localized()
            }
            else if ("walletbay" == paymentMode) {
                self.navItem.title = "Selected Payment Option: Wallet".localized()
            }
            else if ("cod" == paymentMode) {
                self.navItem.title = "Selected Payment Option: Cash".localized()
            }else{
                debugPrint("defaults")
            }
        }else {
            debugPrint("defaults")
        }
        
        
        paymentUITableView.tableFooterView = UIView()

        
        heightConstantTableView.constant = CGFloat(mode_Array.count * 50)
        
        self.paymentUITableView.delegate = self
        self.paymentUITableView.dataSource = self
        self.paymentUITableView.separatorStyle = .none
        
        self.paymentUITableView.reloadData()
        
        
        // Do any additional setup after loading the view.
    }

    func backButton(sender: Any) {
        
        guard (selected_Mode) != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.delegate?.updatePaymentMethod(with: selected_Mode)
        self.dismiss(animated: true, completion: nil)
        
        
    }

    
    
    func buttonSelectActionMethod(sender: UIButton) {
        
        print(sender.tag)
        
        let selected_Mode : String =  mode_Array[sender.tag]
        print(selected_Mode)
        self.showLoader(str: "Updating Payment Mode")
        defaults.set(mode_Array[sender.tag], forKey: "paymentmode")
        
        self.showLoader(str: "Updating Payment Mode")
        
        if ("card" == mode_Array[sender.tag]) {
            self.navItem.title = "Selected Payment Option: Card".localized()
        }
        else if ("walletbay" == mode_Array[sender.tag]) {
            self.navItem.title = "Selected Payment Option: Wallet".localized()
        }
        else if ("cod" == mode_Array[sender.tag]) {
            self.navItem.title = "Selected Payment Option: Cash".localized()
        }
        updatePayment(paymentMode: selected_Mode)
        
    }
    
    
    func updatePayment(paymentMode: String){
        
        API.updatePayment(paymentMode: paymentMode){ json, error in
            
            if let error = error {
                self.hideLoader()
                 self.showAlert(with :error.localizedDescription)
                print("path get error")
                print(error.localizedDescription)
            }else{
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.MESSAGE].stringValue
                    if(status){
                        
                        self.hideLoader()
                        
                        //                   self.selected_Mode = paymentMode
                        
                        self.delegate?.updatePaymentMethod(with: paymentMode)
                        
                        self.dismiss(animated: true, completion: nil)
                        
                        
                        print("Full updatePayment JSON")
                        print(json ?? "json null")
                        
                    }else{
                        
                        self.hideLoader()
                        
                        self.showAlert(with: statusMessage)
                        // self.dismiss(animated: true, completion: nil)
                        
                        
                        print(statusMessage)
//                        print(json ?? "json empty")
//                        var msg = json![Const.ERROR].rawString()!
//                        self.view.makeToast(message: msg)
                    }
                
                    
                }else {
                    self.hideLoader()
                    debugPrint("Invalid Json :(")
                }
            }
               
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension PaymentModeVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mode_Array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PaymentModeCell = tableView.dequeueReusableCell(withIdentifier: "PaymentModeCell", for: indexPath) as! PaymentModeCell
        
        
        
       
        
        
        
        if ("card" == mode_Array[indexPath.row]) {
            
            cell.buttonPaymentMode.setTitle("Pay by Card".localized(),for: .normal)
            
            
            cell.buttonPaymentMode.backgroundColor = UIColor(hex: "FE9700")
        }
        else if ("walletbay" == mode_Array[indexPath.row]) {
            
            cell.buttonPaymentMode.setTitle("Pay by Wallet".localized(),for: .normal)
            cell.buttonPaymentMode.backgroundColor = UIColor(hex: "0070BA")
            
        }
        else if ("cod" == mode_Array[indexPath.row]) {
            
            cell.buttonPaymentMode.setTitle("Pay by Cash".localized(),for: .normal)
            cell.buttonPaymentMode.backgroundColor = UIColor(hex: "FE9700")
            
        }
        
        cell.buttonPaymentMode.tag = indexPath.row
        
        
        cell.buttonPaymentMode.addTarget(self, action:#selector(self.buttonSelectActionMethod), for: .touchUpInside)
       
        
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    

    
    
}
