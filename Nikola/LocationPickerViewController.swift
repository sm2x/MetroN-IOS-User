//
//  LocationPickerViewController
//  Nikola
//
//  Created by Sutharshan on 5/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import Foundation
import GooglePlaces


protocol updateLoactionProtocalDelegate {
    
    func updateAddrLocation(with currentAddr: String, destinationAddr : String,pickupLoc : CLLocationCoordinate2D,destinationLoc : CLLocationCoordinate2D)
    
    
}




class LocationPickerViewController: BaseViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    @IBOutlet weak var pickupBtn: UIButton!
    @IBOutlet weak var dropBtn: UIButton!
    var locationChoice: Int = 0
    
    
    @IBOutlet weak var navBar: UINavigationBar!
  
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    @IBOutlet weak var txtPickupLoc: UITextField!
    
    @IBOutlet weak var letsgoButton: UIButton!
    
    @IBOutlet weak var txtDestinationLoc: UITextField!
    
    
    @IBOutlet weak var tableView_Address: UITableView!
    
    @IBOutlet weak var uiviewHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var uiviewTopViewConstrains: NSLayoutConstraint!
   
    @IBOutlet weak var gmsMapView: GMSMapView!
    
    @IBOutlet weak var locImageView: UIImageView!
    var isTapGoogleMap : Bool = false
    
     var descriptionArray = [String]()
    
    let locationManager = CLLocationManager()
    
    var pickupLoc : CLLocationCoordinate2D!
    var destinationLoc : CLLocationCoordinate2D!
    var locationMeasurements  = [CLLocation]()
    var bestEffortAtLocation: CLLocation?
    
    var sourceLocationMarker : GMSMarker!
    var destinationMarker : GMSMarker!
      var isManuallySetLocation : Bool = false
    var newLat : Double!
    var newLog : Double!
    lazy var defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.setupNavigationBar(with: "Set Your Location".localized())
        self.title = "hokdkskj"
        self.navigationController?.navigationBar.topItem?.title = "Your Title"
        
        navigationController?.navigationBar.topItem?.title = "TEST"
        
        letsgoButton.setTitle("Let's GO!".localized(), for: .normal)
        
        tableView_Address.separatorStyle = .none
        destinationMarker = GMSMarker()
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "blackBackIcon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(LocationPickerViewController.backButton), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        
        txtPickupLoc.tag = 1
        txtDestinationLoc.tag = 2
        
        
        txtPickupLoc.delegate = self
        txtDestinationLoc.delegate = self
        
//        txtDestinationLoc.becomeFirstResponder()
        
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()
            gmsMapView.delegate = self
        
        
        self.navItem.setLeftBarButton(item1, animated: true)

       
        
        
        txtPickupLoc.layer.masksToBounds = false
        txtPickupLoc.layer.shadowRadius = 1.0
        txtPickupLoc.layer.shadowColor = UIColor.black.cgColor
        txtPickupLoc.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtPickupLoc.layer.shadowOpacity = 1.0
        
        
        txtDestinationLoc.layer.masksToBounds = false
        txtDestinationLoc.layer.shadowRadius = 1.0
        txtDestinationLoc.layer.shadowColor = UIColor.black.cgColor
        txtDestinationLoc.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtDestinationLoc.layer.shadowOpacity = 1.0
        
        
        //let defaults = UserDefaults.standard
        let line = defaults.object(forKey: Const.CURRENT_ADDRESS)!
    
        if line != nil {
        let lines = defaults.object(forKey: Const.CURRENT_ADDRESS)! as? String ?? String()
        
        if !(lines ).isEmpty {
            pickupBtn.setTitle(lines, for: UIControlState.normal)
           // txtPickupLoc.text = "  \(lines)"
        }
        }
        
//        defaults.set(defaults.string(forKey: Const.CURRENT_ADDRESS), forKey: Const.PI_ADDRESS)
//        defaults.set(defaults.string(forKey: Const.CURRENT_LATITUDE), forKey: Const.PI_LATITUDE)
//        defaults.set(defaults.string(forKey: Const.CURRENT_LONGITUDE), forKey: Const.PI_LONGITUDE)
        
//        if revealViewController() != nil {
//            
//            burgerMenu.target = revealViewController()
//            burgerMenu.action = "revealToggle:"
//            
//            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//        }
     
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
      
