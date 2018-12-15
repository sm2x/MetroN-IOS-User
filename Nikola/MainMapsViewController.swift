//
//  MainMapsViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

protocol setDestinationProtocalDelegate: class   {
    func setDestinationMethod()
}
extension setDestinationProtocalDelegate {
    func setDestinationMethod(){}
}
protocol checkstatusUpdateProtocalDelegate: class {
    func checkStatusMethod()
}

final class MainMapsViewController: BaseViewController {
    
    //MARK: - iVars
    @IBOutlet fileprivate weak var mapCenterPinImage: UIImageView!
    @IBOutlet fileprivate weak var burgerMenu: UIBarButtonItem!
    // You don't need to modify the default init(nibName:bundle:) method.
    @IBOutlet fileprivate weak var mapView: GMSMapView!
    @IBOutlet fileprivate weak var menuButton: UIButton!
    weak var defaults = UserDefaults.standard
    @IBOutlet fileprivate weak var uiview1: UIView! {
        didSet {
            uiview1.layer.cornerRadius = uiview1.frame.size.width/2
            uiview1.clipsToBounds = true
        }
    }
    @IBOutlet fileprivate weak var uiview2: UIView! {
        didSet {
            uiview2.layer.cornerRadius = uiview2.frame.size.width/2
            uiview2.clipsToBounds = true
        }
    }
    fileprivate let locationManager = CLLocationManager()
    fileprivate var latlon : CLLocationCoordinate2D?
    fileprivate var driverLocations: [NearByDrivers] = []
    fileprivate var markers: [GMSMarker] = []
    fileprivate var isTapGoogleMap : Bool = false
    fileprivate var isCheckAvaliability : Bool = false
    fileprivate var timer: Timer! = nil
    fileprivate var marker : GMSMarker?
    
