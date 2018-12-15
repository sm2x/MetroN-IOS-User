//
//  RentalRideViewController.swift
//  Nikola
//
//  Created by Sutharshan Ram on 12/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import DateTimePicker
import GooglePlaces
import SwiftyJSON
import DropDown


class RentalRideViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    @IBOutlet weak var pickupBtn: UIButton!    
    
    @IBOutlet weak var bookNowBtn: UIButton!
    
    @IBOutlet weak var taxiTypeBtn: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var packagePriceLabel: UILabel!
    @IBOutlet weak var datePickerBtn: UIButton!
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var txtTaxiType: UITextField!
    @IBOutlet weak var txtPickupLocation: UITextField!
    @IBOutlet weak var uiviewTimeSet: UIView!
    
    @IBOutlet weak var timeUILabel: UILabel!
    
    @IBOutlet weak var uiDatePicker: UIDatePicker!
    
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var hoursCountTextView: UITextField!
    var locationChoice: Int = 0
    
    var taxiTypes : [TaxiType] = []
    var taxiTypesStrings : [String] = []
    var currentTaxi: TaxiType? = nil
    var currentSelection : Int = 0
    var currentIndexPath : IndexPath? = nil
     weak var defaults = UserDefaults.standard
    let taxiTypesDropDown: DropDown = DropDown()
    
    var s_address: String = "", d_address: String = ""
    var s_point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0) , d_point: CLLocationCoordinate2D =  CLLocationCoordinate2DMake(0.0, 0.0)
    
    var pickUpLocation: String = "", service_id: String = ""
    
    var hoursCount: String = ""
    var isAirport: Bool = true
    var hourly_package_id: String = ""
    
    var isViewType : Bool!
    
    var dateString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if revealViewController() != nil {
//            burgerMenu.target = revealViewController()
//            burgerMenu.action = "revealToggle:"
//            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//        }
        
        
        
        let btn1 = UIButton(type: .custom)
        
          btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        if let boolValue = isViewType {
                    if boolValue == true {
            
            btn1.setImage(UIImage(named: "blackBackIcon"), for: .normal)
                          btn1.addTarget(self, action: #selector(RentalRideViewController.backNewMethod), for: .touchUpInside)
                    }
                    else {
                          btn1.addTarget(self, action: #selector(RentalRideViewController.backButton), for: .touchUpInside)
                    }

            
        }
        else {
            
            btn1.setImage(UIImage(named: "Burger"), for: .normal)
             btn1.addTarget(self, action: #selector(RentalRideViewController.backButton), for: .touchUpInside)
        }
        
//        if isViewType == true {
        
//            
//              btn1.addTarget(self, action: #selector(RentalRideViewController.backNewMethod), for: .touchUpInside)
//        }
//        else {
//              btn1.addTarget(self, action: #selector(RentalRideViewController.backButton), for: .touchUpInside)
//        }
        
        
    
      
      
        let item1 = UIBarButtonItem(customView: btn1)
        
        self.navItem.setLeftBarButton(item1, animated: true)
        
        
//        self.navBar.tintColor = UIColor.darkGray
        
        
        uiDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        hoursCountTextView.delegate = self
        hoursCountTextView.tag = 0
        
       
        let defaults = UserDefaults.standard
        let line = defaults.object(forKey: Const.CURRENT_ADDRESS)!
        
        if line != nil {
            let lines = defaults.object(forKey: Const.CURRENT_ADDRESS)! as? String ?? String()
            
            if !(lines ?? "").isEmpty {
//                pickupBtn.setTitle(lines, for: UIControlState.normal)
                
                
                txtPickupLocation.text = lines
                
                pickUpLocation = lines
            }
        }

        
        
        
        let taxiTypesString: String = DATA().getTaxiTypesData()
        
        if !taxiTypesString.isEmpty {
            let taxiTypesJson : JSON = JSON.init(parseJSON: taxiTypesString)
            
            let typesArray = taxiTypesJson.arrayValue
            
            self.taxiTypes.removeAll()
            self.taxiTypesStrings.removeAll()
            for type: JSON in typesArray {
                let taxi: TaxiType = TaxiType.init(taxiObj: type)
                self.taxiTypes.append(taxi)
                self.taxiTypesStrings.append(taxi.type)
            }
            
        }else{
            
        }
        
        
        txtPickupLocation.layer.masksToBounds = false
        txtPickupLocation.layer.shadowRadius = 1.0
        txtPickupLocation.layer.shadowColor = UIColor.black.cgColor
        txtPickupLocation.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtPickupLocation.layer.shadowOpacity = 1.0
        
        
        hoursCountTextView.layer.masksToBounds = false
        hoursCountTextView.layer.shadowRadius = 1.0
        hoursCountTextView.layer.shadowColor = UIColor.black.cgColor
        hoursCountTextView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        hoursCountTextView.layer.shadowOpacity = 1.0
        
        
        txtTaxiType.layer.masksToBounds = false
        txtTaxiType.layer.shadowRadius = 1.0
        txtTaxiType.layer.shadowColor = UIColor.black.cgColor
        txtTaxiType.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtTaxiType.layer.shadowOpacity = 1.0
        
        
        getTaxiTypes(initCall: true)
        
        taxiTypesDropDown.anchorView = taxiTypeBtn
        taxiTypesDropDown.dataSource = []
        
        hoursCountTextView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        
        
        taxiTypesDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.taxiTypeBtn.setTitle("\(item)", for: .normal)
            self.service_id = self.taxiTypes[index].id
            self.hoursCount  = self.hoursCountTextView.text!
            self.getHourlyFare(serviceType:  self.service_id, numberOfHours: self.hoursCount)
        }
        
    }
    
    
    
    func backButton(sender: Any) {
        
       
         revealViewController().revealToggle(sender)
        
        
        
    }
    
    func backNewMethod(sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
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
    
    func textFieldDidChange(_ textField: UITextField) {
        
        print(textField.text)
        
        let key: String = textField.text!
        
        if !key.isEmpty{
            self.hoursCount = key
            self.getHourlyFare(serviceType:  self.service_id, numberOfHours: self.hoursCount)
        }else{
            distanceLabel.text = "--"
            packagePriceLabel.text = "--"
            hourly_package_id = ""
        }
        
    }
    
    @IBAction func bookNowBtnAction(_ sender: UIButton) {
        
        if hourly_package_id.isEmpty || pickUpLocation.isEmpty || service_id.isEmpty {
            self.view.makeToast(message: "Please enter all the details")
        }else {
            //self.setLatLonFromAddress()
            self.requestRentalTaxi()
        }
        
    }
    
    @IBAction func taxiTypesListBtnAction(_ sender: UIButton) {
        
        taxiTypesDropDown.show()
        
        if taxiTypesStrings.count > 0{
            taxiTypesDropDown.show()
        }else{
            self.getTaxiTypes(initCall: false)
        }
    }
    
    @IBAction func datePickerAction(_ sender: UIButton) {
        
        if hoursCount.isEmpty || pickUpLocation.isEmpty || service_id.isEmpty {
            self.view.makeToast(message: "Please enter all the details")
        }else {
            
            
            let today: Date = Date()
            
            
            uiviewTimeSet.isHidden = false
            
             let newDate : Date = Calendar.current.date(byAdding: .minute, value: Const.LATER_MINUTES_TO_ADD, to: Date())!
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            dateString = dateFormatter.string(from: newDate)
            
            
            self.timeUILabel.text = dateString
            
            self.uiDatePicker.minimumDate = newDate

            
            
            
//            let today: Date = Date()
//            //let picker = DateTimePicker.show()
//            let picker = DateTimePicker.show(selected: today, minimumDate: today)
//            picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
//            picker.isDatePickerOnly = false // to hide time and show only date picker
//            picker.completionHandler = { date in
//                
//                //date.description
//                //date.description(with: Locale?)
//                let dateFormatter = DateFormatter()
//                //dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss"
//                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
//                let dateString: String = dateFormatter.string(from: date)
//                //self.datePickerBtn.setTitle(dateString, for: .normal)
//                
//                
//                self.requestHourlyTaxiLater(dateTime: dateString)
//            }
        }
    }
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        
        self.dateString = dateFormatter.string(from: sender.date)
        
        self.timeUILabel.text = dateString
        
        
        
//        self.dateString = dateString
        
    }

    
    
    @IBAction func pickupAction(_ sender: UIButton) {
        locationChoice = 0
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func getTaxiTypes(initCall: Bool){
        
        API.getTaxiTypes{ json, error in
            
            if let error = error {
                //self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                     if(status){
                         DATA().putTaxiTypesData(request: json["services"].rawString()!)
                            let typesArray = json["services"].arrayValue
                        for type: JSON in typesArray {
                            self.taxiTypes.append(TaxiType.init(taxiObj: type))
                        }
                                    print(json ?? "error in taxi_types json")
                    
                            self.taxiTypes.removeAll()
                            self.taxiTypesStrings.removeAll()
                            for type: JSON in typesArray {
                                let taxi: TaxiType = TaxiType.init(taxiObj: type)
                                self.taxiTypes.append(taxi)
                                self.taxiTypesStrings.append(taxi.type)
                            }
                    
                        
                        if self.taxiTypesStrings.count > 0 {
                            self.taxiTypeBtn.setTitle("\(self.taxiTypesStrings[0])", for: .normal)
                                self.service_id = self.taxiTypes[0].id
                        }
                        
//                        if let taxiType : String = "\(self.taxiTypesStrings[0])"  {
//                            self.taxiTypeBtn.setTitle("\(self.taxiTypesStrings[0])", for: .normal)
//                            self.service_id = self.taxiTypes[0].id
//                        }
                        
                        
                    
                            if self.taxiTypesStrings.count > 0 {
                                self.taxiTypesDropDown.dataSource = self.taxiTypesStrings
                            if !initCall {
                                  self.taxiTypesDropDown.show()
                                }
                            if self.service_id.isEmpty {
                                self.service_id = self.taxiTypes[0].id
                    
                                }
                             }else{
                                self.taxiTypesDropDown.dataSource = self.taxiTypesStrings
                                        self.taxiTypesDropDown.hide()
                                }
                          }else{
                            print(statusMessage)
                            print(json ?? "json empty")
                        
                        if let msg : String = json[Const.DATA].rawString() {
                            
                            
                            self.view.makeToast(message: msg)
                        }
//                            var msg = json[Const.DATA].rawString()!
//                            msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
//
//                                    self.view.makeToast(message: msg)
                        }
                }else {
                    debugPrint("Invalid Json :(")
                }
            }
            

        }
    }
    
    
    
    func requestRentalTaxi(){
        let defaults = UserDefaults.standard
        
        print(self.s_address)
        do{
            
                self.showAnimation()
                    self.startTimer()
                    API.requestHourlyTaxi(serviceType: self.service_id, hourlyPackageId: self.hourly_package_id, completionHandler: {
                        json, error in
                        if let error = error {
                            //self.hideLoader()
                            let vc = self.childViewControllers.last
                            vc!.willMove(toParentViewController: nil)
                            vc?.view.removeFromSuperview()
                            vc?.removeFromParentViewController()
                            self.showAlert(with :error.localizedDescription)
                            debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                        }else {
                            if let json = json {
                                let status = json[Const.STATUS_CODE].boolValue
                                let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                                if(status){
                                    
                                    print(json)
                                    
                                }else{
                                    let vc = self.childViewControllers.last
                                    vc!.willMove(toParentViewController: nil)
                                    vc?.view.removeFromSuperview()
                                    vc?.removeFromParentViewController()
                                    
                                    print(statusMessage)
                                    print(json ?? "json empty")
                                    if let error_Code = json[Const.ERROR_CODE].int {
                                        if error_Code == 163 {
                                            
                                            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                                            next.isBackBoolVal = true
                                            
                                            let nav = UINavigationController.init(rootViewController: next)
                                            
                                            self.present(nav, animated: true, completion: nil)
                                            
                                            
                                            
                                        }
                                        else if error_Code == 117 {
                                            
                                            if let msg : String = json[Const.MESSAGE].rawString() {
                                                self.showAlert(with: msg)
                                            }
                                        }
                                            
                                        else {
                                            if let msg : String = json[Const.ERROR].rawString() {
                                                self.showAlert(with: msg)
                                            }
                                        }
                                        
                                    }
                                    
        
                                }
                                
                            }else {
                                debugPrint("Invalid Json :(")
                                
                            }
                            
                        }
                        
                       
            })
        }catch {
            print("some error in airport request flow")
        }
    }
    
    func requestHourlyTaxiLater(dateTime: String){
        
        let defaults = UserDefaults.standard
        
        print(self.s_address)
                    API.requestHourlyTaxiLater(dateTime:dateTime, serviceType: self.service_id, hourlyPackageId: self.hourly_package_id, completionHandler: {
                        json, error in
                        
                        if let error = error {
                            //self.hideLoader()
                             self.showAlert(with :error.localizedDescription)
                            debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                        }else {
                            if let json = json {
                                let status =  json[Const.STATUS_CODE].boolValue
                                let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                                if(status){
                                    self.showRideScheduledDialog()
                                            print(json ?? "error in requestHourlyTaxiLater json")
                                
                                }else{
                                
                                    print(statusMessage)
                                    print(json ?? "json empty")
                                    if let msg : String = json[Const.ERROR].rawString() {
                                        self.view.makeToast(message: msg)
                                    }
                                    
                                   
                                
                                  
                                }
                            
                            
                            }else {
                                debugPrint("Invalid Json :(")
                                
                            }
                            
                        }
                        

            })
        
    }
    
    func showRideScheduledDialog(){
        let alert = UIAlertController(title: "", message: "Trip Scheduled Successfully!", preferredStyle: .alert)
        let confirmAction = UIAlertAction(
        title: "Ok", style: UIAlertActionStyle.default) { [weak self] (action) in
            self?.defaults?.set("scdeduledRequest", forKey: "requestType")
            self?.goToDashboard()
        } 
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getHourlyFare(serviceType: String, numberOfHours: String){
        
        API.getFareHourlyPackage(numberOfHours: numberOfHours, service_id: service_id,completionHandler: { json, error in
//
            if let error = error {
                //self.hideLoader()
                 self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status =  json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        let hourlyPackage: JSON = json["hourly_package_details"]
                    
                        self.hourly_package_id = hourlyPackage["id"].stringValue
                        self.distanceLabel.text = hourlyPackage["distance"].stringValue
                        
                        if let currency: String = UserDefaults.standard.string(forKey: "currency") {
                            self.packagePriceLabel.text = "\(currency) " + hourlyPackage["price"].stringValue
                            
                        }else {
                            self.packagePriceLabel.text =  hourlyPackage["price"].stringValue
                        }
                        
                        
                        
                    
                        print(json ?? "error in locations json")
                    
                    }else{
                    
                            self.hourly_package_id = ""
                            self.distanceLabel.text = "--"
                            self.packagePriceLabel.text = "--"
                    
                            print(statusMessage)
                            print(json ?? "json empty")
                        
                        if let msg : String = json[Const.ERROR].rawString() {
                            self.view.makeToast(message: msg)
                        }
                            //var msg = json[Const.ERROR].rawString()!
                    
                        
                     }
                    
                    
                }else {
                    debugPrint("Invalid Json :(")
                }
            }
            
            

        })
    }
    
    
    var timer: DispatchSourceTimer?
    
    func startTimer() {
        let queue = DispatchQueue(label: "com.prov.nikola.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: .now(), interval: .seconds(4))
        timer!.setEventHandler { [weak self] in
            // do whatever you want here
            
            self?.checkRequestStatus()
            
        }
        timer!.resume()
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    
    deinit {
        self.stopTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            print("Full checkrequeststatus JSON")
            print(json ?? "json null")
            
            if let error = error {
                //self.hideLoader()
                 self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                    
                    
                        var requestDetail: RequestDetail = RequestDetail()
                    
                        let jsonAry:[JSON]  = json[Const.DATA].arrayValue
                        let defaults = UserDefaults.standard
                    
                        if jsonAry.count > 0 {
                        let driverData = jsonAry[0]
                            if driverData.exists() {
                    
                                defaults.set(driverData["request_id"].stringValue, forKey: Const.Params.REQUEST_ID)
                                            defaults.set(driverData["provider_id"].stringValue, forKey: Const.Params.DRIVER_ID)
                                            requestDetail.initDriver(rqObj: driverData)
                                }
                    
                        let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
                            if invoiceAry.count > 0 {
                                    let invoiceData = invoiceAry[0]
                                    print("invoice json")
                                    print(invoiceData.rawString() ?? "invoiceData null")
                                            defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                                            requestDetail.initInvoice(rqObj: invoiceData)
                                }
                                self.processStatus(json: json, tripStatus:requestDetail.tripStatus)
                                } else {
                                        requestDetail.tripStatus = Const.NO_REQUEST
                                        let defaults = UserDefaults.standard
                                        defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
                                    }
                    
                    
                    
                                    //self.goToDashboard()
                                    //self.view.makeToast(message: "Logged In")
                                }else{
                                    print(statusMessage)
                                    print(json ?? "json empty")
                        
                        
                        let vc = self.childViewControllers.last
                        vc!.willMove(toParentViewController: nil)
                        vc?.view.removeFromSuperview()
                        vc?.removeFromParentViewController()
                        
                        if let error_Code = json[Const.ERROR_CODE].int {
                            if error_Code == 163 {
                                
                                let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                                next.isBackBoolVal = true
                                
                                let nav = UINavigationController.init(rootViewController: next)
                                
                                self.present(nav, animated: true, completion: nil)
                                
                                
                                
                            }
                            else if error_Code == 117 {
                                
                                if let msg : String = json[Const.MESSAGE].rawString() {
                                    self.showAlert(with: msg)
                                }
                            }
                                
                            else {
                                if let msg : String = json[Const.ERROR].rawString() {
                                    self.showAlert(with: msg)
                                }
                                
                            }
                            
                        
                    
//                        if let msg : String = json[Const.DATA].rawString() {
//                            self.view.makeToast(message: msg)
                        }
                    }
                    
                }else {
                    debugPrint("Invalid Json :(")
                }
                
                
            }
            

        }
    }
    
    func processStatus(json: JSON, tripStatus: Int){
        
        //var requestDetail: RequestDetail = RequestDetail()
        switch(tripStatus){
            
        case Const.NO_REQUEST:
            PreferenceHelper.clearRequestData()
            self.view.makeToast(message: "No Providers found please try after some time!")            
            self.stopTimer()
            if (popOverVC != nil) {
                popOverVC?.removeFromParentViewController()
            }
            print("No Providers found please try after some time!")
        case Const.IS_ACCEPTED:
            
            let defaults = UserDefaults.standard
            defaults.set(Const.IS_ACCEPTED, forKey: Const.DRIVER_STATUS)
            print("Driver accepted")
            self.stopTimer()
            
            if (popOverVC != nil) {
                popOverVC?.removeFromParentViewController()
            }
            
            let jsonAry:[JSON]  = json[Const.DATA].arrayValue
            if jsonAry.count > 0 {
                let driverData = jsonAry[0]
                if driverData.exists() {
                    //saving driver data
                    defaults.set(driverData.rawString(), forKey: Const.CURRENT_DRIVER_DATA)
                    
                    defaults.set(driverData["request_id"].stringValue, forKey: Const.Params.REQUEST_ID)
                }
                
                // saving invoice data
                let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
                if invoiceAry.count > 0 {
                    let invoiceData = invoiceAry[0]
                    defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                }
            }
            self.goToTravelMap()
        default:
            print("something else happened")
        }
        
    }
    
    var popOverVC: RequestAnimationViewController? = nil
    
    func showAnimation(){
        popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestAnimationViewController") as! RequestAnimationViewController
        self.addChildViewController(popOverVC!)
        popOverVC!.view.frame = self.view.frame
        UserDefaults.standard.set(true, forKey: "viewHour")
        self.view.addSubview(popOverVC!.view)
        popOverVC!.didMove(toParentViewController: self)
        
    }
    
    func goToTravelMap(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sw = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.view.window?.rootViewController = sw
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "TravelMapViewController") as! TravelMapViewController
//        let navigationController = UINavigationController(rootViewController: destinationController)
        sw.pushFrontViewController(destinationController, animated: true)
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    
    
    @IBAction func cancelButtionAction(_ sender: Any) {
        
        uiviewTimeSet.isHidden = true
    }
    
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        uiviewTimeSet.isHidden = true
        
        if dateString.isEmpty {
            
        }
        else {

            self.requestHourlyTaxiLater(dateTime: dateString)
        
        }
        
        
    }

    
    
    
    
    
}

extension RentalRideViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        place.coordinate.latitude
        dismiss(animated: true, completion: nil)
        
        let defaults = UserDefaults.standard
        
        if locationChoice == 0 {
            defaults.set(place.formattedAddress, forKey: Const.PI_ADDRESS)
            defaults.set(place.coordinate.latitude, forKey: Const.PI_LATITUDE)
            defaults.set(place.coordinate.longitude, forKey: Const.PI_LONGITUDE)
            pickUpLocation = place.formattedAddress!
            
             txtPickupLocation.text = place.formattedAddress
            
//            pickupBtn.setTitle("", for: UIControlState.normal)
//
//            pickupBtn.setTitle(place.formattedAddress, for: UIControlState.normal)
        } else{
            defaults.set(place.formattedAddress, forKey: Const.DR_ADDRESS)
            defaults.set(place.coordinate.latitude, forKey: Const.DR_LATITUDE)
            defaults.set(place.coordinate.longitude, forKey: Const.DR_LONGITUDE)
            // dropBtn.setTitle(place.formattedAddress, for: UIControlState.normal)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
