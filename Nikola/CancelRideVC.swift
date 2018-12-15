//
//  CancelRideVC.swift
//  Nikola
//
//  Created by sudharsan s on 24/11/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit


class CancelRideVC: BaseViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var mainUIView: UIView!
    
    @IBOutlet weak var viewheightConstrains: NSLayoutConstraint!
    
    var cancelRideReason = [String]()
    var cancelRideId = [Int]()
    lazy var defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()

        
        print(cancelRideReason)
        print(cancelRideId)
        
        if cancelRideReason.count > 0  {
            
            tableview.delegate = self
            tableview.dataSource = self
            tableview.tableFooterView = UIView()
            tableview.reloadData()
            
        }
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.view.addGestureRecognizer(tap)

    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        //self.view.removeFromSuperview()
        //  print("Hello World")
    }

   
    @IBAction func cancelRideButton(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToDashboard(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController
        self.present(secondViewController!, animated: true, completion: nil)
    }
    
   

}
extension CancelRideVC : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.total
        return self.cancelRideReason.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CancelRideCell = tableView.dequeueReusableCell(withIdentifier: "CancelRideCell", for: indexPath) as! CancelRideCell
        
        
        cell.lblissues.text = self.cancelRideReason[indexPath.row]
        //cell.lblName.text = self.descriptionArray[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        
        
        let rea : String = self.cancelRideReason[indexPath.row]
        
        let id : Int = self.cancelRideId[indexPath.row]
        
        let reas_id : String = String(id)
        
        print(reas_id)
        
         let defaults = UserDefaults.standard
        defaults.set(reas_id, forKey: Const.Params.REASON_ID)
        self.showLoader( str: "Canceling Ride")
        
        
            API.cancelRide{ json, error in

                    if let error = error {
                        self.hideLoader()
                         self.showAlert(with :error.localizedDescription)
                        debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
                    }else {
                        if let json = json {
                            let status = json[Const.STATUS_CODE].boolValue
                            let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                                if(status){
                                   
                                    self.hideLoader(); self.view.removeFromSuperview()
                                    print(json)
                                    defaults.removeObject(forKey: "requestType")
                                    
                                    DATA().clearRequestData()
                                    self.goToDashboard()
                                    print(json)
                                }else{
                                    self.hideLoader()
                                     self.view.removeFromSuperview()

                                    print(json )
                                    print(statusMessage)
                                    print(json )
                                    
                                    if let error : String = json[Const.ERROR].rawString() {
                                    
                                    self.showAlert(with: error)
                                    }
                                
                                }

                        }else {
                            self.hideLoader()
                            debugPrint("Invalid Json :(")
                        }
                    }

                }
        
        
        
        
        
        
    }
    
    
    
}
