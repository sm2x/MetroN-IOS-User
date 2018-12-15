//
//  RatingViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/29/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import Cosmos
import SwiftyJSON
import AlamofireImage
import Toucan
import SDWebImage

class RatingViewController : UIViewController{
    
    
    
    
    @IBOutlet weak var fareAmount: UILabel!
    @IBOutlet weak var btnsubmit: UIButton!
    @IBOutlet weak var lblratethecustomer: UILabel!
    
    @IBOutlet weak var lbltripsummary: UILabel!
    @IBOutlet weak var lblfareamount: UILabel!
    
    @IBOutlet weak var carImageView: UIImageView!
    
    @IBOutlet weak var driverImageView: UIImageView!
    
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var durationLabel: UIButton!
    
    @IBOutlet weak var distanceLabel: UIButton!
    
    @IBOutlet weak var cancelfee: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    
    
    var currency : String = ""
    
    var requestDetail: RequestDetail = RequestDetail()
    var isPayShowing: Bool = false
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //driver data null check this. during paynow
        let defaults = UserDefaults.standard
        let driverData: String = DATA().getCurrentDriverData()
        //defaults.string(forKey: Const.CURRENT_DRIVER_DATA)!
        if !driverData.isEmpty{
            let driverJson: JSON = JSON.init(parseJSON: driverData)
            requestDetail.initDriver(rqObj: driverJson)
        }
        defaults.removeObject(forKey: "requestType")
        
        if let curr: String = UserDefaults.standard.string(forKey: "currency") {
            
            currency = curr
            
        }
        

        
        if let canfee : String = UserDefaults.standard.string(forKey: Const.CANCELLATION_FINE) {
            
            if canfee == "0" {
                
                self.cancelfee.text = ""
            }else {
                
                self.cancelfee.text = "Your Trip Cancellation fee: \(currency)"  + canfee
            }
            
        }
        
        
//        if UserDefaults.standard.string(forKey: "currency") == nil {
//
//        }
//        else {
//            currency = UserDefaults.standard.string(forKey: "currency")!
//        }
        
        
        
        //        if UserDefaults.standard.string(forKey: "currency")! == nil {
        //
        //        }
        //        else {
        //            currency = UserDefaults.standard.string(forKey: "currency")!
        //        }
        
        //        if let cuurent = UserDefaults.standard.string(forKey: "currency")!{
        //             currency = UserDefaults.standard.string(forKey: "currency")!
        //        }
        
        
        
        // print(UserDefaults.standard.string(forKey: "currency")!)
        
        if defaults.object(forKey: Const.CURRENT_INVOICE_DATA) != nil {
            let invoiceData = defaults.object(forKey: Const.CURRENT_INVOICE_DATA)! as? String ?? String()
            //let invoiceData: String = defaults.string(forKey: Const.CURRENT_INVOICE_DATA)!
            if !(invoiceData ?? "").isEmpty{
                let invoiceJson: JSON = JSON.init(parseJSON: invoiceData)
                requestDetail.initInvoice(rqObj: invoiceJson)
            }
        }
        
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "backArrow"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let item1 = UIBarButtonItem(customView: btn1)
        
        
        
        self.navItem.setLeftBarButton(item1, animated: true)
        
        self.navBar.tintColor = UIColor.black
        
        let dist : Double = Double(requestDetail.trip_time)!
        
        let roundedValuedist : Double = round(dist)
        
        
        let distval : String = String(format: "%.2f", roundedValuedist)
       
        durationLabel.setTitle("\(distval) mins", for: UIControlState.normal)
        distanceLabel.setTitle("\(requestDetail.trip_distance) \(requestDetail.trip_distance_unit)", for: UIControlState.normal)
        
        let amount : Double = Double(requestDetail.trip_total_price)!
        
        let roundedValue : Double = round(amount)
        
        
        
        
        let fare : String = String(format: "%.2f", amount)
         fareAmount.text = "\(currency) \(requestDetail.trip_total_price)"
        
        
//        if UserDefaults.standard.string(forKey: "currency") == nil {
//            fareAmount.text = "₹ \(fare)"
//        }
//        else {
//            fareAmount.text = "₹ \(requestDetail.trip_total_price)"
//        }
        
        
        
        let size = CGSize(width: 100.0, height: 100.0)
        let filter = AspectScaledToFillSizeCircleFilter(size: size)
        
        carImageView.layer.cornerRadius = driverImageView.bounds.width/2
        
