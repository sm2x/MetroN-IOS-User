//
//  TravelMapViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/29/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import UIKit
import Floaty
import SwiftyJSON
import AlamofireImage
import GoogleMaps
import PubNub
import SDWebImage
import Toucan
import SocketIO


class TravelMapViewController: BaseViewController , FloatyDelegate , PNObjectEventListener, ARCarMovementDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    @IBOutlet weak var requestStatusLabel: UILabel!
    
    @IBOutlet weak var pickupAddressLabel: MarqueeLabel!
    
    @IBOutlet weak var cancelRequestButton: UIButton!
    @IBOutlet weak var pickupAdd: MarqueeLabel!
    @IBOutlet weak var addressTitle: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    
    @IBOutlet weak var driverMobileLabel: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var floatingButton: Floaty!
    
    var performGoogleMatrixApiCall : Bool?
    @IBOutlet weak var gmsMapView: GMSMapView!
    var piPoint : CLLocationCoordinate2D? = nil
    var drPoint : CLLocationCoordinate2D? = nil
    var driverPoint : CLLocationCoordinate2D? = nil
    
    var driverMovingPoint : CLLocationCoordinate2D!
    
    var updateLocationPoint : CLLocationCoordinate2D!
    
    
    @IBOutlet weak var driver_car_img: UIImageView!
    var pick_marker : GMSMarker? = nil
    var drop_marker : GMSMarker? = nil
    var driver_marker : GMSMarker? = nil
    
    var requestDetail: RequestDetail = RequestDetail()
    var floaty: Floaty? = nil
    
    var jobStatus: Int = 0
    let locationManager = CLLocationManager()
    
    var client: PubNub!
    var timer1: Timer! = nil
    
    var cancelReasonArray = [String]()
    var cancelReasonId = [Int]()
    var rotoation: Double!
    
    var driverMarker: GMSMarker!
    var moveMent: ARCarMovement!
    var coordinateArr = NSArray()
    var oldCoordinate: CLLocationCoordinate2D!
    //var timer: Timer! = nil
    var counter: NSInteger!
    
    var etaTime: String = "- -"
    
     var path = GMSPath()
    
    static let sharedInstance = SocketIOManager()
    
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet weak var cantactbtn: UIButton!

    
    var polyline: GMSPolyline!
    
    var nickname: String! = ""
    let defaults = UserDefaults.standard
    @IBOutlet weak var addressUIView: UIView!
    //MARK:- Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
         SocketIOManager.sharedInstance.establishConnection()
        
        cantactbtn.setTitle("Contact".localized(), for: .normal)
        cancelbtn.setTitle("Cancel".localized(), for: .normal)
        
         nickname = "\(DATA().getUserId())"
        SocketIOManager.sharedInstance.connectToServerWithNickname(self.nickname, completionHandler: { (userList) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                //                if userList != nil {
                //                    self.users = userList!
                //                    self.tblUserList.reloadData()
                //                    self.tblUserList.isHidden = false
                //                }
                print("connected to server")
            })
        })
        
        pickupAdd.tag = 501
        pickupAdd.type = .continuous
        pickupAdd.speed = .duration(10)
        pickupAdd.fadeLength = 10.0
        pickupAdd.trailingBuffer = 30.0

//        updateLocationPoint.latitude = 0.0000
        
        
//        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
//            DispatchQueue.main.async(execute: { () -> Void in
//                
//                      
//                if let val = messageInfo["message"] as! [String: AnyObject]! {
//                   
//                        
//                        
//                    
//                    
//                    if val["latitude"] == nil {
//                        
//                        
//                    }
//                    else {
//                        
//                        let lat: Double  = Double(val["latitude"] as! String)!
//                        let lon: Double  = Double(val["longitude"] as! String)!
//                        self.rotoation = Double(val["bearing"] as! String)!
//                        
//                        print(lat)
//                        
//                        
//                        self.driverMovingPoint = CLLocationCoordinate2DMake(lat, lon)
//                        
//                        
//                        self.timer1 = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(TravelMapViewController.timerTriggered), userInfo: nil, repeats: true)
//
//                    }
//                    
//                    
        
                  
                    
                    
                    //                 driverMarker.rotation = rotoation
                    
                    
                    
                  
                    
                    
                   // floatingButton.isHidden = true
                    
                    
//                    self.timer1 = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(TravelMapViewController.timerTriggered), userInfo: nil, repeats: true)


                   
//                }
//            })
//        }
    
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
        gmsMapView.delegate = self
        
        let defaults = UserDefaults.standard
        
        
        defaults.set("requestAccepted", forKey: "requestType")
      //  defaults.removeObject(forKey: "scdeduledRequest")
        
        var pi_lat: String = ""
        var pi_lon: String = ""
        
        var dr_lat: String = ""
        var dr_lon: String = ""
        
        let driverData: String = defaults.string(forKey: Const.CURRENT_DRIVER_DATA)!
        let driverJson: JSON = JSON.init(parseJSON: driverData)
        
        let dic = driverJson.dictionary
        
        let drv_lat: Double = (dic!["driver_latitude"]?.double)!
        let drv_log: Double = (dic!["driver_longitude"]?.double)!
        
      //  floaty?.isHidden = true
