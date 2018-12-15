//
//  AirportRideViewController.Swift
//  Nikola
//
//  Created by Sutharshan Ram on 11/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
//import DatePickerDialog
import DateTimePicker
import GooglePlaces
import SwiftyJSON
import AlamofireImage
import DropDown

class AirportRideViewController : BaseViewController, UICollectionViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    
    fileprivate let reuseIdentifier = "TaxiTypeCell"
    @IBOutlet weak var pickupBtn: UIButton!
    @IBOutlet weak var airportListBtn: UIButton!
    
    @IBOutlet weak var bookNowBtn: UIButton!
    
    @IBOutlet weak var goingToAirportLabel: UILabel!
    
    @IBOutlet weak var comingOutLabel: UILabel!
    
    @IBOutlet weak var taxiTypeBtn: UIButton!
    
    @IBOutlet weak var tollGatesCountLabel: UILabel!
    @IBOutlet weak var packagePriceLabel: UILabel!
    @IBOutlet weak var datePickerBtn: UIButton!
    
    @IBOutlet weak var locationTextView: UITextField!
    var locationChoice: Int = 0
    
    var taxiTypes : [TaxiType] = []
    var taxiTypesStrings : [String] = []
    var airPortsListData : [AirPort] = []
    var airPortsListStrings : [String] = []
    var locationsListData : [LocationItem] = []
    var locationsListStrings : [String] = []
    var currentTaxi: TaxiType? = nil
    var currentSelection : Int = 0
    var currentIndexPath : IndexPath? = nil
    @IBOutlet weak var taxiTypeCollectionView: UICollectionView!
    
    let airportsDropdown: DropDown = DropDown()
    let locationsDropdown: DropDown = DropDown()
    let taxiTypesDropDown: DropDown = DropDown()
    
    var dateString : String = ""
    
    
    var s_address: String = "", d_address: String = ""
    var s_point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0) , d_point: CLLocationCoordinate2D =  CLLocationCoordinate2DMake(0.0, 0.0)
    
    var airport_package_id: String = ""
    var airport_details_id: String = "", location_details_id: String = "", service_id: String = ""
    
    var sc_address: String = "", dc_address: String = ""
    
    var isAirport: Bool = true
    
    lazy var currency : String = ""
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    @IBOutlet weak var airportSetUIView: UIView!
    
    
    @IBOutlet weak var airportBtnUIView: UIView!
    
    
    @IBOutlet weak var selectTaxiUIView: UIView!
    @IBOutlet weak var uiviewTimeSet: UIView!
    
    
    @IBOutlet weak var uiDatePicker: UIDatePicker!
    
    
    @IBOutlet weak var timeUILabel: UILabel!
    
    var isViewType : Bool!
    weak var defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            
            
            //            }
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        locationTextView.delegate = self
        locationTextView.tag = 0
        
        uiDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        
        let btn1 = UIButton(type: .custom)
        
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let defaults = UserDefaults.standard
        
        if let curr : String = defaults.string(forKey: Const.CURRENCEY) {
            
            print(curr)
            
            currency = curr
            
        }
        
       // let id : String = defaults.string(forKey: Const.Params.ID)!
        
        
        
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
        
        
        
        
        
        let item1 = UIBarButtonItem(customView: btn1)
        
        self.navItem.setLeftBarButton(item1, animated: true)
        //
        //
        //        self.navBar.tintColor = UIColor.darkGray
        
        
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
        
        
        airportSetUIView.layer.masksToBounds = false
        airportSetUIView.layer.shadowRadius = 1.0
        airportSetUIView.layer.shadowColor = UIColor.black.cgColor
        airportSetUIView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        airportSetUIView.layer.shadowOpacity = 1.0
        
        
        airportBtnUIView.layer.masksToBounds = false
        airportBtnUIView.layer.shadowRadius = 1.0
        airportBtnUIView.layer.shadowColor = UIColor.black.cgColor
        airportBtnUIView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        airportBtnUIView.layer.shadowOpacity = 1.0
        
        
        selectTaxiUIView.layer.masksToBounds = false
        selectTaxiUIView.layer.shadowRadius = 1.0
        selectTaxiUIView.layer.shadowColor = UIColor.black.cgColor
        selectTaxiUIView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        selectTaxiUIView.layer.shadowOpacity = 1.0
        
        
        locationTextView.layer.masksToBounds = false
        locationTextView.layer.shadowRadius = 1.0
        locationTextView.layer.shadowColor = UIColor.black.cgColor
        locationTextView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        locationTextView.layer.shadowOpacity = 1.0
        
        
        getTaxiTypes(initCall: true)
        getAirPortsList(initCall: true)
        
        airportsDropdown.anchorView = airportListBtn
        airportsDropdown.dataSource = []
        
        taxiTypesDropDown.anchorView = taxiTypeBtn
        taxiTypesDropDown.dataSource = []
        
        locationsDropdown.anchorView = airportListBtn
        locationsDropdown.direction = .top
        locationsDropdown.dataSource = []
        
        locationTextView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        airportsDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.airportListBtn.setTitle("\(item)", for: .normal)
            self.airport_details_id = self.airPortsListData[index].id
            self.getAirportFare()
            
            if self.isAirport {
                self.d_address = "\(item)"
                self.dc_address =  "\(item)"
                
                
            }else{
                self.s_address = "\(item)"
                self.sc_address = "\(item)"
            }
            
        }
        
        locationsDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.locationTextView.text = "\(item)"
            self.location_details_id = self.locationsListData[index].id
            self.getAirportFare()
            
            if self.isAirport {
                self.s_address = "\(item)"
                 self.sc_address = "\(item)"
                
            }else{
                self.d_address = "\(item)"
                self.dc_address =  "\(item)"
            }
        }
        
        //        self.taxiTypeBtn.setTitle("\(taxiTypesStrings[0])", for: .normal)
        //        self.service_id = self.taxiTypes[0].id
        
        taxiTypesDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.taxiTypeBtn.setTitle("\(item)", for: .normal)
            self.service_id = self.taxiTypes[index].id
            self.getAirportFare()
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
            getLocationsList(key: key)
        }else{
            tollGatesCountLabel.text = "--"
            packagePriceLabel.text = "--"
            airport_package_id = ""
            self.locationsDropdown.hide()
        }
        
    }
    
    @IBAction func airportDirectionToggleAction(_ sender: UISwitch) {
        
        if sender.isOn {
            isAirport = true
            goingToAirportLabel.textColor = UIColor.init(hex: "FE9700")
            comingOutLabel.textColor = UIColor.black
            locationTextView.placeholder = "Set Pickup Location"
        }else{
            isAirport = false
            comingOutLabel.textColor = UIColor.init(hex: "FE9700")
            goingToAirportLabel.textColor = UIColor.black
            locationTextView.placeholder = "Set Drop Location"
        }
        
    }
    @IBAction func bookNowBtnAction(_ sender: UIButton) {
        
        if airport_details_id.isEmpty || location_details_id.isEmpty || service_id.isEmpty {
            self.view.makeToast(message: "Please enter all the details")
        }else {
            //self.setLatLonFromAddress()
            self.requestAirportTaxi()
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
    
    @IBAction func airportListBtnAction(_ sender: UIButton) {
        if airPortsListStrings.count > 0{
            airportsDropdown.show()
        }else{
            self.getAirPortsList(initCall: false)
        }
    }
    @IBAction func datePickerAction(_ sender: UIButton) {
        
        if airport_details_id.isEmpty || location_details_id.isEmpty || service_id.isEmpty {
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
            
            
            
            //        let today: Date = Date()
            //        //let picker = DateTimePicker.show()
            //        let picker = DateTimePicker.show(selected: today, minimumDate: today)
            //        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
            //        picker.isDatePickerOnly = false // to hide time and show only date picker
            //        picker.completionHandler = { date in
            //
            //            //date.description
            //            //date.description(with: Locale?)
            //            let dateFormatter = DateFormatter()
            //            //dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss"
            //            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            //            let dateString: String = dateFormatter.string(from: date)
            //            //self.datePickerBtn.setTitle(dateString, for: .normal)
            //
            //            self.requestAirportTaxiLater(dateTime: dateString)
            //        }
        }
    }
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        
        self.dateString = dateFormatter.string(from: sender.date)
        
        self.timeUILabel.text = dateString
        
        
        
        
        //        self.dateString = dateString
        
    }
    
    
    
    @IBAction func cancelButtionAction(_ sender: Any) {
        
        uiviewTimeSet.isHidden = true
    }
    
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        uiviewTimeSet.isHidden = true
        
        
        if dateString.isEmpty {
            
        }
        else {
            
            self.requestAirportTaxiLater(dateTime: dateString)
            
        }
        
        
        
        
    }
    
    
    
    
    
    @IBAction func pickupAction(_ sender: UIButton) {
        locationChoice = 0
        let autocompleteController = GMSAutocompleteViewController()
        // autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func destinationAction(_ sender: UIButton) {
        locationChoice = 1
        let autocompleteController = GMSAutocompleteViewController()
        //  autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func getTaxiTypes(initCall: Bool){
        
        API.getTaxiTypes{ json, error in
            do {
                
                if let error = error {
                   
                    self.showAlert(with :error.localizedDescription)
                   // print(error.debugDescription)
                    return
                }
                else {
                    
                    if let json = json {
                        let status =  json[Const.STATUS_CODE].boolValue
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
                            var msg = json[Const.DATA].rawString()!
                            msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                            
                            self.view.makeToast(message: msg)
                        }
                    }else {
                        
                        print("invalid json :(")
                    }
                    
                }
                
               
            }catch {
                print(error)
            }
        }
    }
    
    func getAirPortsList(initCall: Bool){
        
        API.getAirports{ json, error in
            
            if let error = error {
                self.showAlert(with :error.localizedDescription)
                //print(error.debugDescription)
                return
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        //DATA().putAirPortsListData(request: json!["airport_details"].rawString()!)
                        let airPortsArray = json["airport_details"].arrayValue
                        
                        self.airPortsListData.removeAll()
                        self.airPortsListStrings.removeAll()
                        for type: JSON in airPortsArray {
                            let airport: AirPort = AirPort.init(jObj: type)
                            self.airPortsListData.append(airport)
                            self.airPortsListStrings.append(airport.address)
                        }
                        
                        if self.airPortsListStrings.count > 0 {
                            if self.airport_details_id.isEmpty {
                                self.airport_details_id = self.airPortsListData[0].id
                                if self.isAirport {
                                    self.s_address = self.airPortsListData[0].address
                                }else{
                                    self.d_address = self.airPortsListData[0].address
                                }
                            }
                            self.airportsDropdown.dataSource = self.airPortsListStrings
                            if !initCall {
                                self.airportsDropdown.show()
                            }
                        }else{
                            self.airportsDropdown.dataSource = self.airPortsListStrings
                            self.airportsDropdown.hide()
                        }
                        
                        
                        print(json ?? "error in airports json")
                        
                        //setLatLonFromAddress
                        
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.ERROR].rawString()!
                        
                        self.view.makeToast(message: msg)
                    }
                }else {
                    print("invalid json :(")
                }
                
                
            }
            
            
        }
    }
    
    func getLocationsList(key: String){
        
        API.getLocations(key: key){ json, error in
            
            
            if let error = error {
                self.showAlert(with :error.localizedDescription)
               // print(error.debugDescription)
                
             return
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        //                DATA().putAirPortsListData(request: json!["location_details"].rawString()!)
                        let dataArray = json["location_details"].arrayValue
                        self.locationsListData.removeAll()
                        self.locationsListStrings.removeAll()
                        for type: JSON in dataArray {
                            
                            let locationItem: LocationItem = LocationItem.init(jObj: type)
                            if locationItem.address.lowercased().contains(key.lowercased()){
                                self.locationsListData.append(locationItem)
                                self.locationsListStrings.append(locationItem.address)
                            }
                        }
                        
                        if self.locationsListStrings.count > 0 {
                            if self.location_details_id.isEmpty {
                                self.location_details_id = self.locationsListData[0].id
                                
                                if self.isAirport {
                                    self.d_address = self.locationsListData[0].address
                                }else{
                                    self.s_address = self.locationsListData[0].address
                                }
                            }
                            self.locationsDropdown.dataSource = self.locationsListStrings
                            self.locationsDropdown.show()
                        }else{
                            self.locationsDropdown.dataSource = self.locationsListStrings
                            self.locationsDropdown.hide()
                        }
                        
                        print(json ?? "error in locations json")
                        
                        //setLatLonFromAddress
                        
                    }else{
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = json[Const.ERROR].rawString()!
                        
                        self.view.makeToast(message: msg)
                    }
                    
                    
                }else {
                    print("invalid json :(")
                }
            }
            
            
          
        }
    }
    
    //func setLatLonFromAddressAndRequest(){//(address: String, pickup: Bool) {
    
    //        if pickup {
    //            self.s_address = address
    //        }else{
    //            self.d_address = address
    //        }
    func requestAirportTaxi(){
        let defaults = UserDefaults.standard
        
      //  print(self.s_address)
        do{
            self.showAnimation()
            
            print(self.s_address)
            print(self.d_address)
            
            print(self.sc_address)
            print(self.dc_address)
            
            
            
            let newString = self.sc_address.replacingOccurrences(of: " ", with: ",")

            let trimmedString = newString.replacingOccurrences(of: " ", with: "")


            print("trimmed \(trimmedString)")


            var path : String = "\(Const.googleGeocoderAPIURL)address=\(newString)&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)"


             path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            print(path)


            API.googlePlaceAPICall(with: path) { responseObject, error in

                
                if let error = error {
                    
                    self.showAlert(with :error.localizedDescription)
                    print(error.debugDescription)
                    return
                }else {
                    let json = self.jsonParser.jsonParser(dicData: responseObject)
                    
                    //            print(json)
                    
                    
                    defaults.set(self.s_address, forKey: Const.PI_ADDRESS)
                    
                    if let array = json["results"].array, array.count > 0 {
                        
                        
                        let dic = array[0].dictionary
                        
                        
                        let locationDic = dic?["geometry"]?["location"].dictionary
                        
                        
                        
                        if let lat : Double = (locationDic?["lat"]?.double) {
                            
                            print(lat)
                            defaults.set(lat, forKey: Const.PI_LATITUDE)
                            
                        }
                        if let log : Double = (locationDic?["lng"]?.double) {
                            
                            print(log)
                            
                            defaults.set(log, forKey: Const.PI_LONGITUDE)
                            
                        }
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    let newString1 = self.dc_address.replacingOccurrences(of: " ", with: ",")
                    
                    let trimmedString1 = newString1.replacingOccurrences(of: " ", with: "")
                    
                    
                    print("trimmed \(trimmedString1)")
                    
                    
                    var path1 : String = "\(Const.googleGeocoderAPIURL)address=\(newString1)&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)"
                    
                    
                    path1 = path1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    
                    print(path1)
                    
                    
                    
                    
                    
                    API.googlePlaceAPICall(with: path1) { responseObject, error in
                        
                        if let error = error {
                            self.showAlert(with: error.localizedDescription)
                            // print(error.debugDescription)
                            return
                        }
                        
                        
                        let json = self.jsonParser.jsonParser(dicData: responseObject)
                        
                        //            print(json)
                        
                        defaults.set(self.d_address, forKey: Const.DR_ADDRESS)
                        
                        
                        
                        
                        if let array = json["results"].array, array.count > 0 {
                            
                            
                            let dic = array[0].dictionary
                            
                            
                            let locationDic = dic?["geometry"]?["location"].dictionary
                            
                            
                            
                            if let lat : Double = (locationDic?["lat"]?.double) {
                                
                                print(lat)
                                defaults.set(lat, forKey: Const.DR_LATITUDE)
                                
                            }
                            if let log : Double = (locationDic?["lng"]?.double) {
                                
                                print(log)
                                defaults.set(log, forKey: Const.DR_LONGITUDE)
                                
                            }
                            
                            
                        }
                        
                        print(defaults.string(forKey: Const.PI_LATITUDE)!)
                        
                        
                        self.startTimer()
                        API.requestAirportTaxi(serviceType: self.service_id, airportPackageId: self.airport_package_id, completionHandler: {
                            json, error in
                            if let error = error {
                                self.showAlert(with: error.localizedDescription)
                               // print(error.debugDescription)
                                return
                            }
                            
                            if let json = json {
                                
                                let status = json[Const.STATUS_CODE].boolValue
                                let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                                if(status){
                                    
                                    print(json ?? "error in requestAirportTaxi json")
                                    
                                }else{
                                    let vc = self.childViewControllers.last
                                    vc!.willMove(toParentViewController: nil)
                                    vc?.view.removeFromSuperview()
                                    vc?.removeFromParentViewController()
                                    
                                    print(statusMessage)
                                    print(json ?? "json empty")
                                    
                                    // if let error_code =
                                    
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
                                
                                debugPrint("invalid json :(")
                                
                            }
                            
                            
                            
                            
                        })
                        
                    }

                }
                

            }
            
            
            
            
            
        }catch {
            print("some error in airport request flow")
        }
    }
    
    
    
    
    
    
    
    
    func requestAirportTaxiLater(dateTime: String){
        
        let defaults = UserDefaults.standard
        
        print(self.s_address)
        print(self.d_address)
        
        do{
        
            print(self.sc_address)
            print(self.dc_address)
            
            
            let newString = self.sc_address.replacingOccurrences(of: " ", with: ",")
            
            let trimmedString = newString.replacingOccurrences(of: " ", with: "")
            
            
            print("trimmed \(trimmedString)")
            
            
            let path : String = "\(Const.googleGeocoderAPIURL)address=\(newString)&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)"
            
            
            print(path)
            
            
            API.googlePlaceAPICall(with: path) { responseObject, error in
                
                //                    print(responseObject!)
                
                //                let json = self.jsonParser.jsonParser(dicData: responseObject!)
                
                
                let json = self.jsonParser.jsonParser(dicData: responseObject)
                
                //            print(json)
                
                
                defaults.set(self.s_address, forKey: Const.PI_ADDRESS)
                
                if let array = json["results"].array, array.count > 0 {
                    
                    
                    let dic = array[0].dictionary
                    
                    
                    let locationDic = dic?["geometry"]?["location"].dictionary
                    
                    
                    
                    if let lat : Double = (locationDic?["lat"]?.double) {
                        
                        print(lat)
                        defaults.set(lat, forKey: Const.PI_LATITUDE)
                        
                    }
                    if let log : Double = (locationDic?["lng"]?.double) {
                        
                        print(log)
                        
                        defaults.set(log, forKey: Const.PI_LONGITUDE)
                        
                    }
                    
                    
                    
                    
                    
                    
                }
                
                
                let newString1 = self.dc_address.replacingOccurrences(of: " ", with: ",")
                
                let trimmedString1 = newString1.replacingOccurrences(of: " ", with: "")
                
                
                print("trimmed \(trimmedString1)")
                
                
                let path1 : String = "\(Const.googleGeocoderAPIURL)address=\(newString1)&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)"
                
                
                print(path1)
                
                
                
                
                
                API.googlePlaceAPICall(with: path1) { responseObject, error in
                    
                    //                    print(responseObject!)
                    
                    //                let json = self.jsonParser.jsonParser(dicData: responseObject!)
                    
                    
                    let json = self.jsonParser.jsonParser(dicData: responseObject)
                    
                    //            print(json)
                    
                    defaults.set(self.d_address, forKey: Const.DR_ADDRESS)
                    
                    
                    
                    
                    if let array = json["results"].array, array.count > 0 {
                        
                        
                        let dic = array[0].dictionary
                        
                        
                        let locationDic = dic?["geometry"]?["location"].dictionary
                        
                        
                        
                        if let lat : Double = (locationDic?["lat"]?.double) {
                            
                            print(lat)
                            defaults.set(lat, forKey: Const.DR_LATITUDE)
                            
                        }
                        if let log : Double = (locationDic?["lng"]?.double) {
                            
                            print(log)
                            defaults.set(log, forKey: Const.DR_LONGITUDE)
                            
                        }
                        
                        
                    }
                    
                    print(defaults.string(forKey: Const.PI_LATITUDE)!)
                    
                    
                    API.requestAirportTaxiLater(dateTime:dateTime, serviceType: self.service_id, airportPackageId: self.airport_package_id, completionHandler: {
                        json, error in
                        
                        
                        let status = json![Const.STATUS_CODE].boolValue
                        let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                        if(status){
                            
                            self.showRideScheduledDialog()
                            print(json ?? "error in requestAirportTaxi json")
                            
                        }else{
                            
                            print(statusMessage)
                            print(json ?? "json empty")
                            var msg = json![Const.ERROR].rawString()!
                            
                            self.view.makeToast(message: msg)
                        }
                        
                        
                        
                    })
                    
                }
                
                
                
                
                
            }
            
            
            
            
         
            
            
            
        }catch {
            print("some error in airport request flow")
        }
    }
    
    func showRideScheduledDialog(){
        let alert = UIAlertController(title: "", message: "Trip Scheduled Successfully!", preferredStyle: .alert)
        let confirmAction = UIAlertAction(
        title: "Ok", style: UIAlertActionStyle.default){[weak self]  (action) in
            
            UserDefaults.standard.set(true, forKey: "checkStatus")
             self?.defaults?.set("scdeduledRequest", forKey: "requestType")
            self?.goToDashboard()
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAirportFare(){
        
        API.getFareAirportPackage(airport_details_id: airport_details_id, location_details_id: location_details_id, service_id: service_id,completionHandler: { json, error in
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        let airportPrice: JSON = json["airport_price_details"]
                        
                        self.airport_package_id = airportPrice["id"].stringValue
                        self.tollGatesCountLabel.text = airportPrice["number_tolls"].stringValue
                        
                        if let currency: String = UserDefaults.standard.string(forKey: "currency") {
                            
                            self.packagePriceLabel.text = "\(currency) " + airportPrice["price"].stringValue
                            
                        }
                        else {
                            self.packagePriceLabel.text = airportPrice["price"].stringValue
                        }
                        
                        
                        
                        print(json ?? "error in locations json")
                        
                    }else{
                        
                        self.airport_package_id = ""
                        self.tollGatesCountLabel.text = "--"
                        self.packagePriceLabel.text = "--"
                        
                        print(statusMessage)
                        print(json ?? "json empty")
                        
                        if let error_code = json[Const.ERROR_CODE].int {
                            
                            if error_code == 101 {
                                if let error_messages : String = json[Const.NEW_ERROR].rawString() {
                                     self.view.makeToast(message: error_messages)
                                }
                                else {
                                    
                                    if let error : String = json[Const.ERROR].rawString() {
                                        
                                            self.view.makeToast(message: error)
                                    }
                                    
                                   
                                }
                                
                            }
                        }
                        
                       
                        
                       
                        
                       
                    }
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        //
        //        navBar.tintColor = UIColor.black
        //
        navBar.barTintColor = UIColor.white
        //
        // Or, Set to new colour for just this navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
    }
    
    
    
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            print("Full checkrequeststatus JSON")
            print(json ?? "json null")
            
            if json == nil {
                
                print("nil")
                return
            }
            
            let status = json![Const.STATUS_CODE].boolValue
            let statusMessage = json![Const.STATUS_MESSAGE].stringValue
            if(status){
                
                
                
                
                
                var requestDetail: RequestDetail = RequestDetail()
                
                let jsonAry:[JSON]  = json![Const.DATA].arrayValue
                let defaults = UserDefaults.standard
                
                if jsonAry.count > 0 {
                    let driverData = jsonAry[0]
                    if driverData.exists() {
                        
                        defaults.set(driverData["request_id"].stringValue, forKey: Const.Params.REQUEST_ID)
                        defaults.set(driverData["provider_id"].stringValue, forKey: Const.Params.DRIVER_ID)
                        requestDetail.initDriver(rqObj: driverData)
                    }
                    
                    let invoiceAry:[JSON]  = json![Const.INVOICE].arrayValue
                    if invoiceAry.count > 0 {
                        let invoiceData = invoiceAry[0]
                        print("invoice json")
                        print(invoiceData.rawString() ?? "invoiceData null")
                        defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                        requestDetail.initInvoice(rqObj: invoiceData)
                    }
                    self.processStatus(json: json!, tripStatus:requestDetail.tripStatus)
                } else {
                    requestDetail.tripStatus = Const.NO_REQUEST
                    let defaults = UserDefaults.standard
                    defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
                    let vc = self.childViewControllers.last
                    if (vc != nil) {
                        vc!.willMove(toParentViewController: nil)
                        vc?.view.removeFromSuperview()
                        vc?.removeFromParentViewController()
                    }
                }
                
                
                
                //self.goToDashboard()
                //self.view.makeToast(message: "Logged In")
            }else{
                print(statusMessage)
                print(json ?? "json empty")
                var msg = json![Const.DATA].rawString()!
                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                
                self.view.makeToast(message: msg)
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
            print("No Providers found please try after some time!")
            if (popOverVC != nil) {
                popOverVC?.removeFromParentViewController()
            }
            
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
        //        popOverVC?.isViewTypeHour = true
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
    
}