        if !((requestDetail.vehical_img ?? "").isEmpty)
        {
            
            
            
            //            let url = URL(string: requestDetail.vehical_img.decodeUrl())!
            //            let placeholderImage = UIImage(named: "ellipse_contacting")!
            //
            //
            //            carImageView?.af_setImage(
            //                withURL: url,
            //                placeholderImage: placeholderImage,
            //                filter: filter
            //            )
            
            var pic: String = requestDetail.vehical_img
            
            pic = pic.decodeUrl()
            
            let url = URL(string: pic)!
            
            
            print(url)
            
            carImageView.sd_setImage(with: url as URL?, placeholderImage:  UIImage(named: "defult_user")!)
            
        }else{
            carImageView.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }
        
        //        driverImageView.layer.borderColor = UIColor.orange.cgColor
        driverImageView.layer.cornerRadius = driverImageView.bounds.width/2
        
        if !((requestDetail.driver_picture ?? "").isEmpty)
        {
            //            let url2 = URL(string: requestDetail.driver_picture.decodeUrl())!
            //            let placeholderImage2 = UIImage(named: "ellipse_contacting")!
            //
            //            driverImageView?.af_setImage(
            //                withURL: url2,
            //                placeholderImage: placeholderImage2,
            //                filter: filter
            //            )
            var pic: String = requestDetail.driver_picture
            
            pic = pic.decodeUrl()
            
            let url = URL(string: pic)!
            
            
            print(url)
            
            driverImageView.sd_setImage(with: url as URL?, placeholderImage:  UIImage(named: "defult_user")!)
            
        }else{
            driverImageView.image = Toucan(image: UIImage(named: "driver")!).maskWithEllipse().image
        }
        
        
        let url3 = URL(string: getGoogleMapThumbnail(lati: Double(requestDetail.d_lat)!, longi: Double(requestDetail.d_lon)!))!
        let placeholderImage3 = UIImage(named: "ellipse_contacting")!
        
        locationImageView?.af_setImage(
            withURL: url3,
            placeholderImage: placeholderImage3,
            filter: filter
        )
        
        
        lblfareamount.text = "Total Fare".localized()
        lbltripsummary.text = "Trip Summary".localized()
        lblratethecustomer.text = "Rate the Driver".localized()
        //        if requestDetail.driverStatus == 3 && !isPayShowing {
        //            //showPayDialog()
        //
        //        }
        
    }
    
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        giveRating()
    }
    
    
    func sendPay(){
        
        let ispaid: String = "1"
        print(requestDetail.payment_mode)
        let paymentMode: String = requestDetail.payment_mode
        
        API.sendPay(isPaid: ispaid, paymentMode: paymentMode){ json, error in
            
            if let error = error {
                //self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        print(json ?? "error in sendPay json")
                        
                    }else{
                        // print(statusMessage)
                        print(json ?? "sendPay json empty")
                        
                        if let msg : String = json[Const.ERROR].rawString(){
                            self.showAlert(with: msg)
                        }
                        
                        // var msg = json[Const.ERROR].rawString()!
                        
                        
                        //                var msg = json![Const.DATA].rawString()!
                        //                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        //
                        //                self.view.makeToast(message: msg)
                    }
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
                
            }
            
            
            
            
        }
    }
    
    func giveRating(){
        
        let comment:String = ""
        let ratingValue: Int = Int(exactly:ratingBar.rating)!
        let rating: String = "\(ratingValue)"
        
        API.giveRating(rating: rating, comment: comment){ json, error in
            
            if let error = error {
                //self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        print(json ?? "error in sendPay json")
                        
                        self.goToDashboard()
                    }else{
                        // print(statusMessage)
                        print(json ?? "sendPay json empty")
                        //var msg = json![Const.DATA].rawString()!
                        //                msg = msg.replacingOccurrences( of:"[{}\",]", with: "", options: .regularExpression)
                        
                        
                        if let errorCode : Int = json["error_code"].int {
                            if errorCode == 150 {
                                self.view.makeToast(message: "Waiting for driver to confirm the payment".localized())
                            }
                        }
                        
                        // let errorCode: Int = json["error_code"].int!
                        
                        
                        
                    }
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
                
            }
            
            
        }
    }
    
    func showPayDialog(){
        
        isPayShowing = true
        let alert = UIAlertController(title: "", message: "Your Ride is complete!\n\nYou need to pay: \(UserDefaults.standard.string(forKey: "currency")!) \(self.requestDetail.trip_total_price)", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(
        title: "Yes", style: UIAlertActionStyle.default) { (action) in
            self.sendPay()
        }
        
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getGoogleMapThumbnail(lati: Double, longi: Double) -> String {
        let staticMapUrl: String = "https://maps.google.com/maps/api/staticmap?center=\(lati),\(longi)&markers=\(lati),\(longi)&zoom=14&size=150x120&sensor=false&\(Const.Params.KEY)=\(Const.googlePlaceAPIkey)";
        return staticMapUrl;
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
    
}


