//
//  RequestViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import GoogleMaps
import NVActivityIndicatorView
import Toucan
import SDWebImage

protocol UpdatePaymentMethodProtocalDelegate {
    
    func updatePaymentMethod(with type : String)
    
}

protocol updatePromoCodeProtocalDelegate: class {
    func updatepromoCode()
}

class RequestViewController: BaseViewController , UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "TaxiTypeCell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var taxiTypes : [TaxiType] = []
    var currentTaxi: TaxiType? = nil
    var currentSelection : Int = 0
    var currentIndexPath : IndexPath? = nil
    
    var piPoint : CLLocationCoordinate2D? = nil
    var drPoint : CLLocationCoordinate2D? = nil
    
    var latlon : CLLocationCoordinate2D? = nil
    
    var driverLocations: [NearByDrivers] = []
    var markers: [GMSMarker] = []
    
    var nearest_eta : String = "- -"
    
    var currencyType : String = ""
    
    var payment_Mode_Array = [String]()
    
    @IBOutlet weak var gmsMapView: GMSMapView!
    @IBOutlet weak var taxiTypeCollectionView: UICollectionView!
    @IBOutlet weak var requestBtn: UIButton!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    var activityIndicatorView :NVActivityIndicatorView? = nil
    
    var pick_marker : GMSMarker? = nil
    var drop_marker : GMSMarker? = nil
    
    
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer1: Timer!
    var estimatedFare = ""
    var gotoPayment = false
    
    @IBOutlet weak var appyPromoCodeBtn: UIButton!
    
    @IBOutlet weak var trxValueLabel: UILabel!
    
    //    @IBOutlet weak var paymentTypeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if revealViewController() != nil {
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
//        paymentTypeBtn.setTitle("Payment Type is Card".localized(), for: .normal)
        requestBtn.setTitle("No driver available now".localized(), for: .normal)
        taxiTypeCollectionView.dataSource = self
        taxiTypeCollectionView.delegate = self
        //getTaxiTypes()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
        gmsMapView.delegate = self
        
        
        
        
//        do {
//            // Set the map style  by passing the URL of the local file.
//            if let styleURL = Bundle.main.url(forResource: "maps_style", withExtension: "json") {
//                gmsMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//                
//            } else {
//                NSLog("Unable to find style.json")
//            }
//        } catch {
//            NSLog("One or more of the map styles failed to load. \(error)")
//        }

        
        
        let defaults = UserDefaults.standard
        
         defaults.set("requesting", forKey: "requestType")
        
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let dr_lat: String = defaults.string(forKey: Const.DR_LATITUDE)!
        let dr_lon: String = defaults.string(forKey: Const.DR_LONGITUDE)!
        
        let pLati = Double(pi_lat) ?? 0.0
        let pLongi = Double(pi_lon) ?? 0.0
        
        let dLati = Double(dr_lat) ?? 0.0
        let dLongi = Double(dr_lon) ?? 0.0
        
        let piPointLat : CLLocationDegrees = pLati
        piPoint = CLLocationCoordinate2DMake(pLati, pLongi)
        drPoint = CLLocationCoordinate2DMake(dLati, dLongi)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        lpgr.numberOfTapsRequired = 0
        
        self.taxiTypeCollectionView.addGestureRecognizer(lpgr)
        self.startProviderTimer()
        
        self.findDistanceandTime(pic_loc: self.piPoint!, drop_loc: drPoint!)
        
        if let paymentMode: String = defaults.string(forKey: "paymentmode") {
            
//            if ("card" == paymentMode) {
//                paymentTypeBtn.setImage(UIImage(named:"card_icon.png"), for: .normal)
//                paymentTypeBtn.setTitle("Payment Type is Card".localized(),for: .normal)
//
//            }
//            else if ("walletbay" == paymentMode) {
//                paymentTypeBtn.setImage(UIImage(named:"wallet_icon.png"), for: .normal)
//                paymentTypeBtn.setTitle("Payment Type is Wallet".localized(),for: .normal)
//            }
//            else if ("cod" == paymentMode) {
//                paymentTypeBtn.setImage(UIImage(named:"Cash-icon.png"), for: .normal)
//                paymentTypeBtn.setTitle("Payment Type is Cash".localized(),for: .normal)
//            }
            
        }else {
            updatePayment(paymentMode: "cod")
        }
    }
    
    @IBAction func btnAddTRXWalletPressed(_ sender: Any) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
        myVC.isBackBoolVal = true
    self.navigationController?.pushViewController(myVC, animated: true)
