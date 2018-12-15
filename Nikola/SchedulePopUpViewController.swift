//
//  SchedulePopUpViewController.swift
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
import Toucan
import SDWebImage

class SchedulePopUpViewController : BaseViewController, UICollectionViewDelegate {
    
    fileprivate let reuseIdentifier = "TaxiTypeCell"
    @IBOutlet weak var pickupBtn: UIButton!
    @IBOutlet weak var dropBtn: UIButton!
    
  
    
    @IBOutlet weak var lblschedule: UILabel!
   
    
    @IBOutlet weak var timedonebtn: UIBarButtonItem!
    @IBOutlet weak var canceldatebtn: UIBarButtonItem!
    @IBOutlet weak var lblSelectDateandttime: UILabel!
    
    
    
    @IBOutlet weak var scheduleBtn: UIButton!
    
    @IBOutlet weak var datePickerBtn: UIButton!
    
    @IBOutlet weak var uiviewTimeSet: UIView!
    @IBOutlet weak var cancelbtn: UIButton!
    
    @IBOutlet weak var uiDatePicker: UIDatePicker!
    
    
    @IBOutlet weak var timeUILabel: UILabel!
    
    
    @IBOutlet weak var txtSetDate: UITextField!
    @IBOutlet weak var txtPickupLocation: UITextField!
    
    
   weak var delegate : checkstatusUpdateProtocalDelegate?
    
    @IBOutlet weak var txtDestinationLocation: UITextField!
    var locationChoice: Int = 0
    
    fileprivate  var taxiTypes : [TaxiType] = []
    fileprivate  var currentTaxi: TaxiType? = nil
    fileprivate  var currentSelection : Int = 0
    fileprivate  var currentIndexPath : IndexPath? = nil
    fileprivate  var service_id: String = "", p_address: String = "", d_address: String = "", dateString: String = ""
    @IBOutlet weak var taxiTypeCollectionView: UICollectionView!
    weak var defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taxiTypeCollectionView.dataSource = self
        taxiTypeCollectionView.delegate = self
//        scheduleBtn.setTitle("Schedule".localized(), for: .normal)
//        cancelbtn.setTitle("Cancel".localized(), for: .normal)
//        lblschedule.text = "Schedule a new ride".localized()
        
        txtPickupLocation.placeholder = "Set Pickup Location".localized()
        txtDestinationLocation.placeholder = "Choose your destination".localized()
//        lblSelectDateandttime.text = "Select Date and time".localized()
        
        
        uiDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        
        let taxiTypesString: String = DATA().getTaxiTypesData()
        
        if !taxiTypesString.isEmpty {
            let taxiTypesJson : JSON = JSON.init(parseJSON: taxiTypesString)
            
            let typesArray = taxiTypesJson.arrayValue
            for type: JSON in typesArray {
                self.taxiTypes.append(TaxiType.init(taxiObj: type))
            }
            let taxi: TaxiType = taxiTypes[0]
            
            let defaults = UserDefaults.standard
            defaults.set(taxi.id, forKey: Const.Params.SERVICE_TYPE)
            self.service_id = taxi.id
            
            self.taxiTypeCollectionView.reloadData()
            self.taxiTypeCollectionView.collectionViewLayout.invalidateLayout()
            
            if self.taxiTypes.count == 0 {
                getTaxiTypes()
            }
        }else{
            getTaxiTypes()
        }
        
        
        
        
        txtPickupLocation.layer.masksToBounds = false
        txtPickupLocation.layer.shadowRadius = 1.0
        txtPickupLocation.layer.shadowColor = UIColor.black.cgColor
        txtPickupLocation.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtPickupLocation.layer.shadowOpacity = 1.0
        
        
        txtDestinationLocation.layer.masksToBounds = false
        txtDestinationLocation.layer.shadowRadius = 1.0
        txtDestinationLocation.layer.shadowColor = UIColor.black.cgColor
        txtDestinationLocation.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtDestinationLocation.layer.shadowOpacity = 1.0
        