//        self.driverPoint = CLLocationCoordinate2DMake(drv_lat, drv_log)
//        self.setDriverMarker(latlong: self.driverPoint!)
        
        
        
        requestDetail.initDriver(rqObj: driverJson)
        
        
        self.driverPoint = CLLocationCoordinate2DMake(drv_lat, drv_log)
        self.setDriverMarker(latlong: self.driverPoint!)
        
        
        //let configuration = PNConfiguration(publishKey: "demo", subscribeKey: "demo")
        let configuration = PNConfiguration(publishKey: Const.Publish_key, subscribeKey: Const.Subscribe_key)
        self.client = PubNub.clientWithConfiguration(configuration)
        
        self.client.addListener(self)
        
        let channel: String  =  "\(Const.CHANNEL_ID)\(requestDetail.driver_id)"
        self.client.subscribeToChannels([channel], withPresence: false)
        //self.client.subscribeToChannels(["my_channel1","my_channel2"], withPresence: false)
        
        DATA().putDriverId(driverId: requestDetail.driver_id)
        DATA().putRequestId(reqId: requestDetail.requestId)
        
        if defaults.object(forKey: Const.PI_LATITUDE) != nil {
            pi_lat = defaults.string(forKey: Const.PI_LATITUDE)!
            pi_lon = defaults.string(forKey: Const.PI_LONGITUDE)!
            
            dr_lat = defaults.string(forKey: Const.DR_LATITUDE)!
            dr_lon = defaults.string(forKey: Const.DR_LONGITUDE)!
        }else{
            
            pi_lat = requestDetail.s_lat
            pi_lon = requestDetail.s_lon
            
            dr_lat = requestDetail.d_lat
            dr_lon = requestDetail.d_lon
        }
        
        
        let pLati = Double(pi_lat ?? "") ?? 0.0
        let pLongi = Double(pi_lon ?? "") ?? 0.0
        
        let dLati = Double(dr_lat ?? "") ?? 0.0
        let dLongi = Double(dr_lon ?? "") ?? 0.0
        
        let piPointLat : CLLocationDegrees = pLati
        piPoint = CLLocationCoordinate2DMake(pLati, pLongi)
        drPoint = CLLocationCoordinate2DMake(dLati, dLongi)
        
        
        oldCoordinate = piPoint
        
        
        if defaults.object(forKey: Const.CURRENT_INVOICE_DATA) != nil {
            let invoiceData = defaults.object(forKey: Const.CURRENT_INVOICE_DATA)! as? String ?? String()
            //let invoiceData: String = defaults.string(forKey: Const.CURRENT_INVOICE_DATA)!
            if !(invoiceData).isEmpty{
                let invoiceJson: JSON = JSON.init(parseJSON: invoiceData)
                requestDetail.initInvoice(rqObj: invoiceJson)
            }
        }
        
       
        
        requestStatusLabel.text = "Driver accepted the request".localized()
        carNumberLabel.text = "Car.No:".localized() + requestDetail.plate_no
        driverMobileLabel.text = "\(requestDetail.color) \(requestDetail.model)"
        driverNameLabel.text = requestDetail.driver_name
        pickupAdd.text = requestDetail.s_address
        
        
        
        driverImage.layer.cornerRadius = driverImage.frame.height / 2
        driverImage.clipsToBounds = true
       
        driver_car_img.layer.cornerRadius = driver_car_img.frame.height / 2
        driver_car_img.clipsToBounds = true
        
        if !(requestDetail.driver_picture).isEmpty{
            let url = URL(string: requestDetail.driver_picture)!
         
              driverImage.sd_setImage(with: url as URL?, placeholderImage:  UIImage(named: "ellipse_contacting")!)
            
        }
        else {
             driverImage.image = Toucan(image: UIImage(named: "ellipse_contacting")!).maskWithEllipse().image
        }
        
        if !(requestDetail.car_image).isEmpty{
            let url = URL(string: requestDetail.car_image)!
            
            driver_car_img.sd_setImage(with: url as URL?, placeholderImage:  UIImage(named: "newdrivercar.png")!)
            
        }
        else {
            driver_car_img.image = Toucan(image: UIImage(named: "newdrivercar.png")!).maskWithEllipse().image
        }
        
        
      //  newdrivercar.png
        moveMent = ARCarMovement()
        moveMent.delegate = self
     
//        setDriverMarkerTest()
        
