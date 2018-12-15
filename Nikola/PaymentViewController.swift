//
//  PaymentViewController.swift
//  Nikola Driver
//
//  Created by Sutharshan Ram on 25/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import Braintree
import BraintreeDropIn
import Floaty

class PaymentViewController: BaseViewController, UIGestureRecognizerDelegate, FloatyDelegate, UITableViewDelegate, UITableViewDataSource   {
    
    var countryArray=["Afghanistan","Albania","Algeria","AmericanSamoa","Andorra","Angola","Anguilla","Haiti","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya"]
    var selectedIndex:IndexPath?
     var isBackBoolVal : Bool?
    lazy var isdefaulCardSet:Bool = false
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    
    
    @IBOutlet weak var demoUIView: UIView!
    var cards:[Card]=[]
    
    @IBOutlet weak var viewFloat: UIView!
    
    @IBOutlet weak var btnAddPaymentOption: UIButton!
    var floaty: Floaty? = nil
    var longPressCard: Card? = nil
    let model: Card? = nil
     @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    let defaults = UserDefaults.standard
    
    
    //MARK:- Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //166
        if let boolValue = isBackBoolVal {
            if boolValue == true {
                burgerMenu.image = UIImage(named: "blackBackIcon")
                self.navBar.alpha = 0.0
            }
            else {
                burgerMenu.image = UIImage(named: "Burger")
                self.navBar.alpha = 1.0
                }
        }
        else {
            let btn1 = UIButton(type: .custom)
            btn1.setImage(UIImage(named: "Burger"), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            btn1.addTarget(self, action: #selector(PaymentViewController.backButton), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: btn1)
            
            self.navItem.setLeftBarButton(item1, animated: true)
        }
        self.navBar.tintColor = UIColor.darkGray
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        lpgr.numberOfTapsRequired = 0
        
        self.tableView.addGestureRecognizer(lpgr)
        self.tableView.tableFooterView = UIView()
        let card:Bool = defaults.bool(forKey: "defaultcard")
        if card {
            isdefaulCardSet = true
        }else {
            isdefaulCardSet = false
            }
//        rlayoutFAB()
        self.getAddedCards()
        
        viewFloat.backgroundColor = UIColor(red:1.00, green:0.59, blue:0.00, alpha:1.0)
        viewFloat.layer.cornerRadius = 50
        viewFloat.layer.masksToBounds = true
        btnAddPaymentOption.backgroundColor = UIColor.clear
        
        viewFloat.layer.shadowColor = UIColor.lightGray.cgColor
        viewFloat.layer.shadowOffset = CGSize.zero
        viewFloat.layer.shadowRadius = 1
        viewFloat.layer.shadowOpacity = 1
        viewFloat.layer.shouldRasterize = true
        viewFloat.layer.masksToBounds = false
        
    }
    
    
    @IBAction func btnAddPaymentPressed(_ sender: Any) {
        
        self.gototornPaymentOptions()
    }
    func gototornPaymentOptions()
    {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "NKTornPaymenOptionstViewController") as! NKTornPaymenOptionstViewController
        
        self.navigationController?.pushViewController(myVC, animated: true)
//        self.present(myVC, animated: true, completion: nil)
    }
    
    //MARK:- HandleLongPress
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.began {
            return
        }
        let point = gestureReconizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        if let index = indexPath {
            var cell = self.tableView.cellForRow(at: index)
            // do stuff with your cell, for example print the indexPath
            let card: Card = cards[index.row]
            longPressCard = card
            showDeleteCardDialog(card: card)
            print(index.row)
        } else {
            print("Could not find index path")
        }
        
        if isdefaulCardSet {
            let point = gestureReconizer.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: point)
            
