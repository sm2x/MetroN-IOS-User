//
//  RideHistoryViewController.swift
//  Nikola
//
//  Created by Sutharshan Ram on 15/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Toucan

class RideHistoryViewController : UITableViewController{
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    
    var hud : MBProgressHUD = MBProgressHUD()
    
   
    
    let reuseIdentifier: String = "RideHistoryCell"
    var rides:[RideHistoryItem] = []
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }

     


       

        
//        F6F6F6
        
         self.tableView.separatorColor = UIColor.clear
            
        self.tableView.tableFooterView = UIView()
        
        fetchRideHistory()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        
         navigationController?.navigationBar.barTintColor = UIColor(hex: "F6F6F6")
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
//        UIApplication.shared.isStatusBarHidden = true
        
    }

    
    
    func backButton(sender: Any) {
        
        
        revealViewController().revealToggle(sender)
        
        
        
    }

    
    
    func fetchRideHistory(){
        
        
       self.showLoader(str: "Loading Histroy...")
        
        API.fetchRideHistory{ json, error in
            
            if let error = error {
                self.hideLoader()
                self.showAlert(with :error.localizedDescription)
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        DATA().putRideHistoryData(request: json["requests"].rawString()!)
                            let typesArray = json["requests"].arrayValue
                            self.rides.removeAll()
                        for type: JSON in typesArray {
                            self.rides.append(RideHistoryItem.init(jsonObj: type))
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
            noDataLabel.text = "No Rides History Available".localized()
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
        
        let cell:RideHistoryCell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RideHistoryCell
        
        
//        cell.backgroundColor = UIColor.gray
        
        
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.uiview.layer.cornerRadius = 10
        
//        // border
//        cell.uiview.layer.borderWidth = 1.0
//        cell.uiview.layer.borderColor = UIColor.black.cgColor
        
        // shadow
        cell.uiview.layer.shadowColor = UIColor.black.cgColor
        cell.uiview.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.uiview.layer.shadowOpacity = 0.7
        cell.uiview.layer.shadowRadius = 4.0
        
        
        
        let ride : RideHistoryItem = rides[indexPath.row]
        
        cell.ridetime?.text = "\(ride.date)"
        cell.pickUpAddress?.text = "\(ride.s_address)"
        cell.dropAddress?.text = "\(ride.d_address)"
        cell.drivername?.text = "\(ride.provider_name)"
        cell.type?.text = "\(ride.taxi_name)"
        cell.amount?.text = "$ \(ride.total)"
        
        if !((ride.picture ?? "").isEmpty)
        {
            let url = URL(string: ride.picture.decodeUrl())!
            let placeholderImage = UIImage(named: "taxi")!
            let size = CGSize(width: 100.0, height: 100.0)
            let filter = AspectScaledToFillSizeCircleFilter(size: size)
            cell.driverImage?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: filter)
        }else{
            cell.driverImage.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }

        return cell
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 145.0;//Choose your custom row height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
//        let row = indexPath.row
//        print(countryArray[row])
//        selectedIndex = indexPath
//        self.setDefaultCard(card: cards[row])
//        tableView.reloadData()
        
        let ride : RideHistoryItem = rides[indexPath.row]
        DATA().putRideHistorySelectedData(request: ride.jsnObj.rawString()!)
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "RideDetailsViewController") as! RideDetailsViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)

    }
    
    
}


extension RideHistoryViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }

    
}

