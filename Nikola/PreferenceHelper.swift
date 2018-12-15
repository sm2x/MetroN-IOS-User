//
//  PreferenceHelper.swift
//  Nikola
//
//  Created by Sutharshan on 5/29/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class PreferenceHelper {
    
    static func clearRequestData(){
     
        let defaults = UserDefaults.standard
        defaults.set(Const.NO_REQUEST, forKey: Const.Params.REQUEST_ID)
        
    }
}