//        
//        navBar.tintColor = UIColor.black
//        
//        UINavigationBar.appearance().barTintColor = UIColor.white
////
//        // Or, Set to new colour for just this navigation bar
//        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
//       self.navigationController?.navigationBar.barTintColor = UIColor.gray
//
         self.navigationController?.setNavigationBarHidden(true, animated: false)
//        UINavigationBar.appearance().barTintColor = UIColor.gray
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(textField.text!)
        
        
         let defaults = UserDefaults.standard
        let str = textField.text!
        
        if let txtCount = textField.text?.characters.count {
            
            if txtCount > 2 {
                
                print("character count")
                
                
                let newString = str.replacingOccurrences(of: " ", with: ",")
                
                
                let lat : String = defaults.string(forKey: Const.CURRENT_LATITUDE)!
                print(lat)
                let log : String =  defaults.string(forKey: Const.CURRENT_LONGITUDE)!
                
                
                var path : String = "\(Const.googleAutoCompleteAPIURL)input=\(newString)&sensor=false&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)&\(lat),\(log)"
                
               
                
                  path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                
                API.googlePlaceAPICall(with: path) { responseObject, error in
                    
                    //                    print(responseObject!)
                    
                    if let error = error {
                        //self.hideLoader()
                          self.showAlert(with: error.localizedDescription)
                        
                        debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                        return
                    }
                    
                    
                    if responseObject == nil {
                        print("object nil")
//                        debugPrint("Error occuring while fetching provider.service :( | \(error??.localizedDescription)")
                        return
                    }
                    
                    
                     let json = self.jsonParser.jsonParser(dicData: responseObject)
                                            print(json)
                        
                                            if let arrAddress = json["predictions"].array {
                        
                                                self.descriptionArray.removeAll()
                        
                                                for i in 0..<arrAddress.count {
                        
                        
                        
                                                    let dicAddr = arrAddress[i].dictionary
                        
                                                    let fullAddr : String = (dicAddr!["description"]?.string)!
                        
                        
                                                    print(fullAddr)
                        
                                                    self.descriptionArray.append(fullAddr)
                        
                        
                                                }
                        
                        
                        
                        
                        
                        
                                                if self.descriptionArray.count > 0 {
                                                    let addressViewHeight: CGFloat = CGFloat(30 * self.descriptionArray.count)
                        
                        
                                                    self.uiviewHeightConstrain.constant = addressViewHeight
                        
                                                    self.tableView_Address.delegate = self
                                                    self.tableView_Address.dataSource = self
                        
                                                    self.tableView_Address.reloadData()
                        
                                                    guard self.isTapGoogleMap == false else {
                                                        //
                                                        //                                self.txtDestinationlocation.text = str
                        
                                                        self.uiviewTopViewConstrains.constant = -50
                        
                                                        return
                                                    }
                                                    self.uiviewTopViewConstrains.constant = -4
                        
                                                    self.txtPickupLoc.text = str
                        
                        
                                                }
                                                else {
                        
                                                    self.uiviewHeightConstrain.constant = 0
                        
                                                }
                        
                        
                        
                        }
                        
                        
                        
                    
                    

                    
                    
                    
                }
                
                
                
                
            }
                
            else {
                self.uiviewHeightConstrain.constant = 0
            }
            
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            isTapGoogleMap = true
          
        }
            
        else if textField.tag == 2 {
            isTapGoogleMap = false
        }
        
        return true
        
        
    }
    

    func backButton(sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func pickupAction(_ sender: UIButton) {
//        
        
        let defaults = UserDefaults.standard
        defaults.set("0", forKey: Const.LOCATION_CHOICE)
            isManuallySetLocation = true;
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "setupNewLocationVC") as! setupLocationVC
//        nextViewContro‌​ller.delegate = self
////        nextViewContro‌​ller.isTapGoogleMap = true
//        self.present(nextViewContro‌​ller, animated:true, completion:nil)

        
//        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
        
        
        let visibleRegion = gmsMapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
         locImageView.image = UIImage(named: "map_pick_marker")
        locationChoice = 0
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
       // autocompleteController.autocompleteBounds = bounds
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func destinationAction(_ sender: UIButton) {
          locImageView.image = UIImage(named: "map_drop_marker")

//        let defaults = UserDefaults.standard
//        defaults.set("1", forKey: Const.LOCATION_CHOICE)
//
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "setupNewLocationVC") as! setupLocationVC
//        nextViewContro‌​ller.delegate = self
////        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
//        
//        nextViewContro‌​ller.isTapGoogleMap = false
//         self.present(nextViewContro‌​ller, animated:true, completion:nil)
//
//         self.dismiss(animated: true, completion: nil)
        
//        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        locationChoice = 1
        isManuallySetLocation = true;
        let visibleRegion = gmsMapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        autocompleteController.autocompleteBounds = bounds
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func proceedAction(_ sender: UIButton) {
        
        if (pickupBtn.titleLabel?.text?.contains("Set Pickup Location"))! {
            self.view.makeToast(message: "Choose a pickup location")
            return
        }
        
        if (dropBtn.titleLabel?.text?.contains("Choose your destination"))! {
            self.view.makeToast(message: "Choose a drop location")
            return
        }
        goToRequest()
    }
    
    func goToRequest(){
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "RequestViewController") as! RequestViewController
//        
//        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)

    /* //previous working but no back propagation
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "RequestViewNavigationController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
      */  
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sw = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.view.window?.rootViewController = sw
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "RequestViewController") as! RequestViewController
        let navigationController = UINavigationController(rootViewController: destinationController)
        sw.pushFrontViewController(navigationController, animated: true)
    }

    
}