//        driverMarker = GMSMarker()
//        driverMarker?.icon = #imageLiteral(resourceName: "ic_booking_lux_map_topview")
//        driverMarker?.title = "Driver"
//        driverMarker?.map = gmsMapView
        performGoogleMatrixApiCall = true
        self.startTimer()
           self.googleMatrixStartTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        addressUIView.layer.cornerRadius = 5.0
        self.addressUIView.layer.masksToBounds = true

        super.viewWillDisappear(animated)
        self.stopTimer()
        self.googleMatrixStopTimer()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(TravelMapViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifierUpdateStatus"), object: nil)
        
    }
    
    //MARK:- NotificationCenter ReceivedMethod
    
    func methodOfReceivedNotification(notification: Notification){
        
        checkRequestStatus()
    }
    
    //MARK:- MenuActionMethod
    @IBAction func menuActionMethod(_ sender: Any) {
         revealViewController().revealToggle(sender)
        
    }
    var popOverVC: CancelRideVC? = nil
    
    //MARK:- CancelRide
    func cancelRide(){
        self.cancelReasonArray.removeAll()
       self.showLoader( str: "Cancel Ride".localized())
        API.cancelRideReason {  json, error in
            
            if let error = error {
                            self.hideLoader()
                 self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        print(json[Const.DATA].array!)
                        
                        
                        let arr = json[Const.DATA].arrayValue
                        
                        if arr.count > 0 {
                            for type: JSON in arr {
                                print(type["cancel_reason"].stringValue)
                                
                                self.cancelReasonArray.append(type["cancel_reason"].stringValue)
                                self.cancelReasonId.append(type["id"].intValue)
                                
                                // print
                                
                            }
                            
                            
                            
                            self.hideLoader()
                            self.popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CancelRide") as? CancelRideVC
                            
                            self.popOverVC?.cancelRideReason = self.cancelReasonArray
                            self.popOverVC?.cancelRideId = self.cancelReasonId
                            
                            self.addChildViewController(self.popOverVC!)
                            
                            
                            self.popOverVC!.view.frame = self.view.frame
                            self.view.addSubview(self.popOverVC!.view)
                            self.didMove(toParentViewController: self)
                            //
                        }else {
                            print(json)
                            self.hideLoader()
                            debugPrint("Invalid Json :(")
                            
                        }
                    
                    }else {
                        self.hideLoader()
                        debugPrint("Invalid Json :(")
                    }
                    
                    
                }
                
            }
            
        }
        

    }
    
    //MARK:- Navigation Method
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    func goToRating(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
        self.present(nextViewContro‌​ller, animated: true, completion: nil)
    }
    
    func goToChat(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewContro‌​ller = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
//        self.navigationController?.pushViewController(nextViewContro‌​ller, animated: true)
         self.present(nextViewContro‌​ller, animated: true, completion: nil)
    }
    
    //MARK:- ContactActionMethod
    @IBAction func contactActionMethod(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Contact Driver", preferredStyle: .alert)
        let callAction: UIAlertAction = UIAlertAction(title: "Call", style: .default) { action -> Void in
            
            if !self.requestDetail.driver_mobile.isEmpty {
                
                
                
                if let url = URL(string: "tel://\(self.requestDetail.driver_mobile)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                
                
                
            }else{
                self.view.makeToast(message: "Driver number not available".localized())
            }
            
            
            //Just dismiss the action sheet
        }
        let messageAction: UIAlertAction = UIAlertAction(title: "Message".localized(), style: .default) { action -> Void in
            self.goToChat()
            
            //Just dismiss the action sheet
        }
        
        actionSheetController.addAction(callAction)
         actionSheetController.addAction(messageAction)
        self.present(actionSheetController, animated: true, completion: nil)
        
        
    }
    
    //MARK:- CancelActionMethod
    @IBAction func cancelActionMethod(_ sender: Any) {
        
        cancelMethod()
    }
    
    
    //MARK: FAB Layout Setup
    func layoutFAB() {
        
        floaty = Floaty()
        floaty?.buttonColor = UIColor(red:1.00, green:0.59, blue:0.00, alpha:1.0)
        floaty?.buttonImage = UIImage(named: "dots_vertical")
        
        var item = FloatyItem()
        item.title = "Message".localized()
        item.iconImageView.image = UIImage(named: "message_outline")
        item.buttonColor = UIColor(red:1.00, green:0.25, blue:0.51, alpha:1.0)
        item.handler =  { item in
            self.goToChat()
        }
        floaty?.addItem(item: item)
        
        item = FloatyItem()
        item.title = "Call".localized()
        item.iconImageView.image = UIImage(named: "phone_classic")
        item.buttonColor = UIColor(red:0.22, green:0.61, blue:0.68, alpha:1.0)
        item.handler =  { item in
            self.callNumber()
        }
        
        
        floaty?.addItem(item: item)
        
        item = FloatyItem()
        //item.titleLabel.text = "Cancel Trip"
        item.title = "Cancel Trip".localized()
        item.iconImageView.image = UIImage(named: "alert")
        item.buttonColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
        item.handler =  { item in
            
            let alert = UIAlertController(title: "", message: "Are you sure? You want to Cancel this Ride?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(
                title: "No",
                style: UIAlertActionStyle.cancel) { (action) in
                    // ...
            }
            
            let confirmAction = UIAlertAction(
            title: "Yes", style: UIAlertActionStyle.default) { (action) in
                // ...
                self.cancelRide()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        floaty?.addItem(item: item)
        
        self.view.addSubview(floaty!)
        floaty?.fabDelegate = self
        
        
    }
    
    //MARK:- CancelAPI
    func cancelMethod() {
        let alert = UIAlertController(title: "Cancel Ride".localized(), message: "Are you sure? You want to Cancel this Ride?".localized(), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
            title: "No".localized(),
            style: UIAlertActionStyle.cancel) { (action) in
                // ...
        }
        
        let confirmAction = UIAlertAction(
        title: "Yes".localized(), style: UIAlertActionStyle.default) { (action) in
            // ...
            self.cancelRide()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Floatybutton
    func floatyOpened(_ floaty: Floaty) {
        print("Floaty Opened")
        publishPubNub()
        
    }
    
    func floatyClosed(_ floaty: Floaty) {
        print("Floaty Closed")
    }
    
    //MARK:- Call Number
    func callNumber(){
        if !self.requestDetail.driver_mobile.isEmpty {
            

            
            if let url = URL(string: "tel://\(self.requestDetail.driver_mobile)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
      
            
        }else{
            self.view.makeToast(message: "Driver number not available".localized())
        }
    }
    // MARK:- PublishPubNub
    func publishPubNub(){
        self.client.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel",
                            compressed: false, withCompletion: { (status) in
                                
                                if !status.isError {
                                    
                                    // Message successfully published to specified channel.
                                }
                                else{
                                    
                                    /**
                                     Handle message publish error. Check 'category' property to find
                                     out possible reason because of which request did fail.
                                     Review 'errorData' property (which has PNErrorData data type) of status
                                     object to get additional information about issue.
                                     
                                     Request can be resent using: status.retry()
                                     */
                                }
        })
    }
    
    
    // MARK:- GetPolylineRoute
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&\(Const.EXTANCTION)")!
        
        print(url)
        
        //sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if let error = error {
                print("path get error")
                 self.showAlert(with :error.localizedDescription)
                print(error.localizedDescription)
            }else{
                print("path got")
                do {
                    print(data ?? "")
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as? [Any]
                        if routes?.count == 0 {
                            print("error routes count zero")
                            return
                        }
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
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    //MARK:- ShowPath
    func showPath(polyStr :String){
     
        let path:GMSPath = GMSPath(fromEncodedPath: polyStr)!
       
        polyline = GMSPolyline(path: path)
        
        
        polyline.strokeWidth = 5.0
        polyline.strokeColor = UIColor.black
        polyline.map = gmsMapView // Your map view
        //gmsMapView.bounds
        
//        var bounds = GMSCoordinateBounds()
//        
//        for index:UInt in 1...path.count() {
//            bounds = bounds.includingCoordinate(path.coordinate(at: index))
//        }
//        
//        gmsMapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    //MARK:- Timer Status
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
         self.googleMatrixStopTimer()
    }
    var googleMatrixtimer: DispatchSourceTimer?
    
    func googleMatrixStartTimer() {
        let queue = DispatchQueue(label: "com.prov.nikola.timer")  // you can also use `DispatchQueue.main`, if you want
        googleMatrixtimer = DispatchSource.makeTimerSource(queue: queue)
        googleMatrixtimer!.scheduleRepeating(deadline: .now(), interval: .seconds(20))
        googleMatrixtimer!.setEventHandler { [weak self] in
            // do whatever you want here
            
            self?.performGoogleMatrixApiCall = true
        }
        googleMatrixtimer!.resume()
    }
    
    func googleMatrixStopTimer() {
        googleMatrixtimer?.cancel()
        googleMatrixtimer = nil
        self.performGoogleMatrixApiCall = false
    }
    

    //MARK:- CheckRequstStatus
    func checkRequestStatus(){
        API.checkRequestStatus{ json, error in
            
            if let error = error {
                //self.hideLoader()
                 //self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    let isRideCancelled = json[Const.IS_RIDE_CANCELLED].boolValue
                        if(status){
                    
                            var requestDetail: RequestDetail = RequestDetail()
                            let jsonAry:[JSON]  = json[Const.DATA].arrayValue
                                let defaults = UserDefaults.standard
                    
                                            print(jsonAry)
                    
                    //                        print(jsonAry[0]["provider_mobile"].string!)
                    
                    
                                if jsonAry.count > 0 {
                    
                    
                                            if let providerMob = jsonAry[0]["provider_mobile"].string {
//                                                                            self.driverMobileLabel.text = "Mobile:" +  jsonAry[0]["provider_mobile"].string!
                                                                            self.driverNameLabel.text = jsonAry[0]["provider_name"].string!
                    
                    
                                                                            let providerImg : String =  jsonAry[0]["provider_picture"].string!
                    
                                                                            print(providerImg)
                    
                    
//                                                                            if !(providerImg).isEmpty{
//                                                                                let url = URL(string: providerImg)!
//
//                                                                                self.driverImage.sd_setImage(with: url as URL?, placeholderImage:nil)
//
//                                                                            }
//                                                                            else {
////                                                                                self.driverImage.image = Toucan(image: UIImage(named: "ellipse_contacting")!).maskWithEllipse().image
//                                                                            }
//
                    
                                                                        }
                                                //
                    
                    
                    
                                            }
                    
                    
                    
                    
                    
                                            if jsonAry.count > 0 {
                                                let driverData = jsonAry[0]
                                                if driverData.exists() {
                    
                                                    defaults.set(driverData["request_id"].stringValue, forKey: Const.Params.REQUEST_ID)
                                                    defaults.set(driverData["provider_id"].stringValue, forKey: Const.Params.DRIVER_ID)
                                                    requestDetail.initDriver(rqObj: driverData)
                    
                                                    self.driverPoint = CLLocationCoordinate2DMake(requestDetail.driver_latitude, requestDetail.driver_longitude)
                                                    self.setDriverMarker(latlong: self.driverPoint!)
                                                }
                                                let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
                                                if invoiceAry.count > 0 {
                                                    let invoiceData = invoiceAry[0]
                                                    print("invoice json")
                                                    print(invoiceData.rawString() ?? "invoiceData null")
                                                    defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                                                    requestDetail.initInvoice(rqObj: invoiceData)
                                                }
                                                if(self.performGoogleMatrixApiCall)!
                                                {
                                                self.processStatus(json: json, tripStatus:requestDetail.tripStatus)
                                                }
                                            }
                                            else if(isRideCancelled){
                                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                                appDelegate.window?.makeToastMiddle(message: "Unfortunately your driver had to cancel the trip. Please try again".localized())
                                                requestDetail.tripStatus = Const.NO_REQUEST
                                                let defaults = UserDefaults.standard
                                                defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
                                                let delay = 2 * Double(NSEC_PER_SEC)
                                                
                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)) { () -> Void in
                                                    
                                                    self.goToDashboard()
                                                }
                                                
                                                
                                            }
                                            else {
                                                requestDetail.tripStatus = Const.NO_REQUEST
                                                let defaults = UserDefaults.standard
                                                defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
                                                self.goToDashboard()
                                            }
                                            //self.goToDashboard()
                                            //self.view.makeToast(message: "Logged In")
                                        }else{
                                            print(statusMessage)
                                            print(json ?? "json empty")
                            if let msg : String = json[Const.ERROR].rawString() {
                                self.view.makeToast(message: msg)
                            }
                            
//                                            var msg = json[Const.ERROR].rawString()!
//                                            self.view.makeToast(message: msg)
                                        }
                    
                }else {
                    debugPrint("Invalid Json :(")
                }
                
            }
            

        }
    }
    
    //MARK:- ProcessStatus
    func processStatus(json: JSON, tripStatus: Int){
          performGoogleMatrixApiCall = false
        let defaults = UserDefaults.standard
        let requestDetail: RequestDetail = RequestDetail()
        let jsonAry:[JSON]  = json[Const.DATA].arrayValue
        
    
        
        
        if jsonAry.count > 0 {
            let driverData = jsonAry[0]
            if driverData.exists() {
                //saving driver data
                defaults.set(driverData.rawString(), forKey: Const.CURRENT_DRIVER_DATA)
                defaults.set(driverData["request_id"].stringValue, forKey: Const.Params.REQUEST_ID)
                requestDetail.initDriver(rqObj: driverData)
            }
        }
        
        // saving invoice data
        let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
        if invoiceAry.count > 0 {
            let invoiceData = invoiceAry[0]
            defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
            requestDetail.initInvoice(rqObj: invoiceData)
        }
        switch(tripStatus){
            
        case Const.NO_REQUEST:
            PreferenceHelper.clearRequestData()
            self.view.makeToast(message: "No Providers found please try after some time!")
            self.stopTimer()
            self.googleMatrixStopTimer()
            print("No Providers found please try after some time!")
        case Const.IS_ACCEPTED:
            
            defaults.set(Const.IS_ACCEPTED, forKey: Const.DRIVER_STATUS)
            //print("Driver accepted")
            let jsonAry:[JSON]  = json[Const.DATA].arrayValue
            if jsonAry.count > 0 {
                let driverData = jsonAry[0]
                if driverData.exists() {
                
                    self.jobStatus = Const.IS_ACCEPTED;
                    addressTitle.text = "Pickup Address".localized()
                    addressTitle.textColor = UIColor(red:0.09, green:0.85, blue:0.24, alpha:1.0)
                    
                    pickupAdd.text = requestDetail.s_address
                    requestStatusLabel.text = "DRIVER ACCEPTED THE REQUEST".localized()
                }
                
                // saving invoice data
                let invoiceAry:[JSON]  = json[Const.INVOICE].arrayValue
                if invoiceAry.count > 0 {
                    let invoiceData = invoiceAry[0]
                    defaults.set(invoiceData.rawString(), forKey: Const.CURRENT_INVOICE_DATA)
                    requestDetail.initInvoice(rqObj: invoiceData)
                }
            }
             self.findDistanceandTime(loc1: self.driverPoint!, loc2: self.piPoint!)
        case Const.IS_DRIVER_DEPARTED:
            self.jobStatus = Const.IS_DRIVER_DEPARTED;
                addressTitle.text = "Pickup Address".localized()
                        addressTitle.textColor = UIColor(red:0.09, green:0.85, blue:0.24, alpha:1.0)
                        pickupAdd.text = requestDetail.s_address
                        requestStatusLabel.text = "DRIVER IS ON THE WAY".localized()
                        self.findDistanceandTime(loc1: self.driverPoint!, loc2: self.piPoint!)
            
        case Const.IS_DRIVER_ARRIVED:
            self.jobStatus = Const.IS_DRIVER_ARRIVED;
            addressTitle.text = "Drop Address".localized()
            addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
            
            if (requestDetail.d_address ).isEmpty{
                pickupAdd.text = "--Not Available--"
            }else{
                pickupAdd.text = requestDetail.d_address
            }
            requestStatusLabel.text = "DRIVER HAS ARRIVED AT YOUR PLACE".localized()
            if cancelRequestButton != nil {
                cancelRequestButton.removeFromSuperview()
            }
//            if (floaty?.items.count)! > 2 {
//                self.floaty?.removeItem(index: 2)
//            }
            self.findDistanceandTime(loc1: self.driverPoint!, loc2: self.piPoint!)
        case Const.IS_DRIVER_TRIP_STARTED:
            self.jobStatus = Const.IS_DRIVER_TRIP_STARTED;
            addressTitle.text = "Drop Address".localized()
            addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
            
            self.getPolylineRoute(from: self.driverPoint!, to: drPoint!)
            if cancelRequestButton != nil {
                cancelRequestButton.removeFromSuperview()
            }
            
            self.findDistanceandTime(loc1: self.driverPoint!, loc2: self.drPoint!)
            
            
            if (requestDetail.d_address ).isEmpty{
                pickupAdd.text = "--Not Available--"
            }else{
                pickupAdd.text = requestDetail.d_address
            }
            
            
            
            requestStatusLabel.text = "YOUR TRIP HAS BEEN STARTED".localized()

           // self.findDistanceandTime(loc1: self.driverPoint!, loc2: self.drPoint!)
        case Const.IS_DRIVER_TRIP_ENDED:
            self.jobStatus = Const.IS_DRIVER_TRIP_ENDED;
            addressTitle.text = "Drop Address".localized()
            addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
            
            if (requestDetail.d_address ).isEmpty{
                pickupAdd.text = "--Not Available--"
            }else{
                pickupAdd.text = requestDetail.d_address
            }
            requestStatusLabel.text = "YOUR TRIP IS COMPLETED".localized()
//            if (floaty?.items.count)! > 2 {
//                self.floaty?.removeItem(index: 2)
//            }
            
            
//            self.findDistanceandTime(loc1: self.driverMovingPoint!, loc2: self.drPoint!)
            stopTimer()
            goToRating()
            
        case Const.IS_DRIVER_RATED:
            self.jobStatus = Const.IS_DRIVER_RATED;
            addressTitle.text = "Drop Address".localized()
            addressTitle.textColor = UIColor(red:0.98, green:0.08, blue:0.04, alpha:1.0)
            
            if (requestDetail.d_address ).isEmpty{
                pickupAdd.text = "--Not Available--"
            }else{
                pickupAdd.text = requestDetail.d_address
            }
            requestStatusLabel.text = "YOUR TRIP IS COMPLETED".localized()
//            if (floaty?.items.count)! > 2 {
//                self.floaty?.removeItem(index: 2)
//            }
            stopTimer()
            googleMatrixStopTimer()
            goToRating()
            
        default:
            print("something else happened")
        }
        
    }
    
    //MARK:- SetDriverMarker
    func setDriverMarker( latlong: CLLocationCoordinate2D){
        
        //return
        
        if latlong == nil {
            return
        }
        
                if driverMarker == nil {
        
                    driverMarker = GMSMarker(position: latlong)
                    driverMarker?.icon = #imageLiteral(resourceName: "ic_booking_lux_map_topview")
                    driverMarker?.title = "Driver".localized()
                    driverMarker?.map = gmsMapView
                }else{
                driverMarker?.position = latlong
                }
        
    }
    
    func setDriverMarkerTest(){
        return
            
            driverMarker = GMSMarker()
        driverMarker?.position = oldCoordinate
        driverMarker?.icon = #imageLiteral(resourceName: "ic_booking_lux_map_topview")//UIImage(named: "car-1")
        driverMarker?.map = gmsMapView
        
    }
    
    // MARK:- PubNub
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            // let msg : Dictionary = message.data.message as! Dictionary[String:String]
            //            let msgStr : String = message.data.message as! String
            //            message.data.
            //            let msgJson = JSON.init(parseJSON: msgStr)
            //
            //            let lat  = msgJson["lat"].doubleValue
            //            let lon  = msgJson["lan"].doubleValue
            
            do{
                let dict = message.data.message as! Dictionary<String, Any>
                //let msg  = message.data.message as! [String:Any]?
                let lat: Double  = try (dict["lat"] as! Double?)!
                let lon: Double  = try (dict["lan"] as! Double?)!
                rotoation = try (dict["heading"] as! Double?)!
                
                
                //                 driverMarker.rotation = rotoation
                
                
                
                driverMovingPoint = CLLocationCoordinate2DMake(lat, lon)
                
                
                timer1 = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(TravelMapViewController.timerTriggered), userInfo: nil, repeats: true)
                
                //                moveToNextPosition(newCoordinate: CLLocationCoordinate2DMake(lat, lon))
                // Message has been received on channel stored in message.data.channel.
            }catch{
                print(error.localizedDescription)
            }
        }
        
        print("Received message: \(message.data.message) on channel \(message.data.channel) at \(message.data.timetoken)")
    }
    
    
    
    
    func timerTriggered() {
        
        
//        print(driverMovingPoint.latitude)
        
        if let lat : Double = driverMovingPoint.latitude {
            
              moveToNextPosition(newCoordinate: driverMovingPoint)
            
//              self.findDistanceandTime(loc1: driverMovingPoint!, loc2: self.drPoint!)
       
            
        }
        
        
      
        
        
        //        print("movetonext")
        
    }
    
    
    
    // Handle subscription status change.
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        if status.operation == .subscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                    
                    // Select last object from list of channels and send message to it.
                    let targetChannel = client.channels().last!
                    /* client.publish("Hello from the PubNub Swift SDKdd", toChannel: targetChannel,
                     compressed: false, withCompletion: { (publishStatus) -> Void in
                     
                     if !publishStatus.isError {
                     
                     // Message successfully published to specified channel.
                     }
                     else {
                     
                     /**
                     Handle message publish error. Check 'category' property to find out
                     possible reason because of which request did fail.
                     Review 'errorData' property (which has PNErrorData data type) of status
                     object to get additional information about issue.
                     
                     Request can be resent using: publishStatus.retry()
                     */
                     }
                     })
                     */
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
            }
            else if status.category == .PNUnexpectedDisconnectCategory {
                
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                }
            }
        }
        else if status.operation == .unsubscribeOperation {
            
            if status.category == .PNDisconnectedCategory {
                
                /**
                 This is the expected category for an unsubscribe. This means there was no error in
                 unsubscribing from everything.
                 */
            }
        }
        else if status.operation == .heartbeatOperation {
            
            /**
             Heartbeat operations can in fact have errors, so it is important to check first for an error.
             For more information on how to configure heartbeat notifications through the status
             PNObjectEventListener callback, consult http://www.pubnub.com/docs/ios-objective-c/api-reference-configuration#configuration_basic_usage
             */
            
            if !status.isError { /* Heartbeat operation was successful. */ }
            else { /* There was an error with the heartbeat operation, handle here. */ }
        }
    }
    
    // MARK: - scheduledTimerWithTimeInterval Action
    //func timerTriggered() {
    func moveToNextPosition(newCoordinate: CLLocationCoordinate2D) {
        // if counter < coordinateArr.count {
        if true {
            
            //            let dict = coordinateArr[counter] as? Dictionary<String,AnyObject>
            //
            //            let newCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(dict!["lat"] as! Float), CLLocationDegrees(dict!["long"] as! Float))
            /**
             *  You need to pass the created/updating marker, old & new coordinate, mapView and bearing value from driver
             *  device/backend to turn properly. Here coordinates json files is used without new bearing value. So that
             *  bearing won't work as expected.
             */
            moveMent.arCarMovement(driverMarker, withOldCoordinate: oldCoordinate, andNewCoordinate: newCoordinate, inMapview: gmsMapView, withBearing: 0)
            oldCoordinate = newCoordinate
            
            
            //            print("movetonext")
            
            //counter = counter + 1
            //increase the value to get all index position from array
        }
        else {
            //            timer.invalidate()
            //            timer = nil
        }
    }
    
    // MARK: - ARCarMovementDelegate
    func arCarMovement(_ movedMarker: GMSMarker) {
        
        
//        print(rotoation)
        
        if let rota : Double = rotoation {
            
             driverMarker.rotation = rotoation
            
        }
        
        
       
        
        driverMarker = movedMarker
        
        
        driverMarker?.map = gmsMapView
        
        
    
        
        
        
        
//          gmsMapView.camera = GMSCameraPosition(target: driverMovingPoint!, zoom: 16, bearing: 0, viewingAngle: 0)
        
//        if updateLocationPoint.latitude == driverMovingPoint.latitude {
//            
//            
//        }
//        else {
        
            
            let updatedCamera = GMSCameraUpdate.setTarget((driverMarker?.position)!, zoom: 18.0)
            
            
            
                    gmsMapView.animate(with: updatedCamera)
            
//        }
        
        
   

    }
    
    //MARK:- Finding Distance
    func findDistanceandTime(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let pi_lat: String = String(loc1.latitude)
        let pi_lon: String = String(loc1.longitude)
        
        let dr_lat: String = String(loc2.latitude)
        let dr_lon: String = String(loc2.longitude)
        
        
        var path : String = "\(Const.GOOGLE_MATRIX_URL)\(Const.Params.ORIGINS)=\(pi_lat),\(pi_lon)&\(Const.Params.DESTINATION)=\(dr_lat),\(dr_lon)&\(Const.Params.MODE)=driving&\(Const.Params.KEY)=\(Const.googlePlaceAPIkey)&\(Const.Params.LANGUAGE)=en-EN&\(Const.Params.SENSOR)=false"
        
        
          path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        print(path)
        
//      let strURL = url?.path
        
        
        API.googlePlaceAPICall(with: path){ responseObject, error in
            
            print(error ?? "Any")
            if let error = error {
                //self.hideLoader()
                // self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                return
            }
            
            
            if let resData = responseObject {
//
//                
                let json = self.jsonParser.jsonParser(dicData: resData)
                
                print(json)
//
//                
                if let dic = json["rows"].array, dic.count > 0 {
//
                    
                    if let value = dic[0]["elements"].array {
                        
                        print(value[0]["duration"])
                        
                        let durationeDic = value[0]["duration"].dictionary
//
//                        
//                        
                        if let duration = durationeDic?["text"]?.string {
                            
                            print(duration)
                            
                            
                            if let etaView = UIView.viewFromNibName("EtaView") as? EtaView {
                                etaView.etaLabel.text = duration
                                    self.drop_marker?.iconView = etaView
                            }

                            
                        }
                    
                    }
                    }
                
            }
            
            
            }
        
            }
}

