//
//  TaxiType.swift
//  Nikola
//
//  Created by Sutharshan on 5/25/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
class TaxiType {
    
    var id: String!
    var min_fare: String!
    var picture: String!
    var type: String!
    var price_min: String!
    var price_distance: String!
    var seats: String!
    var img: UIImage!
    var jsonObj: JSON!
    var estimated_fare: Double
    
    init(taxiObj: JSON) {        
        id = taxiObj["id"].stringValue
        min_fare = taxiObj["min_fare"].stringValue
        picture = taxiObj["picture"].stringValue
        type = taxiObj["name"].stringValue
        price_min = taxiObj["price_per_min"].stringValue
        price_distance = taxiObj["price_per_unit_distance"].stringValue
        seats = taxiObj["number_seat"].stringValue
        estimated_fare = taxiObj["estimated_fare"].doubleValue
        jsonObj = taxiObj
       // img = UIImage(data: try! Data(contentsOf: URL(string:picture)!))!
    }

}
