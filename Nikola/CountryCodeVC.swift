//
//  CountryCodeVC.swift
//  Nikola
//
//  Created by Shantha Kumar on 10/7/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit

class CountryCodeVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var serachText: SkyFloatingLabelTextField!
    var countryArray :[Any]! = []

    var delegate : updateCountryCodeProtocal!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        serachText.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
//        UINavigationBar.appearance().isTranslucent = false
        
        tableView.tableFooterView = UIView()
        readJson()
        
         UIApplication.shared.isStatusBarHidden = true
        
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(textField.text!)
        
        if (textField.text?.isEmpty)! {
            
            print("empty")
            
        
        }
        
        
        
        
        if let txtCount = textField.text?.characters.count {
            
 
            
            if txtCount > 2 {
                

                
                let filterArray = countryArray.filter({(($0 as! Dictionary<String,String>)["name"] as! String).lowercased().range(of: textField.text!) != nil})
//                print("Filter:\(filterArray)")
                
                if  filterArray.count > 0 {
                    
                    countryArray.removeAll()
                    
                    countryArray = filterArray
 
                    print("Filter:\(filterArray)")
                    
                    self.tableView.reloadData()
                    
                }
                
  
                }
            else {
                
                 countryArray.removeAll()
                readJson()
                print("show full")
            }
                
                

        }
        
        
        return true
    }
    
    
    
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "countryCodes", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as?  [[String:Any]] {
                    // json is an array
                    print(object)
                    
                    
                    self.countryArray = object
                    
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
     
                    self.tableView.reloadData()
                    
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonActionMethod(_ sender: Any) {
        
         self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CountryCodeVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.total
        return self.countryArray.count
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.selectionStyle = UITableViewCellSelectionStyle.none
//
//    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CountryCodeCell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeCell", for: indexPath) as! CountryCodeCell
        
        
        let dic : [String: String] = self.countryArray[indexPath.row] as! [String : String]
        
        
        cell.lblCountryName.text = dic["name"]
        cell.lblCountryCode.text = dic["dial_code"]
        cell.mapImg.image = UIImage(named: dic["code"]!)
        
        
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        
        let dic : [String: String] = self.countryArray[indexPath.row] as! [String : String]
        
        delegate.updateCountryCodeMethod(with: dic)
        self.dismiss(animated: true, completion: nil)
        print(dic)
        
    }
    
    
    
    
    
}

