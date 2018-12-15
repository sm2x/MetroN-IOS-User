//
//  ScheduledRidesViewController.swift
//  Nikola
//
//  Created by Sutharshan Ram on 15/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Toucan

class ScheduledRidesViewController : UITableViewController{
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    
     var hud : MBProgressHUD = MBProgressHUD()
    
    let reuseIdentifier: String = "ScheduledRideCell"
    var rides:[ScheduledRideItem] = []
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        
//        
//        let btn1 = UIButton(type: .custom)
//        btn1.setImage(UIImage(named: "Burger"), for: .normal)
//        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//        btn1.addTarget(self, action: #selector(RideHistoryViewController.backButton), for: .touchUpInside)
//        let item1 = UIBarButtonItem(customView: btn1)
//        
//        self.navItem.setLeftBarButton(item1, animated: true)
//        
//        
//        self.navBar.tintColor = UIColor.darkGray
        
       fetchScheduledRides()
        
        self.tableView.tableFooterView = UIView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
      
       // UIApplication.shared.isStatusBarHidden = true
        
    }

    
    
    func backButton(sender: Any) {
        
        
        revealViewController().revealToggle(sender)
        
        
        
    }

    
    
    func fetchScheduledRides(){
        
        self.showLoader(str: "Loading ScheduledRides...")
        
        
        API.fetchSheduledRides{ json, error in
            
            if let error = error {
                self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                                    //DATA().putTaxiTypesData(request: json![Const.DATA].rawString()!)
                        let typesArray = json[Const.DATA].arrayValue
                    
                              print(typesArray)
                    
                        self.rides.removeAll()
                        for type: JSON in typesArray {
                                self.rides.append(ScheduledRideItem.init(jsonObj: type))
                        }
                            print(json ?? "error in fetchRideHistory json")
                             self.hideLoader()
                             self.tableView.reloadData()
                    
                        }else{
                            print(statusMessage)
                            print(json ?? "json empty")
                    
                            self.hideLoader()
                    
                        if let error_Code = json[Const.ERROR_CODE].int {
                    
                            if error_Code == 104 {
                    
                                    self.showAlert(with: "Session expired")
                    
                                }
                            else {
                    
                                if let msg : String = json[Const.NEW_ERROR].rawString() {
                                    self.showAlert(with: msg)
                                }

                    
                    
                                }
                    
                    
                            }
            
                         }
                }else {
                    self.hideLoader()
                    debugPrint("Invalid Json :(")
                }
                
            }
            

        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if rides.count == 0 {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            noDataLabel.text = "No Scheduled Rides Available".localized()
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
        }else {
            self.tableView.backgroundView = nil
        }
        
        return rides.count
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ScheduledRideCell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ScheduledRideCell
        
        let ride : ScheduledRideItem = rides[indexPath.row]
        
        cell.ridetime?.text = "\(ride.date)"
        cell.pickUpAddress?.text = "\(ride.s_address)"
        cell.dropAddress?.text = "\(ride.d_address)"
        cell.type?.text = "\(ride.taxi_name)"
        
        if !((ride.picture ?? "").isEmpty)
        {
            let url = URL(string: ride.picture.decodeUrl())!
            let placeholderImage = UIImage(named: "taxi")!
            let size = CGSize(width: 100.0, height: 100.0)
            let filter = AspectScaledToFillSizeCircleFilter(size: size)
            cell.carImg?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: filter)
        }else{
            cell.carImg.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }
        
        cell.cancelBtn.tag = indexPath.row        
        cell.cancelBtn.addTarget(self, action: #selector(ScheduledRidesViewController.cancelAction), for: .touchUpInside)


        return cell
    }
    
    func cancelAction(sender: UIButton){
        
        let ride: ScheduledRideItem = rides[sender.tag]
        cancelRide(reqId: ride.request_id)
        
    }
    
    func cancelRide(reqId: String){
        
        API.cancelScheduledRide(reqId: reqId, completionHandler: { json, error in
            
            if let error = error {
                //self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                        if(status){
                            self.view.makeToast(message: "Scheduled Ride Cancelled".localized())
                                    print(json ?? "error in cancelRide json")
                    
                            self.fetchScheduledRides()
                    
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


    
}



extension ScheduledRidesViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
}


