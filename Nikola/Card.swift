//
//  Card.swift
//  Nikola
//
//  Created by Sutharshan Ram on 25/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON

class Card {
    
    var cardNumber: String = ""
    var cardTypeUrl: String = ""
    var isDefault: String = ""
    var type: String = ""
    var cardtype: String = ""
    var cardId: String = ""
    var email: String = ""
    
    var jsonObj: JSON!
        
    init(jObj: JSON) {
        cardId = jObj["id"].stringValue
        cardNumber = jObj["last_four"].stringValue
        isDefault = jObj["is_default"].stringValue
        cardtype = jObj["card_type"].stringValue
        type = jObj["type"].stringValue
        email = jObj["email"].stringValue
        jsonObj = jObj
    }

}