        txtSetDate.layer.masksToBounds = false
        txtSetDate.layer.shadowRadius = 1.0
        txtSetDate.layer.shadowColor = UIColor.black.cgColor
        txtSetDate.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtSetDate.layer.shadowOpacity = 1.0
        
        
        
        
        let defaults = UserDefaults.standard
        let line = defaults.object(forKey: Const.CURRENT_ADDRESS)!
        
        if line != nil {
            let lines = defaults.object(forKey: Const.CURRENT_ADDRESS)! as? String ?? String()
            
            if !(lines ?? "").isEmpty {
                
                
                
                
                
                //                 let lat = defaults.object(forKey: Const.CURRENT_LONGITUDE)!
                //                let log = defaults.object(forKey: Const.CURRENT_LATITUDE)!
                //
                //                print(lat)
                //                print(log)
                //
                //                txtPickupLocation.text = lines
                //
                //                defaults.set(txtPickupLocation.text, forKey: Const.PI_ADDRESS)
                //
                //                defaults.set(lat, forKey: Const.PI_LATITUDE)
                //                defaults.set(log, forKey: Const.PI_LONGITUDE)
                
                // p_address = lines
            }
        }
        
        
        
        
        //        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //        layout.itemSize = CGSize(width: 94, height: 134)
        //        layout.scrollDirection = .horizontal
        //
        //        taxiTypeCollectionView.collectionViewLayout = layout
        
        
        
        
        //        datePickerBtn.layer.masksToBounds = false
        //        datePickerBtn.layer.shadowRadius = 1.0
        //        datePickerBtn.layer.shadowColor = UIColor.black.cgColor
        //        datePickerBtn.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        //        datePickerBtn.layer.shadowOpacity = 1.0
        
        
        
    }
    @IBAction func scheduleBtnAction(_ sender: UIButton) {
        
        
        if dateString.isEmpty || p_address.isEmpty || d_address.isEmpty || service_id.isEmpty {
            self.view.makeToast(message: "Please enter all the details")
        }else {
            self.requestTaxiLater(dateTime:  dateString)
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func datePickerAction(_ sender: UIButton) {
        
        
        let today: Date = Date()
        
        let newDate : Date = Calendar.current.date(byAdding: .minute, value: Const.LATER_MINUTES_TO_ADD, to: Date())!
        
        uiviewTimeSet.isHidden = false
        
        
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
        //            // do something after tapping done
        //            //date.description
        //            //date.description(with: Locale?)
        //            let dFDisplay = DateFormatter()
        //            dFDisplay.dateFormat = "  MMM dd, yyyy hh:mm"
        //            let dateDisplayString: String = dFDisplay.string(from: date)
        //            self.datePickerBtn.setTitle(dateDisplayString, for: .normal)
        //
        //            let dateFormatter = DateFormatter()
        //            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        //            let dateString: String = dateFormatter.string(from: date)
        //            self.requestTaxiLater(dateTime: dateString)
        //        }
    }
    
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        
        self.dateString = dateFormatter.string(from: sender.date)
        
        print(self.dateString)
        
        
        self.timeUILabel.text = self.dateString
        
        //        self.requestTaxiLater(dateTime: dateString)
        
    }
    
    
    
    func requestTaxiLater(dateTime: String){
        
        let defaults = UserDefaults.standard
        
        do{
            API.requestTaxiLater(dateTime:dateTime, serviceType: self.service_id, completionHandler: {
                json, error in
                
                if let error = error {
                    //self.hideLoader()
                    self.showAlert(with :error.localizedDescription)
                    debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                }else {
                    if let json = json {
                        let status = json[Const.STATUS_CODE].boolValue
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
                //
                
            })
        }catch {
            print("some error in airport request flow")
        }
    }
    
    func showRideScheduledDialog(){
        let alert = UIAlertController(title: "", message: "Trip Scheduled Successfully!", preferredStyle: .alert)
        let confirmAction = UIAlertAction(
        title: "Ok", style: UIAlertActionStyle.default) { [weak self] (action) in
            
            self?.delegate?.checkStatusMethod()
            self?.defaults?.set("scdeduledRequest", forKey: "requestType")
            self?.view.removeFromSuperview()
            
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pickupAction(_ sender: UIButton) {
        locationChoice = 0
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func destinationAction(_ sender: UIButton) {
        locationChoice = 1
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func getTaxiTypes(){
        
        API.getTaxiTypes{ json, error in
            if let error = error {
                self.showAlert(with :error.localizedDescription)
                //  print(error.debugDescription)
                
                return
            }
            
            let status = json![Const.STATUS_CODE].boolValue
            let statusMessage = json![Const.STATUS_MESSAGE].stringValue
            if(status){
                DATA().putTaxiTypesData(request: json!["services"].rawString()!)
                let typesArray = json!["services"].arrayValue
                for type: JSON in typesArray {
                    self.taxiTypes.append(TaxiType.init(taxiObj: type))
                }
                self.taxiTypeCollectionView.reloadData()
                self.taxiTypeCollectionView.collectionViewLayout.invalidateLayout()
                print(json ?? "error in taxi_types json")
                
            }else{
                print(statusMessage)
                print(json ?? "json empty")
                var msg = json![Const.DATA].rawString()!
                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                
                self.view.makeToast(message: msg)
            }
        }
    }
    
    
    @IBAction func cancelButtionAction(_ sender: Any) {
        
        uiviewTimeSet.isHidden = true
    }
    
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        uiviewTimeSet.isHidden = true
        
        datePickerBtn.setTitle(self.dateString,for: .normal)
    }
    
    
}

extension SchedulePopUpViewController: GMSAutocompleteViewControllerDelegate {
    
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
            
            txtPickupLocation.text = place.formattedAddress
            
            
            //            pickupBtn.setTitle(place.formattedAddress, for: UIControlState.normal)
            self.p_address = place.formattedAddress!
        } else{
            
            print( place.coordinate.latitude)
            print( place.coordinate.longitude)
            
            defaults.set(place.formattedAddress, forKey: Const.DR_ADDRESS)
            defaults.set(place.coordinate.latitude, forKey: Const.DR_LATITUDE)
            defaults.set(place.coordinate.longitude, forKey: Const.DR_LONGITUDE)
            //            dropBtn.setTitle(place.formattedAddress, for: UIControlState.normal)
            
            txtDestinationLocation.text = place.formattedAddress
            self.d_address = place.formattedAddress!
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

// MARK:- UICollectionViewDataSource Delegate
extension SchedulePopUpViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.taxiTypes.count)
        return self.taxiTypes.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        currentSelection = indexPath.row
        if currentIndexPath != nil {
            taxiTypeCollectionView.reloadItems(at: [currentIndexPath! as IndexPath])
        }
        collectionView.reloadItems(at: [indexPath as IndexPath])
        currentIndexPath = indexPath as IndexPath
        collectionView.reloadItems(at: [indexPath as IndexPath])
        
        let taxi: TaxiType = taxiTypes[indexPath.row]
        
        let defaults = UserDefaults.standard
        defaults.set(taxi.id, forKey: Const.Params.SERVICE_TYPE)
        self.service_id = taxi.id
        
        //let tel: String = taxi.type
        //        let btnText = "Request \(tel)"
        //        self.scheduleBtn.setTitle(btnText, for: UIControlState.normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TaxiTypeCell
        //cell.backgroundColor = UIColor.red
        
        let taxi: TaxiType = taxiTypes[indexPath.row]
        cell.name.text = taxi.type
        cell.amount.text = "$ " + taxi.min_fare
        
        //        cell.bgImageView.layer.cornerRadius = cell.bgImageView.frame.height / 2
        //        cell.bgImageView.clipsToBounds = true
        
        
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height / 2
        cell.imageView.clipsToBounds = true
        
        
        if !((taxi.picture ?? "").isEmpty)
        {
            let url = URL(string: taxi.picture.decodeUrl())!
            
            print(url)
            
            cell.imageView.sd_setImage(with: url as URL?, placeholderImage:  UIImage(named: "taxi")!)
            
            
        }else{
            cell.imageView.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }
        
        if currentSelection == indexPath.row {
            currentIndexPath = indexPath
            cell.bgBorder?.alpha = 1
        } else {
            cell.bgBorder?.alpha = 0
        }
        
        if currentIndexPath == nil {
            currentIndexPath = indexPath
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        didDeselectItemAtIndexPath indexPath: IndexPath) {
        
    }
}