            if let index = indexPath {
                var cell = self.tableView.cellForRow(at: index)
                // do stuff with your cell, for example print the indexPath
                let card: Card = cards[index.row]
                longPressCard = card
                showDeleteCardDialog(card: card)
                print(index.row)
            } else {
                print("Could not find index path")
            }
        }else {
           
        }
        
        
    }
    
    //MARK:- Navigation Back
    func backButton(sender: Any) {
        revealViewController().revealToggle(sender)
    }
    @IBAction func BackActionMethod(_ sender: Any) {
        
        if let boolValue = isBackBoolVal {
            if boolValue == true {
                self.dismiss(animated: true, completion: nil)
            }else {
                revealViewController().revealToggle(sender)
            }
            
        }else {
            revealViewController().revealToggle(sender)
        }
        
        
    }
    //MARK:- GetAddedCards
    func getAddedCards(){
        
        
         self.showLoader( str: "Please wait")
        
        
        API.getAddedCards{ json, error in
            if error != nil {
                print("getAddedCards error")
                print(error!.localizedDescription)
            }else{
                
                if let json = json {
                    
                    debugPrint("json card response \(json)")
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        let jsonArray = json["cards"].arrayValue
                        self.isdefaulCardSet = true
                        self.defaults.set(true, forKey: "defaultcard")
                        
                            self.cards.removeAll()
                            for cardJobj: JSON in jsonArray {
                            self.cards.append(Card.init(jObj: cardJobj))
                        }
                        print(json)
                        self.demoUIView.isHidden = true
                             self.hideLoader()
                            self.tableView.reloadData()
                            print("cards done")
                        
                        let tron_wallet = json["tron_wallet"].dictionaryValue
                        
                        
                        let defaults = UserDefaults.standard
                        defaults.set(tron_wallet["address_base58"]?.stringValue, forKey: Const.Torn_Wallet_Address)
                        defaults.set(json["market_price"].stringValue, forKey: Const.Torn_Current_value)
                        
                        
                        }else{
                        
                         self.demoUIView.isHidden = false
                            self.hideLoader()
                    
                            print(statusMessage)
                            print(json)
//                            print(json["tron_wallet"].dictionaryValue)
                        let tron_wallet = json["tron_wallet"].dictionaryValue
                        
                        
                        let defaults = UserDefaults.standard
                        defaults.set(tron_wallet["address_base58"]?.stringValue, forKey: Const.Torn_Wallet_Address)
                        defaults.set(json["market_price"].stringValue, forKey: Const.Torn_Current_value)
                        
                    
                     
                        if let error_Code = json[Const.ERROR_CODE].int {
                    
                            if error_Code == 104 {
                    
                                self.showAlert(with: "Session expired")
                    
                            }
                        else {
                    
                                if let msg : String = json[Const.NEW_ERROR].rawString() {
                                    self.showAlert(with: "session expired")
                                }
                            }
                    
                    
                       }
                    
                    
                    
                }
                    
                }else {
                    debugPrint("invalid")
                }
                

        }
        }
        
    }
    
    //MARK:- SetDefaultCard
    func setDefaultCard(card: Card? = nil){
        
        if isdefaulCardSet {
            debugPrint("defaultcardsetted")
            API.setDefaultCard(cardNumber: (card?.cardNumber)!, type: (card?.type)!, cardId: (card?.cardId)!, completionHandler: { json, error in
                if error != nil {
                    print("setDefaultCard error")
                    print(error!.localizedDescription)
                }else{
                    if let json = json {
                        let status = json[Const.STATUS_CODE].boolValue
                        let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                            print(json)
                            self.getAddedCards()
                            print("default cards done")
                        }else{
                            print(statusMessage)
                            print(json)
                            var msg = json[Const.DATA].rawString()!
                            self.view.makeToast(message: msg)
                        }
                    }else {
                        debugPrint("Invalid Json :(")
                        
                    }
                    
                    
                }
            })
        }else {
            API.setDefaultCard(cardNumber: "4242 4242 4242 42", type: "visa", cardId: "", completionHandler: { json, error in
                if error != nil {
                    print("setDefaultCard error")
                    print(error!.localizedDescription)
                }else{
                    if let json = json {
                        let status = json[Const.STATUS_CODE].boolValue
                        let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                            print(json)
                            self.getAddedCards()
                            print("default cards done")
                        }else{
                            print(statusMessage)
                            print(json)
                            if let error_code: Int = json[Const.ERROR_CODE].intValue {
                                if error_code == 101 {
                                    let msg = json[Const.ERROR_MSG].stringValue
                                    self.showAlert(with: msg)
                                }else {
                                    let msg = json[Const.ERROR].stringValue
                                    self.showAlert(with: msg)
                                }
                            }
                        
                        }
                    }else {
                        debugPrint("Invalid Json :(")
                        
                    }
                    
                    
                }
            })
        }
        
        
    }
    
    //MARK:- RemoveCard
    func removeCard(card: Card){
        print(card.cardId)
        
        API.removeCard(cardId: card.cardId, completionHandler: { json, error in
            if error != nil {
                print("removeCard error")
                print(error!.localizedDescription)
            }else{
                
                if let json = json {
                        let status = json[Const.STATUS_CODE].boolValue
                        let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                            print(json )
                            self.getAddedCards()
                            print("default cards done")
                        }else{
                            print(statusMessage)
                            print(json ?? "json empty")
                                        var msg = ""
                            if json[Const.ERROR].exists() {
                                msg = json[Const.ERROR].stringValue
                            }else if json[Const.MESSAGE].exists() {
                                msg = json[Const.MESSAGE].stringValue
                            }
                            if msg.isEmpty {
                                msg = "Unable to proceed with action. Please try again"
                            }
                            self.view.makeToast(message: msg, duration: 3.0, position: "center" as AnyObject)
                                        //self.view.makeToast(message: msg)
                        }
                    
                }else {
                    debugPrint("Invalid Json :(")
                    
                }
   
            }
        })
    }

    

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if isdefaulCardSet {
            return cards.count
            
         }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PaymentCell=tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        
        if isdefaulCardSet {
            
            let card: Card = cards[indexPath.row]
            
            cell.cardNumber.text = "XXXX XXXX XXXX \(card.cardNumber)"
            
            
            
            if (selectedIndex == indexPath || card.isDefault == "1") {
                cell.radioButton.setImage(UIImage(named: "radioButtonChecked"),for:.normal)
            } else {
                cell.radioButton.setImage(UIImage(named: "radioButtonUnchecked"),for:.normal)
            }
            
            let cardType: String = card.cardtype.lowercased()
            
            var tempCardImg: UIImage? = nil
            if card.type == "card" {
                switch (cardType) {
                case "americanexpress":
                    tempCardImg = UIImage(named: "bt_amex")
                    break;
                case "visa":
                    tempCardImg = UIImage(named: "bt_visa")
                    break;
                case "mastercard":
                    tempCardImg = UIImage(named: "bt_mastercard")
                    break;
                case "jcb":
                    tempCardImg = UIImage(named: "bt_jcb")
                    break;
                case "maestro":
                    tempCardImg = UIImage(named: "bt_maestro")
                    break;
                case "dinersclub":
                    tempCardImg = UIImage(named: "bt_diners")
                    break;
                case "chinaunionPay":
                    tempCardImg = UIImage(named: "bt_card_highlighted")
                    break;
                default:
                    tempCardImg = UIImage(named: "bt_card_highlighted")
                }
                cell.radioButton.isHidden = false
            }
                
            else{
                tempCardImg = UIImage(named: "ub__creditcard_paypal")
                cell.cardNumber.text = "\(card.email)"
                cell.radioButton.isHidden = true
            }
            
            cell.cardTypeImg.image = tempCardImg
            
        }else {
             cell.cardNumber.text = "XXXX XXXX XXXX 4242"
             cell.cardTypeImg.image = UIImage(named: "bt_visa")
        }
        
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let row = indexPath.row
        print(countryArray[row])
        selectedIndex = indexPath
        if cards.count > 0 {
                self.setDefaultCard(card: cards[row])
        }
    
        tableView.reloadData()
    }
    
    func showDeleteCardDialog(card: Card){
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove this card?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(
        title: "Yes", style: UIAlertActionStyle.default) { (action) in
            self.removeCard(card: card)
        }
        alert.addAction(confirmAction)
        let cancelAction = UIAlertAction(
        title: "No", style: UIAlertActionStyle.default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- FABButton
    func layoutFAB() {
        
        floaty = Floaty()
        floaty?.buttonColor = UIColor(red:1.00, green:0.59, blue:0.00, alpha:1.0)
        floaty?.buttonImage = UIImage(named: "add-credit-card")
        
//        self.view.addSubview(floaty!)
        floaty?.fabDelegate = self
        
        
    }
    
    func emptyFloatySelected(_ floaty: Floaty){
        print("Floaty emptyFloatySelected")
        getBrainTreeClientToken()
    }
    
    func floatyOpened(_ floaty: Floaty) {
        print("Floaty Opened")
    }
    
    func floatyClosed(_ floaty: Floaty) {
        print("Floaty Closed")
    }

    //MARK:- BrainTreeClientToken
    func getBrainTreeClientToken(){
        
        API.getBrainTreeClientToken { json, error in
            
            if (error != nil) {
                print(error.debugDescription)
                self.view.makeToast(message: (error?.localizedDescription)!)
                return
            }
            if let json = json {
                let status = json[Const.STATUS_CODE].boolValue
                let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                if(status){
                    let clientToken: String = json["client_token"].stringValue
                    print(json ?? "error in getBrainTreeClientToken json")
                        self.showDropIn(clientTokenOrTokenizationKey: clientToken)
                    }else{
                        print(statusMessage)
                        print(json ?? "getBrainTreeClientToken json empty")
                    
                    if let msg : String = json[Const.ERROR].rawString() {
                        self.view.makeToast(message: msg)
                    }
//                        var msg = json[Const.ERROR].rawString()!
//                        msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                    
                }
                
            }else {
                
                debugPrint("Invalid Json :(")
                
            }

        }
    }
    
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
            
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
                self.view.makeToast(message: (error?.localizedDescription)!)
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
                self.view.makeToast(message: "Please enter payment information to proceed")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                
                self.sendNonce(nonce: (result.paymentMethod?.nonce)!)
                //self.goToDashboard()
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }

    func sendNonce(nonce: String){
        API.sendNonce(nonce: nonce, completionHandler: { json, error in
            if (error != nil) {
                print(error.debugDescription)
                self.view.makeToast(message: (error?.localizedDescription)!)
                return
            }
            
            if let json = json {
                let status = json[Const.STATUS_CODE].boolValue
                let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                if(status){
                    self.view.makeToast(message: "Card added successfully")
                    self.getAddedCards()
                        print(json ?? "error in sendNonce json")
                                    //self.goToDashboard()
                    }else{
                        print(statusMessage)
                        print(json ?? "sendNonce json empty")
                    
                    if let msg : String = json[Const.ERROR].rawString() {
                         self.view.makeToast(message: msg)
                    }
                                   // var msg = json[Const.ERROR].rawString()!
                    
                }
                
            }else {
                debugPrint("Invalid Json :(")
            }
            

        })
    }
    
}
//MARK:- UIImage Extention
extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}