extension LocationPickerViewController : updateLoactionProtocalDelegate {
    
   
    func updateAddrLocation(with currentAddr: String, destinationAddr: String, pickupLoc: CLLocationCoordinate2D, destinationLoc: CLLocationCoordinate2D) {
        
        
        
         let defaults = UserDefaults.standard
        
        defaults.set(currentAddr, forKey: Const.PI_ADDRESS)
        defaults.set(pickupLoc.latitude, forKey: Const.PI_LATITUDE)
        defaults.set(pickupLoc.longitude, forKey: Const.PI_LONGITUDE)
        pickupBtn.setTitle(currentAddr, for: UIControlState.normal)
        txtPickupLoc.text = currentAddr
        
        
        
         defaults.set(destinationAddr, forKey: Const.DR_ADDRESS)
        defaults.set(destinationLoc.latitude, forKey: Const.DR_LATITUDE)
        defaults.set(destinationLoc.longitude, forKey: Const.DR_LONGITUDE)
        dropBtn.setTitle(destinationAddr, for: UIControlState.normal)
        
         txtDestinationLoc.text = destinationAddr
        
        
        letsgoButton.isUserInteractionEnabled = true
        letsgoButton.backgroundColor = UIColor.black
        
        
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            //self.addressLabel.unlock()
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                //self.addressLabel.text = lines.joined(separator: "\n")
                 if self.locationChoice == 0 {
                let defaults = UserDefaults.standard
                defaults.set(lines.joined(separator: "\n"), forKey: Const.CURRENT_ADDRESS)
                defaults.set(coordinate.latitude, forKey: Const.CURRENT_LATITUDE)
                defaults.set(coordinate.longitude, forKey: Const.CURRENT_LONGITUDE)
                    defaults.set(lines.joined(separator: "\n"), forKey: Const.PI_ADDRESS)
                    defaults.set(coordinate.latitude, forKey: Const.PI_LATITUDE)
                    defaults.set(coordinate.longitude, forKey: Const.PI_LONGITUDE)
                }
                //let labelHeight = self.addressLabel.intrinsicContentSize.height
                print(" current address is -- ")
                print(lines.joined(separator: "\n"))
                
                let addr : String = lines.joined(separator: "\n")
                
                
                guard self.locationChoice == 0 else {
                    
                    self.txtDestinationLoc.text = addr
                    
                    return
                }
                
                self.txtPickupLoc.text = addr
                
                
                //                self.currentLocationAddressButton.setTitle(addr, for:.normal)
                
                
            }
        }
    }
    
    
    

    
}


