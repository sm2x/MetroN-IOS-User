//
//  NearbyDriver.swift
//  Nikola
//
//  Created by Sutharshan on 6/2/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

class NearByDrivers {
    var id: String = ""
    var latlon: CLLocationCoordinate2D
    var driver_name: String = ""
    var driver_distance: String = ""
    var driver_rate: Int = 0
 
    
    init(jsonObj: JSON) {
        
        id = jsonObj["id"].stringValue
        latlon = CLLocationCoordinate2D(latitude: Double(jsonObj["latitude"].stringValue)!, longitude: Double(jsonObj["longitude"].stringValue)!)
        driver_name = jsonObj["first_name"].stringValue
        driver_distance = jsonObj["distance"].stringValue
        driver_rate = Int(Double(jsonObj["rating"].stringValue)!)
        
    }
}