// MARK: - CLLocationManagerDelegate
extension TravelMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            gmsMapView.isMyLocationEnabled = true
            gmsMapView.settings.myLocationButton = true
            
            //        let position = CLLocationCoordinate2D(latitude: 40.717041, longitude: -73.988007)
            //        let hello = GMSMarker(position: position)
            //        hello.title = "Hello world!"
            //        hello.snippet = "Welcome to my marker"
            //
            //        hello.map = mapView
            
            let pi_lat: String = requestDetail.s_lat
            let pi_lon: String = requestDetail.s_lon
            
            
            
            
            
            
            
            let dr_lat: String = requestDetail.d_lat
            let dr_lon: String = requestDetail.d_lon
            
            let pLati = Double(pi_lat ?? "") ?? 0.0
            let pLongi = Double(pi_lon ?? "") ?? 0.0
            
            let dLati = Double(dr_lat ?? "") ?? 0.0
            let dLongi = Double(dr_lon ?? "") ?? 0.0
            
            piPoint = CLLocationCoordinate2DMake(pLati, pLongi)
            drPoint = CLLocationCoordinate2DMake(dLati, dLongi)
            
            gmsMapView.camera = GMSCameraPosition(target: piPoint!, zoom: 15, bearing: 0, viewingAngle: 0)
            
            gmsMapView.settings.scrollGestures = true
            if piPoint != nil && (piPoint?.latitude != 0 && piPoint?.longitude != 0){
                pick_marker = GMSMarker(position: piPoint!)
                pick_marker?.title = "Pickup location".localized()
                //pick_marker?.snippet = self.nearest_eta
                pick_marker?.icon = #imageLiteral(resourceName: "map_pick_marker")
                pick_marker?.map = gmsMapView
                
                
                
                
            }
            
             locationManager.stopUpdatingLocation()
            
            if drPoint != nil && (drPoint?.latitude != 0 && drPoint?.longitude != 0){
                drop_marker = GMSMarker(position: drPoint!)
                drop_marker?.title = "Drop location".localized()
                //drop_marker?.title = nearest_eta
                drop_marker?.icon = #imageLiteral(resourceName: "map_drop_marker")
                drop_marker?.map = gmsMapView
                
                
                if let etaView = UIView.viewFromNibName("EtaView") as? EtaView {
                    etaView.etaLabel.text = "--"
                    drop_marker?.iconView = etaView
                }

                
            }
            
            if piPoint != nil && drPoint != nil{
                self.getPolylineRoute(from: self.piPoint!, to: drPoint!)
                
            }
            
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            gmsMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//            locationManager.stopUpdatingLocation()
//        }
//    }
}

// MARK: - GMSMapViewDelegate
extension TravelMapViewController {
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
    
//    func mapView(_ mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
//        let placeMarker = marker as! PlaceMarker
//        
//        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
//            infoView.nameLabel.text = placeMarker.place.name
//            
//            if let photo = placeMarker.place.photo {
//                infoView.placePhoto.image = photo
//            } else {
//                infoView.placePhoto.image = UIImage(named: "generic")
//            }
//            
//            return infoView
//        } else {
//            return nil
//        }
//    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView!) -> Bool {
        // mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
}