//        self.present(myVC, animated: true, completion: nil)
        
       
        
    }
    
    func getTaxiTypes(dist : String, time : String){
        
        API.getTaxiTypesWithDistanceTime(dist: dist, time: time){ json, error in
            
            if let error = error {
                //self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                    
                                print(json)
                    
                        DATA().putTaxiTypesData(request: json["services"].rawString()!)
                    
                        UserDefaults.standard.set(json["currency"].rawString()!, forKey: "currency") //setObject
                    
                  
                            self.currencyType = json["currency"].rawString()!
                    
                            let typesArray = json["services"].arrayValue
                            for type: JSON in typesArray {
                                self.taxiTypes.append(TaxiType.init(taxiObj: type))
                            }
                            let TronServices =  json["tron_wallet"].dictionaryValue
                    
                            self.trxValueLabel.text = json["currency"].stringValue + json["tron_balance"].stringValue
                    
                            let taxi: TaxiType = self.taxiTypes[0]
                                        self.currentTaxi = taxi
                            self.estimatedFare = "\(taxi.estimated_fare)"
                    
                                        self.taxiTypeCollectionView.reloadData()
                                        self.taxiTypeCollectionView.collectionViewLayout.invalidateLayout()
                                         self.getProviders()
                                        print(json ?? "error in taxi_types json")
                    
                        }else{
                                        print(statusMessage)
                                        print(json ?? "json empty")
                            
                            if let msg : String = json[Const.DATA].rawString() {
                                self.view.makeToast(message: msg)
                            }

                    }
                    
                }else {
                    debugPrint("Invalid Json :(")
                }
                
            }

        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (self.timer1 != nil){
            self.timer1.invalidate()
            self.timer1=nil
        }
        
    }
    
    
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
                    
                                if driverLatLon != nil {
                                self.findDistanceandTimeforeta(pic_loc: self.piPoint!, drop_loc: driverLatLon)
                                }
                    
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
                                           markerNow.icon =  UIImage(named: "car-1")
                                            markerNow.map = self.gmsMapView
                                            self.markers.append(markerNow)
                                        }
                                        if self.currentTaxi != nil {
                                            let taxiName : String = (self.currentTaxi?.type)!
                                            self.requestBtn.setTitle("Request \(taxiName)", for: UIControlState.normal)
                    
                                             self.requestBtn.setTitleColor(UIColor.white, for: .normal)
                                            self.requestBtn.backgroundColor = UIColor.black
                    //                        self.requestBtn.setTitleColor(UIColor.black, for: .normal)
                                        }
                                        self.requestBtn.isEnabled = true
                                    } else{
                    
                                        if self.markers != nil && self.markers.count > 0 {
                                            for marker: GMSMarker in  self.markers {
                                                marker.map = nil
                                            }
                                        }
                        DispatchQueue.main.async
                            {
                                if self.pick_marker != nil {
                                    //self.pick_marker?.snippet = self.nearest_eta
                                    
                                    if let etaView = self.pick_marker?.iconView as? EtaView {
                                        if(self.driverLocations.count != 0)
                                        {
                                        etaView.etaLabel.text = self.nearest_eta
                                        }
                                        else
                                        {
                                          etaView.etaLabel.text = "--"
                                        }
                                        //self.pick_marker?.iconView = etaView
                                    }
                                }
                        }
                                        self.markers.removeAll()
                                         self.requestBtn.backgroundColor = UIColor(hex: "e4e4e4")
                                        self.requestBtn.setTitle("No driver available now", for: UIControlState.normal)
                                       self.requestBtn.setTitleColor(UIColor.lightGray, for: .normal)
                    
                                        self.requestBtn.isEnabled = false
                                    }
                    
                                    print(json ?? "error in getProviders json")
                                }else{
                                    print(statusMessage)
                                    print(json ?? "json empty")
                        
                        if let msg : String = json[Const.DATA].rawString() {
                            self.view.makeToast(message: msg)
                        }

                    }
                }else {
                    debugPrint("Invalid Json :(")
                }
                
            }
            

        }
    }
    
    func findDistanceandTimeforeta(pic_loc: CLLocationCoordinate2D, drop_loc: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let pi_lat: String = String(pic_loc.latitude)
        let pi_lon: String = String(pic_loc.longitude)
        
        let dr_lat: String = String(drop_loc.latitude)
        let dr_lon: String = String(drop_loc.longitude)
        
        
        let url = URL(string: Const.GOOGLE_MATRIX_URL + Const.Params.ORIGINS + "="
            + pi_lat + "," + pi_lon + "&" + Const.Params.DESTINATION + "="
            + dr_lat + "," + dr_lon + "&" + Const.Params.MODE + "="
            + "driving" + "&" + Const.Params.LANGUAGE + "="
            + "en-EN" + "&" + Const.Params.KEY + "=" + Const.googlePlaceAPIkey + "&" + Const.Params.SENSOR + "="
            + "false")
        print(url)
        
        
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if error != nil {
                print("path get error")
                print(error!.localizedDescription)
            }else{
                print("path got")
                do {
                    print(data ?? "")
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        print(json ?? "")
                        
                        let routes = json["rows"] as? [Any]
                        if (routes != nil) && (routes?.count)! > 0 {
                            let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String!
                            print(outputStr ?? " output str ")
                            
                            let jsonOut: JSON = JSON.parse(outputStr!)
                            let distance = jsonOut["rows"][0]["elements"][0]["distance"]["text"].stringValue
                            print(distance ?? "distance error")
                            let distanceValue = jsonOut["rows"][0]["elements"][0]["distance"]["value"].stringValue
                            print(distanceValue ?? "value error")
                            
                            let durationValue = jsonOut["rows"][0]["elements"][0]["duration"]["value"].stringValue
                            print(durationValue ?? "value error")
                            
                            let duration = jsonOut["rows"][0]["elements"][0]["duration"]["text"].stringValue
                            print(duration ?? "value error")
                            
                            self.nearest_eta = duration
                            
                            DispatchQueue.main.async
                                {
                                    if self.pick_marker != nil {
                                        //self.pick_marker?.snippet = self.nearest_eta
                                        
                                        if let etaView = self.pick_marker?.iconView as? EtaView {
                                            if(self.driverLocations.count != 0)
                                            {
                                            etaView.etaLabel.text = self.nearest_eta
                                            }
                                            else
                                            {
                                                etaView.etaLabel.text = "--"
                                            }
                                            
                                            //self.pick_marker?.iconView = etaView
                                        }
                                    }
                            }
                            
                            //print(distance +" - "+ duration)
                            
                            //GMSMarker.image
                            
                            /*
                             let polyString : String = (overview_polyline?["points"] as?String)!
                             print(polyString)
                             //Call this method to draw path on map
                             DispatchQueue.main.async
                             {
                             //                                // 2. Perform UI Operations.
                             //                                var position = CLLocationCoordinate2DMake(17.411647,78.435637)
                             //                                var marker = GMSMarker(position: position)
                             //                                marker.title = "Hello World"
                             //                                marker.map = vwGoogleMap
                             self.showPath(polyStr: polyString)
                             }
                             */
                        }
                        
                        
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func findDistanceandTime(pic_loc: CLLocationCoordinate2D, drop_loc: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let pi_lat: String = String(pic_loc.latitude)
        let pi_lon: String = String(pic_loc.longitude)
        
        let dr_lat: String = String(drop_loc.latitude)
        let dr_lon: String = String(drop_loc.longitude)
        
        
        let url = URL(string: Const.GOOGLE_MATRIX_URL + Const.Params.ORIGINS + "="
            + pi_lat + "," + pi_lon + "&" + Const.Params.DESTINATION + "="
            + dr_lat + "," + dr_lon + "&" + Const.Params.MODE + "="
            + "driving" + "&" + Const.Params.LANGUAGE + "="
            + "en-EN" + "&" + Const.Params.KEY + "=" + Const.googlePlaceAPIkey + "&" + Const.Params.SENSOR + "="
            + "false")
        print(url)
        
        
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if error != nil {
                print("path get error")
                print(error!.localizedDescription)
            }else{
                print("path got")
                do {
                    print(data ?? "")
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        print(json ?? "")
                        
                        let routes = json["rows"] as? [Any]
                        if (routes != nil) && (routes?.count)! > 0 {
                            let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String!
                            print(outputStr ?? " output str ")
                            
                            let jsonOut: JSON = JSON.parse(outputStr!)
                            let distance = jsonOut["rows"][0]["elements"][0]["distance"]["text"].stringValue
                            print(distance ?? "distance error")
                            let distanceValue = jsonOut["rows"][0]["elements"][0]["distance"]["value"].stringValue
                            print(distanceValue ?? "value error")
                            
                            let durationValue = jsonOut["rows"][0]["elements"][0]["duration"]["value"].stringValue
                            print(durationValue ?? "value error")
                            
                            self.nearest_eta = durationValue
                            
                            if distanceValue == nil || distanceValue.length == 0{
                                
                                self.showAlert(with :"Google Maps api cant fetch distance and time duration for this trip")
                                
                            }
                            else {
                                let dist : Double = Double(distanceValue)! * 0.001

                                DispatchQueue.main.async
                                    {
                                        self.getTaxiTypes(dist: "\(dist)", time: "\(durationValue)")
                                }
                            }
                            }
                            
                            
                        
                    }
                    
                }catch{
                     self.showAlert(with :"distance api google error")
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }

    
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.began {
            return
        }
        
        let point = gestureReconizer.location(in: self.taxiTypeCollectionView)
        let indexPath = self.taxiTypeCollectionView.indexPathForItem(at: point)
        
        if let index = indexPath {
            var cell = self.taxiTypeCollectionView.cellForItem(at: index)
            // do stuff with your cell, for example print the indexPath
            let taxi: TaxiType = taxiTypes[index.row]
            self.currentTaxi = taxi
            let defaults = UserDefaults.standard
            defaults.set(taxi.jsonObj.rawString(), forKey: Const.TAXI_LONG_PRESS)
            
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FairEstimatePopUpViewController") as! FairEstimatePopUpViewController
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            print(index.row)
        } else {
            print("Could not find index path")
        }
    }
    
    func popupViewDispalay(sender: UIButton){
        let buttonTag = sender.tag
        
        
            // do stuff with your cell, for example print the indexPath
            let taxi: TaxiType = taxiTypes[buttonTag]
            self.currentTaxi = taxi
            let defaults = UserDefaults.standard
            defaults.set(taxi.jsonObj.rawString(), forKey: Const.TAXI_LONG_PRESS)
            
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FairEstimatePopUpViewController") as! FairEstimatePopUpViewController
//              popOverVC.currency = currencyType
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
        
        
        
        
        
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        
        
        
    }
    
    
    
    @IBAction func changePaymentAction(_ sender: UIButton) {
        
        self.showLoader(str: "fetching PaymentMode")
        
        self.payment_Mode_Array.removeAll()
        
        API.getPayment(){ json, error in
            
//            print(json)
    
            if let error = error {
                self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                    
                            let payment_Mode = json["payment_modes"].array
                    
    
                        
                            for mode in payment_Mode! {
                    
                                let str : String = mode.string!
                    
                                self.payment_Mode_Array.append(str)
                    
                            }
                    
                                print(self.payment_Mode_Array)
                    
                                self.hideLoader()
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "PaymentModeVC") as! PaymentModeVC
                    
                             nextViewContro‌​ller.delegate = self
                                         nextViewContro‌​ller.mode_Array = self.payment_Mode_Array
                                        self.present(nextViewContro‌​ller, animated:true, completion:nil)
                    
                    
                    
                    }
                    
                    
                }else {
                     self.hideLoader()
                    
                    debugPrint("Invalid Json")
                }
                
            }
            

        }
        
        
        
    }
    @IBAction func requestAction(_ sender: UIButton) {
        
        showAnimation()
        
        let defaults = UserDefaults.standard
        var serviceType = defaults.string(forKey: Const.Params.SERVICE_TYPE)
        if (serviceType ?? "").isEmpty{
            if(taxiTypes.count > 0)
            {
                let defaultTaxiType = taxiTypes[0].id
                
                if (defaultTaxiType?.isEmpty)! {
                    
                    serviceType = "1"
                }
                else{
                    serviceType = defaultTaxiType
                    
                }
                
            }
                
            else{
                serviceType = "1"
            }
        }
        
        API.requestTaxi(serviceType: serviceType!,EstimatedFare:self.estimatedFare){ json, error in
            
            if let error = error {
                //self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                    
                            print("Full requestTaxi JSON")
                            print(json ?? "json null")
                    
                        let frame :CGRect = CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: 100, height: 100))
                    
                        self.activityIndicatorView  = NVActivityIndicatorView(frame: frame)
                        self.activityIndicatorView?.startAnimating()
                    
                    
                        self.startTimer()
                        print("Request taxi success. Timer started")
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
                            if error_Code == 166 {
                          
                                let next = self.storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
                                next.isBackBoolVal = true

                                let nav = UINavigationController.init(rootViewController: next)

                                self.present(nav, animated: true, completion: nil)
                                
                                
                                
                            }
                            else if error_Code == 5837
                            {
                                if let msg : String = json[Const.ERROR].rawString() {
                                    self.view.makeToast(message: msg)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                                  self.gotoPayment = true
                                    self.gotoAddPaymentOption()
                                })
                                
                                
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

        }
    }
    func gotoAddPaymentOption()
    {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
     
        self.navigationController?.pushViewController(myVC, animated: true)
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
        self.stopProviderTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
        self.stopProviderTimer()
        if(!gotoPayment)
        {
         self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        else
        {
          self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    //MARK:- ApplyPromoCodeButtonAction
    @IBAction func applyPromoCodeButtonAction(_ sender: Any) {
        
        
        let popOverVC: NKPromoCodeVC   = NKPromoCodeVC(nibName: "NKPromoCodeVC", bundle: nil)
        
        popOverVC.delegate = self
//        let popOverVC: WalletPaymentGateType   = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletPaymentGateTypeVC") as? WalletPaymentGateType)!
        
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + 70)

        popOverVC.willMove(toParentViewController: self)
        self.view.addSubview(popOverVC.view)
        self.addChildViewController(popOverVC)
        popOverVC.didMove(toParentViewController: self)
        
        
    }
    
    @IBAction func menuButtonActionMethod(_ sender: Any) {
        
         revealViewController().revealToggle(sender)
        
    }
    
    
    
    var timerProviders: DispatchSourceTimer?
    
    func startProviderTimer() {
        let queue = DispatchQueue(label: "com.prov.nikola.timer2")  // you can also use `DispatchQueue.main`, if you want
        timerProviders = DispatchSource.makeTimerSource(queue: queue)
        timerProviders!.scheduleRepeating(deadline: .now(), interval: .seconds(4))
        timerProviders!.setEventHandler { [weak self] in
            // do whatever you want here
            
//            self?.getProviders()
            
        }
        timerProviders!.resume()
    }
    
    func stopProviderTimer() {
        timerProviders?.cancel()
        timerProviders = nil
    }
    
    func updatePayment(paymentMode: String){
        
        API.updatePayment(paymentMode: paymentMode){ json, error in
            
            if let error = error {
                print("path get error")
                self.showAlert(with :error.localizedDescription)
                print(error.localizedDescription)
            }else{
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                    
                            print("Full updatePayment JSON")
                            print(json ?? "json null")
                    
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
        }
    }
    
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            if let error = error {
                print("error")
                self.showAlert(with :error.localizedDescription)
                print(error.localizedDescription)
            }else{
                print("Full checkrequeststatus JSON")
                print(json ?? "json null")
                
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
                        
                        if let msg : String = json[Const.DATA].rawString() {
                             self.view.makeToast(message: msg)
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
    
    func addLine(button:UIButton)// pass button object as a argument
    {
        let length = button.bounds.width
        let x  =  button.bounds.origin.x
        let y = button.bounds.origin.y + button.bounds.height - 5
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x + length , y:y))
        //design path in layer
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.red.cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.fillColor  = UIColor.clear.cgColor
        button.layer.insertSublayer(lineLayer, at: 0)
    }
    
    // Pass your source and destination coordinates in this method.
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&\(Const.EXTANCTION)")!
        //sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print("path get error")
                print(error!.localizedDescription)
            }else{
                print("path got")
                do {
                    print(data ?? "")
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as? [Any]
                        if (routes != nil) && (routes?.count)! > 0 {
                            let route = routes?[0] as?[String:Any]
                            let overview_polyline = route?["overview_polyline"] as?[String:Any]
                            let polyString : String = (overview_polyline?["points"] as?String)!
                            
                            
                            
                            print(polyString)
                            //Call this method to draw path on map
                            DispatchQueue.main.async
                                {
                                    //                                // 2. Perform UI Operations.
                                    //                                var position = CLLocationCoordinate2DMake(17.411647,78.435637)
                                    //                                var marker = GMSMarker(position: position)
                                    //                                marker.title = "Hello World"
                                    //                                marker.map = vwGoogleMap
                                    
                                    self.path = GMSPath.init(fromEncodedPath: polyString)!
                                    
                                    self.showPath(polyStr: polyString)
                            }
                        }
                        
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr :String){
//        let path:GMSPath = GMSPath(fromEncodedPath: polyStr)!
//        let polyline = GMSPolyline(path: path)
//        polyline.strokeWidth = 3.0
//        polyline.strokeColor = UIColor.black
//        polyline.map = gmsMapView // Your map view
        
        
        // let path:GMSPath = GMSPath(fromEncodedPath: polyStr)!
        self.polyline.path = path
        self.polyline.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.polyline.strokeWidth = 5.0
        self.polyline.map = self.gmsMapView
        
       
        
        //gmsMapView.bounds
        
        var bounds = GMSCoordinateBounds()
        
        for index:UInt in 1...path.count() {
            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        }
        
        gmsMapView.animate(with: GMSCameraUpdate.fit(bounds))
        
        
         self.timer1 = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
    }
    
    
    func animatePolylinePath() {
      
        
        if (self.i < self.path.count()) {
            self.animationPath.add(self.path.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor.black
            self.animationPolyline.strokeWidth = 5.0
            self.animationPolyline.map = self.gmsMapView
            self.i += 1
        }
        else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
        }
    }
    
    func goToTravelMap(){
        /* //old flow with back btn issues
         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "TravelMapViewController") as! TravelMapViewController
         self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
         */
        //self.timer1.Invalid
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sw = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.view.window?.rootViewController = sw
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "TravelMapViewController") as! TravelMapViewController
//        let navigationController = UINavigationController(rootViewController: destinationController)
        sw.pushFrontViewController(destinationController, animated: true)
    }
    
    var popOverVC: RequestAnimationViewController? = nil
    
    func showAnimation(){
        popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestAnimationViewController") as? RequestAnimationViewController
        self.addChildViewController(popOverVC!)
        popOverVC!.view.frame = self.view.frame
        UserDefaults.standard.set(false, forKey: "viewHour")
        self.view.addSubview(popOverVC!.view)
        self.didMove(toParentViewController: self)
        
    }
}


// MARK:- UICollectionViewDataSource Delegate
extension RequestViewController: UICollectionViewDataSource {
    
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
        self.currentTaxi = taxi
        let defaults = UserDefaults.standard
        defaults.set(taxi.id, forKey: Const.Params.SERVICE_TYPE)
        let tel: String = taxi.type
        let btnText = "Request \(tel)"
        
        self.estimatedFare = "\(taxi.estimated_fare)"
        
        self.requestBtn.setTitleColor(UIColor.white, for: .normal)
        self.requestBtn.backgroundColor = UIColor.black
        self.requestBtn.setTitle(btnText, for: UIControlState.normal)
        self.getProviders()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TaxiTypeCell
        //cell.backgroundColor = UIColor.red
        
        let taxi: TaxiType = taxiTypes[indexPath.row]
        //cell.imageView.image = UIImage(named: name.lowercaseString)
        /*
         let image = UIImage(data: try! Data(contentsOf: URL(string:taxi.picture.decodeUrl())!))!
         cell.imageView?.image = image
         cell.imageView?.layer.cornerRadius = (image.size.width)/2
         
         //        cell.imageView.setImageFromURl(stringImageUrl: taxi.picture.decodeUrl())
         //        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
         cell.imageView?.layer.masksToBounds = true
         */
        cell.name.text = taxi.type
        cell.amount.text = "\(self.currencyType) \(taxi.estimated_fare)"
        
        cell.popupButton.tag = indexPath.row
        
        cell.popupButton.addTarget(self, action: #selector(RequestViewController.popupViewDispalay), for: .touchUpInside)
        
  
        if !((taxi.picture ?? "").isEmpty)
        {
            let url = URL(string: taxi.picture.decodeUrl())!
            
            
            
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


extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

//let profilePicture = UIImage(data: try! Data(contentsOf: URL(string:"http://i.stack.imgur.com/Xs4RX.jpg")!))!
//profilePicture.circleMasked

// MARK: - CLLocationManagerDelegate
extension RequestViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            gmsMapView.isMyLocationEnabled = true
            gmsMapView.settings.myLocationButton = true
    
            if piPoint != nil && (piPoint?.latitude != 0 && piPoint?.longitude != 0){
                pick_marker = GMSMarker(position: piPoint!)
                pick_marker?.title = "Set Pickup location".localized()
                pick_marker?.snippet = nearest_eta
                pick_marker?.icon = #imageLiteral(resourceName: "map_pick_marker")
                pick_marker?.map = gmsMapView
                
                if let etaView = UIView.viewFromNibName("EtaView") as? EtaView {
                    etaView.etaLabel.text = "--"
                    pick_marker?.iconView = etaView
                }
            }
            
            if drPoint != nil && (drPoint?.latitude != 0 && drPoint?.longitude != 0){
                drop_marker = GMSMarker(position: drPoint!)
                drop_marker?.title = "Drop location".localized()
                //drop_marker?.title = nearest_eta
                drop_marker?.icon = #imageLiteral(resourceName: "map_drop_marker")
                drop_marker?.map = gmsMapView
            }
            
            
            
            if piPoint != nil && drPoint != nil{
                self.getPolylineRoute(from: piPoint!, to: drPoint!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.latlon = location.coordinate
            gmsMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            
            
            locationManager.stopUpdatingLocation()
        }
    }
}

// MARK: - GMSMapViewDelegate
extension RequestViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView!, idleAt position: GMSCameraPosition!) {
        // reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView!, willMove gesture: Bool) {
        //addressLabel.lock()
        
        if (gesture) {
            //mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        
        return nil
        //        }
    }
    
    func mapView(_ mapView: GMSMapView!, didTap marker: GMSMarker!) -> Bool {
        //mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView!) -> Bool {
        // mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
}

extension RequestViewController: updatePromoCodeProtocalDelegate {
    func updatepromoCode() {
        //let image = UIImage(named: "promo2.png")
        appyPromoCodeBtn.setImage(UIImage(named: "promo2.png"), for: .normal)
        appyPromoCodeBtn.setTitle("  Promocode Applied successfully", for: .normal)
    }
}

extension RequestViewController: UpdatePaymentMethodProtocalDelegate {
    
    func updatePaymentMethod(with type : String) {
        
//        if ("card" == type) {
//            
//             self.showAlert(with: "Payment Mode Updated Successfully".localized())
////             paymentTypeBtn.setImage(UIImage(named:"card_icon.png"), for: .normal)
////           paymentTypeBtn.setTitle("Payment Type is Card".localized(),for: .normal)
//          
//        }
//        else if ("walletbay" == type) {
//             self.showAlert(with: "Payment Mode Updated Successfully".localized())
//             paymentTypeBtn.setImage(UIImage(named:"wallet_icon.png"), for: .normal)
//            paymentTypeBtn.setTitle("Payment Type is Wallet".localized(),for: .normal)
//           
//            
//        }
//        else if ("cod" == type) {
//            
//             self.showAlert(with: "Payment Mode Updated Successfully".localized())
//            
//         paymentTypeBtn.setImage(UIImage(named:"Cash-icon.png"), for: .normal)
//           paymentTypeBtn.setTitle("Payment Type is Cash".localized(),for: .normal)
//            
//       
//        }
        
      //  paymentTypeBtn.setTitle(<#T##title: String?##String?#>, for: <#T##UIControlState#>)
        
        
    }
    
    
}



