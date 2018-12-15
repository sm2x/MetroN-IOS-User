//
//  NKTornPaymenOptionstViewController.swift
//  Nikola
//
//  Created by Vinitha on 06/12/18.
//  Copyright © 2018 Nikola. All rights reserved.
//

import UIKit

class NKTornPaymenOptionstViewController: UIViewController {
    
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var btnAddingPaymentCard: UIButton!
    

    @IBOutlet weak var btnPaymentTorn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupUI()
    {
      btnAddingPaymentCard.layer.cornerRadius = 10
        btnPaymentTorn.layer.cornerRadius = 10
        btnAddingPaymentCard.layer.masksToBounds = true
        btnPaymentTorn.layer.masksToBounds = true
        
    }
    
    @IBAction func btnPaymrntTornPressed(_ sender: Any) {
        
        self.gototornPaymentOptions()
    }
    func gototornPaymentOptions()
    {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "NKDirectTopUpTornViewController") as! NKDirectTopUpTornViewController
                self.navigationController?.pushViewController(myVC, animated: true)
//        self.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func btnAddingPaymentPressed(_ sender: Any) {
        
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
//       self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
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
