//
//  ScheduledRideItem.swift
//  Nikola
//
//  Created by Sutharshan Ram on 15/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScheduledRideItem {
    
    var request_id: String = ""
    var date: String = "", picture: String = "",  taxi_name: String = "", s_address: String = "", d_address: String = "";
    
    init(jsonObj: JSON) {
        request_id = jsonObj["request_id"].stringValue
        date = jsonObj["requested_time"].stringValue
        picture = jsonObj["type_picture"].stringValue
        taxi_name = jsonObj["service_type_name"].stringValue
        s_address = jsonObj["s_address"].stringValue
        d_address = jsonObj["d_address"].stringValue
    }

}
