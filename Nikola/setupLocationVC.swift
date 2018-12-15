//
//  setupLocationVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 9/1/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import GoogleMaps

class setupLocationVC: BaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
   
    
    var delegate : updateLoactionProtocalDelegate!
    
    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var locImageView: UIImageView!
    @IBOutlet weak var txtPickuplocation: UITextField!
    
    @IBOutlet weak var txtDestinationlocation: UITextField!
    
    
    @IBOutlet weak var uiviewTopViewConstrains: NSLayoutConstraint!
    
    @IBOutlet weak var tableView_Address: UITableView!
    
    @IBOutlet weak var uiviewHeightConstrain: NSLayoutConstraint!
    
    
    @IBOutlet weak var uiviewAddrList: UIView!
    
    var isTapGoogleMap : Bool = false
    
    var descriptionArray = [String]()
    
    var marker : GMSMarker!
    
    var pickupLoc : CLLocationCoordinate2D!
    var destinationLoc : CLLocationCoordinate2D!
    
    var newLat : Double!
    var newLog : Double!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "blackBackIcon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(setupLocationVC.backButton), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        
        
        self.navItem.setLeftBarButton(item1, animated: true)
        
        
        
        txtPickuplocation.delegate = self
        txtDestinationlocation.delegate = self
        
        
        txtPickuplocation.tag = 1
        txtDestinationlocation.tag = 2
        
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()
        mapView.delegate = self
        
        let defaults = UserDefaults.standard
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        var dr_lat: String = ""
        if defaults.object(forKey: Const.DR_LATITUDE) != nil {
            dr_lat = defaults.string(forKey: Const.DR_LATITUDE)!
        }
        
        var dr_lon: String = ""
        if defaults.object(forKey: Const.DR_LATITUDE) != nil {
            dr_lon = defaults.string(forKey: Const.DR_LONGITUDE)!
        }
        
        
        let pLati = Double(pi_lat ?? "") ?? 0.0
        let pLongi = Double(pi_lon ?? "") ?? 0.0
        
        let dLati = Double(dr_lat ?? "") ?? 0.0
        let dLongi = Double(dr_lon ?? "") ?? 0.0
        
        
        pickupLoc = CLLocationCoordinate2DMake(pLati, pLongi)
        
        let locationChoice:String = defaults.object(forKey: Const.LOCATION_CHOICE)! as! String
        if locationChoice == "1"{
            self.isTapGoogleMap = true
            locImageView.image = UIImage(named: "map_drop_marker")
            //txtDestinationlocation.isFocused = true
        }else{
            self.isTapGoogleMap = false
            locImageView.image = UIImage(named: "map_pick_marker")
            //txtPickuplocation.isFocused = true
        }
        
        
        
        do {
            // Set the map style  by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "maps_style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func backButton(sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //        self.setupNavigationBar(with: "Set Your Locations")
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        // Or, Set to new colour for just this navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let defaults = UserDefaults.standard
        let line = defaults.object(forKey: Const.CURRENT_ADDRESS)!
        
        
        txtPickuplocation.text = line as? String
        
        
        
        txtPickuplocation.layer.masksToBounds = false
        txtPickuplocation.layer.shadowRadius = 3.0
        txtPickuplocation.layer.shadowColor = UIColor.black.cgColor
        txtPickuplocation.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtPickuplocation.layer.shadowOpacity = 1.0
        
        
        txtDestinationlocation.layer.masksToBounds = false
        txtDestinationlocation.layer.shadowRadius = 3.0
        txtDestinationlocation.layer.shadowColor = UIColor.black.cgColor
        txtDestinationlocation.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtDestinationlocation.layer.shadowOpacity = 1.0
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(textField.text!)
        
        
        
        let str = textField.text!
        
        if let txtCount = textField.text?.characters.count {
            
            if txtCount > 2 {
                
                print("character count")
                
                
                let newString = str.replacingOccurrences(of: " ", with: ",")
                
                
                var path : String = "\(Const.googleAutoCompleteAPIURL)input=\(newString)&sensor=false&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)"
                
                
                  path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                API.googlePlaceAPICall(with: path) { responseObject, error in
                    
                    //                    print(responseObject!)
                    
                    
                    if responseObject == nil {
                        
                    }
                    else {
                        
                        if let resData = responseObject {
                            
                            
                            
                            
                            let json = self.jsonParser.jsonParser(dicData: resData)
                            
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
                                        
                                        self.uiviewTopViewConstrains.constant = 105
                                        
                                        return
                                    }
                                    self.uiviewTopViewConstrains.constant = 60
                                    
                                    //                                self.txtPickuplocation.text = str
                                    
                                    
                                }
                                else {
                                    
                                    self.uiviewHeightConstrain.constant = 0
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
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
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            isTapGoogleMap = false
            
            locImageView.image = UIImage(named: "map_pick_marker")
            
            
        }
            
        else if textField.tag == 2 {
            isTapGoogleMap = true
            locImageView.image = UIImage(named: "map_drop_marker")
            
            //            map_drop_marker
            
        }
        
        return true
        
        
    }
    
    
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            //self.addressLabel.unlock()
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                //self.addressLabel.text = lines.joined(separator: "\n")
                
                let defaults = UserDefaults.standard
                defaults.set(lines.joined(separator: "\n"), forKey: Const.CURRENT_ADDRESS)
                defaults.set(coordinate.latitude, forKey: Const.CURRENT_LATITUDE)
                defaults.set(coordinate.longitude, forKey: Const.CURRENT_LONGITUDE)
                
                //let labelHeight = self.addressLabel.intrinsicContentSize.height
                print(" current address is -- ")
                print(lines.joined(separator: "\n"))
                
                let addr : String = lines.joined(separator: "\n")
                
                
                guard self.isTapGoogleMap == false else {
                    
                    self.txtDestinationlocation.text = addr
                    
                    return
                }
                
                self.txtPickuplocation.text = addr
                
                
                //                self.currentLocationAddressButton.setTitle(addr, for:.normal)
                
                
            }
        }
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doneButtonActionMethod(_ sender: Any) {
        
        //        self.navigationController?.popViewController(animated: true)
        
        
        if (txtPickuplocation.text?.isEmpty)!{
            
        }
            
        else if ((txtDestinationlocation.text?.isEmpty)!) {
            
            self.txtDestinationlocation.resignFirstResponder()
            self.isTapGoogleMap = true
            locImageView.image = UIImage(named: "map_drop_marker")
        }
        else {
            self.dismiss(animated: true, completion: nil)
            
            
            delegate.updateAddrLocation(with: txtPickuplocation.text!, destinationAddr: txtDestinationlocation.text!, pickupLoc: pickupLoc, destinationLoc: destinationLoc)
        }
        
        
        
        
        
        
    }
    
    
    
    
    
}

