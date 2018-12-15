//
//  FairEstimatePopUpViewController.swift
//  Nikola
//
//  Created by Sutharshan on 5/29/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Toucan
import SDWebImage

class FairEstimatePopUpViewController: UIViewController {
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var serviceTypeLabel: UILabel!
    
    @IBOutlet weak var approximateDistanceLabel: UILabel!
    @IBOutlet weak var approximateFareLabel: UILabel!
    
    @IBOutlet weak var moreInfoButton: UIButton!
    
    var currency : String = ""
    
    @IBAction func doneAction(_ sender: UIButton) {
    self.view.removeFromSuperview()
    }
    
    var serviceType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let defaults = UserDefaults.standard
        let taxiString: String = defaults.string(forKey: Const.TAXI_LONG_PRESS)!
        
        
        currency = UserDefaults.standard.string(forKey: "currency")!
        
        let taxiJson: JSON = JSON.init(parseJSON: taxiString)
        let taxi : TaxiType = TaxiType.init(taxiObj: taxiJson)
        serviceType = taxi.id
        

        serviceTypeLabel.text = taxi.type
//        costperKmLabel.text = taxi.price_distance
//        costperMinLabel.text = taxi.price_min
        approximateFareLabel.text = "..."
        let seats: String = taxi.seats
        approximateDistanceLabel.text =  "1 - \(seats)"
        
//        let url = URL(string: taxi.picture.decodeUrl())!
//        let placeholderImage = UIImage(named: "ellipse_contacting")!
//        
//        let size = CGSize(width: 100.0, height: 100.0)
//        let filter = AspectScaledToFillSizeCircleFilter(size: size)
//        
//        carImageView?.af_setImage(
//            withURL: url,
//            placeholderImage: placeholderImage,
//            filter: filter
//        )
        
        carImageView.layer.cornerRadius = carImageView.frame.height / 2
        carImageView.clipsToBounds = true
        
        
        if !((taxi.picture ?? "").isEmpty)
        {
            let url = URL(string: taxi.picture.decodeUrl())!
            
            carImageView.sd_setImage(with: url as URL?, placeholderImage:  UIImage(named: "taxi")!)
            
        }else{
            carImageView.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }

//        moreInfoButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit

        findDistanceTime()
    
    }
    
    @IBAction func moreInfoAction(_ sender: UIButton) {
    }
    func findDistanceTime(){
        
        let defaults = UserDefaults.standard
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let dr_lat: String = defaults.string(forKey: Const.DR_LATITUDE)!
        let dr_lon: String = defaults.string(forKey: Const.DR_LONGITUDE)!
        
        
        let url = URL(string: Const.GOOGLE_MATRIX_URL + Const.Params.ORIGINS + "="
            + pi_lat + "," + pi_lon + "&" + Const.Params.DESTINATION + "="
            + dr_lat + "," + dr_lon + "&" + Const.Params.MODE + "="
            + "driving" + "&" + Const.Params.LANGUAGE + "="
            + "en-EN" + "&" + Const.Params.KEY + "=" + Const.googlePlaceAPIkey + "&" + Const.Params.SENSOR + "="
            + "false")
        print(url)
    
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
    let task = session.dataTask(with: url!, completionHandler: {
        (data, response, error) in
        if error != nil {
            //print("path get error")
            print(error!.localizedDescription)
        }else{
            print("path got")
            do {
                print(data ?? " data couldnt be printed")
                if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                    
//                    self.approximateDistanceLabel.text = "hello"
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String!
                    print(outputStr ?? " output str ")
                    
                    let jsonOut: JSON = JSON.parse(outputStr!)
                    let distance = jsonOut["rows"][0]["elements"][0]["distance"]["text"].stringValue
                    print(distance ?? "distance error")
                    let distanceValue = jsonOut["rows"][0]["elements"][0]["distance"]["value"].stringValue
                    print(distanceValue ?? "value error")
                    
                    let durationValue = jsonOut["rows"][0]["elements"][0]["duration"]["value"].stringValue
                    print(durationValue ?? "value error")
                    
                    let dist : Double = Double(distanceValue)! * 0.001
                    
//                    self.approximateDistanceLabel.text = distance
                    
                    API.getFare(distance: "\(dist)", duration: durationValue, serviceType: self.serviceType){ json, error in
                        if error != nil {
                            print(error!.localizedDescription)
                        }else{
                        let status = json![Const.STATUS_CODE].boolValue
                        let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                        if(status){
                            
                            DATA().putFareEstimateData(data: (json?.rawString())!)
                            print("Full getfare JSON")
                            print(json ?? "json null")
                            
                            if let totalFare = Double(json!["estimated_fare"].stringValue) {
                                
                                let fare = String(format: "%.2f",totalFare)
                        
                                self.approximateFareLabel.text = "\(self.currency) \(fare)"
                            }
                            else {
                                let fare = json!["estimated_fare"].stringValue;
                                self.approximateFareLabel.text = "\(self.currency) \(fare)"
                            }
                            print("getFare  success.")
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
                    
                    
                }
                
            }catch{
                print("error in JSONSerialization")
            }
        }
    })
    task.resume()
    }
}