    @IBOutlet weak var lblwherearewegoing: UILabel!
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarAppearanceAttributes()
        setLoggedInTag()
      //  setDefaultGoogleMapColoring()
        CLLocationPermissionCheck()
        setPanGestureToMakeSidebarSlideout()
        observeCLLocationDuringLaunch()
        //mapView.settings.setAllGesturesEnabled(false)
    }
    
    deinit {
        self.stopProviderTimer()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //CLLocationPermissionCheck()
    }
    
    
    //MARK:- NotificationCenter ReceivedMethod
    func methodOfReceivedNotification(notification: Notification){
        
        self.goToTravelMap()
    }
    
    //MARK: - CLLocationPermissionCheck to enable the location server
    
    private func CLLocationPermissionCheck() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                self.showAlert(with: "Location Service Disabled To re-enable, please go to Settings and turn on Location Service for this app.")
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            self.showAlert(with: "Location Service Disabled To re-enable, please go to Settings and turn on Location Service for this app.")
            print("Location services are not enabled")
        }
    }
    
    
    //MARK: - Private functions
    private func observeCLLocationDuringLaunch() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //.authorizedWhenInUse,
            self.startMonitoringLocation()
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        default:
            debugPrint("permission denied")
            break;
        }
    }
    private func setPanGestureToMakeSidebarSlideout() {
        if revealViewController() != nil {
//            burgerMenu.target = revealViewController()
//            burgerMenu.action = "revealToggle:"
            //self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }
    private func setDefaultGoogleMapColoring() {
        do {
            if let styleURL = Bundle.main.url(forResource: "maps_style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                debugPrint("Unable to find style.json")
            }
        } catch {
            debugPrint("One or more of the map styles failed to load. \(error)")
        }
    }
    private func setNavigationBarAppearanceAttributes() {
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UIApplication.shared.isStatusBarHidden = false
    }
    private func setLoggedInTag() {
        lblwherearewegoing.text = "Where are you going?".localized()
        UserDefaults.standard.set(true, forKey: "loggedIn")
        defaults?.removeObject(forKey: "PROMOCODE")
    }
    
    private func startMonitoringLocation() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    
    @IBAction func setupLocationButtonActionMethod(_ sender: Any) {
        let nextViewContro‌​ller = self.storyboard?.instantiateViewController(withIdentifier: "LocationPickerVC") as! LocationPickerViewController
        self.present(nextViewContro‌​ller, animated:true, completion:nil)
    }
    
    @IBAction func moveToCurrentLocationButton(_ sender: Any) {
        if let lat_log = latlon {
            mapView.camera = GMSCameraPosition(target: lat_log, zoom: 15, bearing: 0, viewingAngle: 0)
        }
    }
    //MARK:- SheduleButtonAction
    @IBAction func sheduleBtnAction(_ sender: UIButton) {
        let popOverVC = self.storyboard?.instantiateViewController(withIdentifier: "SchedulePopUpViewController") as! SchedulePopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        popOverVC.delegate = self
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    //MARK:- CheckRequestStatus
    func checkRequestStatus(){
        API.checkRequestStatus{ [weak self] json, error in
            print("Full checkrequeststatus JSON")
            if let error = error {
                //self.hideLoader()
                self?.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    let defaults = UserDefaults.standard
                    if let currency : String = json[Const.CURRENCEY].rawString() {
                        print(currency)
                        defaults.set(currency, forKey: json[Const.CURRENCEY].rawString()!)
                    }
                    if let cancellation : Int = json[Const.CANCELLATION_FINE].intValue {
                        
                        let str : String = String(cancellation)
                        print(str)
                        defaults.set(str, forKey: Const.CANCELLATION_FINE)
                        
                    }
                    if(status){
//                        let alert = UIAlertController(title: "Message".localized(), message: "messgage", preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
//                        (UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil))
                        
                        let requestDetail: RequestDetail = RequestDetail()
                        
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
                            self?.processStatus(json: json, tripStatus:requestDetail.tripStatus)
                        } else {
                            requestDetail.tripStatus = Const.NO_REQUEST
                            let defaults = UserDefaults.standard
                            defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
                        }
                    }else{
                        print(json)
                        
                        if let error_Code = json[Const.ERROR_CODE].int {
                            if error_Code == 104 {
                                self?.showAlert(with: "Session expired")
                                let defaults = UserDefaults.standard
                                
                                defaults.set(false, forKey: "isloggedin")
                                
                                
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GetStartedViewController") as! GetStartedViewController
                                //  nav?.pushViewController(nextViewController, animated: true)
                                self?.present(nextViewController, animated: true, completion: nil)
                            }
                            else {
                                if let msg : String = json[Const.ERROR].rawString() {
                                    self?.showAlert(with: "session expired")
                                }
                            }
                        }
                    }
                }else{
                    debugPrint("Invalid JSON :(")
                }
            }
        }
    }
    
    //MARK:- ProcessStatus
    func processStatus(json: JSON, tripStatus: Int){
        
        //var requestDetail: RequestDetail = RequestDetail()
        switch(tripStatus){
            
        case Const.NO_REQUEST:
            PreferenceHelper.clearRequestData()
            self.view.makeToast(message: "No Providers found please try after some time!")
            print("No Providers found please try after some time!")
        //case Const.IS_CREATED:
        case Const.IS_ACCEPTED, Const.IS_DRIVER_TRIP_STARTED, Const.IS_DRIVER_ARRIVED,Const.IS_DRIVER_DEPARTED:
            
            let defaults = UserDefaults.standard
            defaults.set(Const.IS_ACCEPTED, forKey: Const.DRIVER_STATUS)
            print("Driver accepted")
            
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
        case Const.IS_DRIVER_TRIP_ENDED:
            
            let defaults = UserDefaults.standard
            defaults.set(Const.IS_DRIVER_TRIP_ENDED, forKey: Const.DRIVER_STATUS)
            print("IS_DRIVER_TRIP_ENDED")
            
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
            
            self.goToRating()
        case Const.IS_DRIVER_RATED:
            
            let defaults = UserDefaults.standard
            defaults.set(Const.IS_DRIVER_RATED, forKey: Const.DRIVER_STATUS)
            print("IS_DRIVER_RATED")
            
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
            
            self.goToRating()
        default:
            print("something else happened")
        }
        
    }
    
    //MARK:- Navigation TravelMap
    func goToTravelMap(){
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "TravelMapViewController") as! TravelMapViewController
        //
        //         self.present(nextViewContro‌​ller, animated:true, completion:nil)
        
        
        //        graud let tm = timer , tm = nil else{
        //
        //
        //
        //        }
        
        if timer == nil {
            
            
        } else {
            self.timer.invalidate()
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sw = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.view.window?.rootViewController = sw
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "TravelMapViewController") as! TravelMapViewController
        sw.pushFrontViewController(destinationController, animated: true)
    }
    
    //MARK:- RatingView Navigation
    func goToRating(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
        self.present(nextViewContro‌​ller, animated:true, completion:nil)
    }
    var timerProviders: DispatchSourceTimer?
    
    var queue : DispatchQueue? = nil
    func startProviderTimer() {
        queue = DispatchQueue(label: "com.prov.nikola.timer2")
        timerProviders = DispatchSource.makeTimerSource(queue: queue)
        timerProviders!.scheduleRepeating(deadline: .now(), interval: .seconds(4))
        timerProviders!.setEventHandler { [weak self] in
            do{
                self?.getProviders()
            }catch{
                self?.stopProviderTimer()
            }
        }
        timerProviders!.resume()
    }
    
    //MARK:- Overrride Methods
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //        [mapView clear];
        //        [m_mapView stopRendering] ;
        //        [m_mapView removeFromSuperview] ;
        //        m_mapView = nil ;
        self.stopProviderTimer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hourlyVC" {
            if let destVC = segue.destination as? RentalRideViewController {
                destVC.isViewType = true
            }
        }else if segue.identifier == "AirportVC" {
            if let destVC = segue.destination as? AirportRideViewController {
                destVC.isViewType = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkRequestStatus()
        startProviderTimer()
        
        UIApplication.shared.isStatusBarHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainMapsViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifierUpdateScdeduledRequest"), object: nil)
        
    }
    
    func stopProviderTimer() {
        
        timerProviders?.cancel()
        timerProviders = nil
        //queue?.suspend()
    }
    
    //MARK:- MenuButton Action Method
    @IBAction func menuButtonActionMethod(_ sender: Any) {
        revealViewController().revealToggle(sender)
    }
    
    
    //MARK:- GetProviders Method
    func getProviders(){
        
        if latlon == nil {
            return
        }
        
        //var loc : CLLocationCoordinate2D? = nil
        
        API.getProviders(latlong: latlon!){ json, error in
            
            print("Full getProviders JSON")
            print(json ?? "getProviders json null")
            
            if let error = error {
                //self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        self.driverLocations.removeAll()
                        
                        let driversArray = json["providers"].arrayValue
                        for driver: JSON in driversArray {
                            self.driverLocations.append(NearByDrivers.init(jsonObj: driver))
                        }
                        if self.driverLocations.count > 0 {
                            
                            let driverLatLon: CLLocationCoordinate2D = self.driverLocations[0].latlon
                            
                            if self.markers != nil && self.markers.count > 0 {
                                for marker: GMSMarker in  self.markers {
                                    marker.map = nil
                                }
                            }
                            self.markers.removeAll()
                            
                            for i: Int in 0...(self.driverLocations.count-1) {
                                
                                let markerNow: GMSMarker = GMSMarker(position: self.driverLocations[i].latlon)
                                markerNow.title = self.driverLocations[i].driver_name
                                //pick_marker?.snippet = nearest_eta
                                markerNow.icon = UIImage(named: "car-1")
                                markerNow.map = self.mapView
                                self.markers.append(markerNow)
                            }
                        } else{
                            
                            if self.markers != nil && self.markers.count > 0 {
                                for marker: GMSMarker in  self.markers {
                                    marker.map = nil
                                }
                            }
                            self.markers.removeAll()
                        }
                        
                        print(json)
                    }else{
                        print(statusMessage)
                        print(json)
                        
                    }
                    
                }else {
                    debugPrint("invalid json :(")
                }
                
            }
            
        }
    }
    
    
}

// MARK: - CLLocationManagerDelegate
extension MainMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = false
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.latlon = location.coordinate
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.locationManager.stopUpdatingLocation()
        }
    }
}

//MARK:- checkstatusUpdateProtocalDelegate
extension MainMapsViewController : checkstatusUpdateProtocalDelegate {
    func checkStatusMethod() {
        //        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(MainMapsViewController.checkRequestStatus), userInfo: nil, repeats: true)
    }
    
}


// MARK: - GMSMapViewDelegate
extension MainMapsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(coordinate: position.target)
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
    private func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                let lat =  String(format:"%.7f", coordinate.latitude)
                let log = String(format:"%.7f", coordinate.longitude)
                let defaults = UserDefaults.standard
                defaults.set(lines.joined(separator: "\n"), forKey: Const.CURRENT_ADDRESS)
                defaults.set(lat, forKey: Const.CURRENT_LATITUDE)
                defaults.set(log, forKey: Const.CURRENT_LONGITUDE)
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: 60.0, right: 0)
            }
        }
    }
    
}