// MARK: - GMSMapViewDelegate
extension setupLocationVC: GMSMapViewDelegate {
    
    
    //    // Touch and lift
    //    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    //
    //        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude:coordinate.longitude)
    //
    //
    //
    //        reverseGeocodeCoordinate(coordinate: position)
    ////
    ////        guard self.isTapGoogleMap == false else {
    ////
    ////
    ////            print("marker already added")
    ////
    ////            marker.position = position
    ////
    ////            return
    ////
    ////        }
    ////
    ////
    ////        marker = GMSMarker(position: position)
    ////        marker.icon = UIImage(named: "map_pick_marker")
    ////        marker.map = self.mapView
    ////
    ////        isTapGoogleMap = true
    //
    //        //        marker.iconView = infoWindow
    //
    //
    //
    //    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        
        print("location settting")
        
        print(position.target)
        
        reverseGeocodeCoordinate(coordinate: position.target)
        let deriverLoc : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
        
        guard self.isTapGoogleMap == false else {
            
            
            destinationLoc = deriverLoc
            
            return
        }
        
        pickupLoc = deriverLoc
        
        
        
    }
    
    
    
    
}

extension setupLocationVC : UITableViewDelegate, UITableViewDataSource {
    
    
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
        
        
//        let newString = str.replacingOccurrences(of: ", ", with: ",")
//
//        let trimmedString = newString.replacingOccurrences(of: " ", with: "")
//
//
//        print("trimmed \(trimmedString)")
//
        var path : String = "\(Const.googleGeocoderAPIURL)address=\(str)&key=\(Const.PLACES_AUTOCOMPLETE_API_KEY)"
        
        
         path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        print(path)
        
        API.googlePlaceAPICall(with: path) { responseObject , errro in
            
            
            if responseObject == nil {
                
            }
            else {
                let json = self.jsonParser.jsonParser(dicData: responseObject)
                
                print(json)
                
                
                if let array = json["results"].array, array.count > 0 {
                    
                    
                    let dic = array[0].dictionary
                    
                    if let addr : String = (dic!["formatted_address"]?.string) {
                        
                        
                        
                        if self.isTapGoogleMap == true {
                            
                            self.txtDestinationlocation.text  = addr
                        }
                        else {
                            self.txtPickuplocation.text = addr
                        }
                        
                        
                        //                    guard self.isTapGoogleMap == false else {
                        //
                        //                        self.txtDestinationlocation.text  = addr
                        //
                        //                        return
                        //                    }
                        //
                        //                    self.txtPickuplocation.text = addr
                        
                        
                        
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
                        
                        
//                         mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
                        //mapView.camera = deriverLoc
                        self.destinationLoc = deriverLoc
                        self.hideLoader()
                        return
                    }
                    
                    self.pickupLoc = deriverLoc
                    
                    self.hideLoader()
                    
                }
            }
            
           
            
        }
        
        
    }
    
    
    
    
}

// MARK: - CLLocationManagerDelegate
extension setupLocationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //            self.latlon = location.coordinate
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
            
            self.locationManager.stopUpdatingLocation()
            
            
            //locationManager.stopUpdatingLocation()
            //fetchNearbyPlaces(location.coordinate)
        }
    }
}

