//
//  AirPort.swift
//  Nikola
//
//  Created by Sutharshan Ram on 12/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON

class LocationItem {
    
    var id: String!
    var address: String!
    var jsonObj: JSON!
    
    init(jObj: JSON) {
        id = jObj["id"].stringValue
        address = jObj["name"].stringValue
        jsonObj = jObj
    }
}