extension LocationPickerViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        place.coordinate.latitude
        
        for component in place.addressComponents! {
            if component.type == "locality" {
                print(component.name)
            }
        }
        dismiss(animated: true, completion: nil)
        
        let defaults = UserDefaults.standard
        
        let bounds = GMSCoordinateBounds.init()
        let marker = GMSMarker.init()
        if locationChoice == 0 {
            defaults.set(place.formattedAddress, forKey: Const.PI_ADDRESS)
            defaults.set(place.coordinate.latitude, forKey: Const.PI_LATITUDE)
            defaults.set(place.coordinate.longitude, forKey: Const.PI_LONGITUDE)
            pickupBtn.setTitle(place.formattedAddress, for: UIControlState.normal)
            
            
            let location = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
            sourceLocationMarker.map = nil
            sourceLocationMarker = GMSMarker()
            sourceLocationMarker.position = location
            sourceLocationMarker.map = gmsMapView
            sourceLocationMarker.icon = UIImage(named: "map_pick_marker")
             gmsMapView.camera = GMSCameraPosition(target: location, zoom: 17, bearing: 0, viewingAngle: 0)
            
//            let location = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
//
////            marker.position = location
////             marker.map = gmsMapView
//             bounds.includingCoordinate(location)
//
////            let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
////            gmsMapView.moveCamera(update)
//
//            let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
//            gmsMapView.animate(with: update)
            
//            let camera = gmsMapView.camera(for: bounds, insets:.zero)
//            gmsMapView.camera = camera!
            
            txtPickupLoc.text = place.formattedAddress
            
        } else{
            defaults.set(place.formattedAddress, forKey: Const.DR_ADDRESS)
            defaults.set(place.coordinate.latitude, forKey: Const.DR_LATITUDE)
            defaults.set(place.coordinate.longitude, forKey: Const.DR_LONGITUDE)
            dropBtn.setTitle(place.formattedAddress, for: UIControlState.normal)
            
            
            let location = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
            destinationMarker.map = nil
            
            destinationMarker.position = location
            destinationMarker.map = gmsMapView
            destinationMarker.icon = UIImage(named: "map_drop_marker")
            gmsMapView.camera = GMSCameraPosition(target: location, zoom: 17, bearing: 0, viewingAngle: 0)
            
            txtDestinationLoc.text = place.formattedAddress
            
            
            letsgoButton.isUserInteractionEnabled = true
            letsgoButton.backgroundColor = UIColor.black
            
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

extension LocationPickerViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.total
        return self.descriptionArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:LocAddrListCell = tableView.dequeueReusableCell(withIdentifier: "LocAddrCell", for: indexPath) as! LocAddrListCell
        
        
        
        cell.lblName.text = self.descriptionArray[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        
        
        print(self.descriptionArray[indexPath.row])
        
        
        //        self.showLoader(str: "setting up your location")
        
        self.view.endEditing(true)
        
        self.uiviewHeightConstrain.constant = 0
        
        
        let str = self.descriptionArray[indexPath.row]
        
        
        
        
        self.showLoader(str: "fetcthing address")
        
        
        let newString = str.replacingOccurrences(of: ", ", with: ",")
        
        let trimmedString = newString.replacingOccurrences(of: " ", with: "")
        
        
        print("trimmed \(trimmedString)")
        
        let path : String = "\(Const.googleGeocoderAPIURL)address=\(trimmedString)&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)"
        
         let defaults = UserDefaults.standard
        
        API.googlePlaceAPICall(with: path) { responseObject , error in
            
            if let error = error {
                  self.showAlert(with: error.localizedDescription)
                return
            }
            
            
            let json = self.jsonParser.jsonParser(dicData: responseObject)
            
            //            print(json)
            
            
            if let array = json["results"].array, array.count > 0 {
                
                
                let dic = array[0].dictionary
                
                if let addr : String = (dic!["formatted_address"]?.string) {
                    
                    
                    
                    if self.isTapGoogleMap == true {
                        
                        
                        self.txtPickupLoc.text = "  \(addr)"
                        self.pickupBtn.setTitle("  \(addr)", for: UIControlState.normal)
                        defaults.set(addr, forKey: Const.PI_ADDRESS)
                        
                      
                    }
                    else {
                        self.txtDestinationLoc.text  = "  \(addr)"
                         self.dropBtn.setTitle("  \(addr)", for: UIControlState.normal)
                        defaults.set(addr, forKey: Const.DR_ADDRESS)
                    }
                    
                 
                    
                    
                    
                }
                
                let locationDic = dic?["geometry"]?["location"].dictionary
                
                
                
                
                if let lat : Double = (locationDic?["lat"]?.double) {
                    
                    self.newLat = lat
                    
                    
                }
                if let log : Double = (locationDic?["lng"]?.double) {
                    self.newLog = log
                }
                

                
                let deriverLoc : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.newLat, longitude: self.newLog)
                
                
                
                
                guard self.isTapGoogleMap == false else {
                    
                   
                    defaults.set(deriverLoc.latitude, forKey: Const.PI_LATITUDE)
                    defaults.set(deriverLoc.longitude, forKey: Const.PI_LONGITUDE)
//                    self.destinationLoc = deriverLoc
                    self.hideLoader()
                    return
                }
                
             
                
                defaults.set(deriverLoc.latitude, forKey: Const.DR_LATITUDE)
                defaults.set(deriverLoc.longitude, forKey: Const.DR_LONGITUDE)
                
                self.letsgoButton.isUserInteractionEnabled = true
                self.letsgoButton.backgroundColor = UIColor.black
                
//                self.pickupLoc = deriverLoc
                
                self.hideLoader()
                
            }
            
        }
        
        
    }
    
    
    
    
}


extension LocationPickerViewController : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        
        
        print("location settting")
        
        print(position.target)
        
        if(!isManuallySetLocation)
        {
            
            let deriverLoc : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
            
            
            guard locationChoice == 0 else {
                
                //reverseGeocodeCoordinate(coordinate: position.target)
                destinationLoc = deriverLoc
                
                return
            }
            
            pickupLoc = deriverLoc
        }
        else{
            isManuallySetLocation = false;
            
        }
        
        
    }
    
    
    
}


// MARK: - CLLocationManagerDelegate
extension LocationPickerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            gmsMapView.isMyLocationEnabled = true
            gmsMapView.settings.myLocationButton = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        isManuallySetLocation = true
        let newLocation = locations.first
        if(locationMeasurements.count  ==  0)
        {
            self.showLoader( str: "Fetching best location...".localized())
        }
        var horizontalAccuracyFinal = newLocation!.horizontalAccuracy
        //For test :horizontalAccuracyFinal = 500
        
        if newLocation!.horizontalAccuracy < 0 {
            return
        }
        locationMeasurements.append(newLocation!)
        if(locationMeasurements.count < 6)
        {
            if (horizontalAccuracyFinal) <= 200 {
                locationMeasurements.removeAll()
                //self.latlon = newLocation?.coordinate
                reverseGeocodeCoordinate(coordinate: (newLocation?.coordinate)!)
                gmsMapView.camera = GMSCameraPosition(target: newLocation!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                self.locationManager.stopUpdatingLocation()
                self.locationManager.delegate = nil
                bestEffortAtLocation = nil
                isManuallySetLocation = false
                sourceLocationMarker = GMSMarker()
                sourceLocationMarker.position = (newLocation?.coordinate)!
                sourceLocationMarker.map = gmsMapView
                sourceLocationMarker.icon = UIImage(named: "map_pick_marker")
                self.hideLoader()
                
            }
            else
            {
                if(bestEffortAtLocation == nil)
                {
                    bestEffortAtLocation = newLocation
                }
                else if(bestEffortAtLocation!.horizontalAccuracy >= newLocation!.horizontalAccuracy)
                {
                    bestEffortAtLocation = newLocation
                }
            }
        }
        else
        {
            locationMeasurements.removeAll()
            //            self.latlon = bestEffortAtLocation?.coordinate
            reverseGeocodeCoordinate(coordinate: (bestEffortAtLocation?.coordinate)!)
            gmsMapView.camera = GMSCameraPosition(target: bestEffortAtLocation!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            self.locationManager.stopUpdatingLocation()
            self.locationManager.delegate = nil
            bestEffortAtLocation = nil
            isManuallySetLocation = false
            sourceLocationMarker = GMSMarker()
            sourceLocationMarker.position = (bestEffortAtLocation?.coordinate)!
            sourceLocationMarker.map = gmsMapView
            sourceLocationMarker.icon = UIImage(named: "map_pick_marker")
            self.hideLoader()
            
            let alert = UIAlertController(title: "Message".localized(), message: "Unfortunately, we couldn't find the best location for you.Please select the pickup location manually by tapping pickup location field in the next screen before requesting for cabs".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}



