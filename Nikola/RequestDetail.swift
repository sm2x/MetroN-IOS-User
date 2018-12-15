//
//  RequestDetail.swift
//  Nikola
//
//  Created by Sutharshan on 5/27/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON

class RequestDetail {
    var requestId: Int = 0;
    var tripStatus: Int = 0;
    var driverStatus: Int = 0;
    var driver_name : String = "", driver_picture : String = "", driver_mobile : String = "", driver_rating : String = "",driver_id : String = "",vehical_img : String = "";
    var s_lat: String = "", s_lon: String = "", d_lat: String = "", d_lon: String = "", s_address: String = "", d_address: String = "";
    var driver_latitude: Double = 0.0,driver_longitude: Double = 0.0;
    var request_type: String = "",no_tolls: String = "";
    var trip_time: String = "",trip_distance: String = "",trip_total_price: String = "",trip_base_price: String = "",payment_mode: String = "",trip_distance_unit: String = "";
    
    var car_image: String = "", model: String = "", plate_no: String = "", color: String = "";
    
    
    init() {
    
    }
    
    
    func initDriver(rqObj: JSON) {
        
        if rqObj["provider_status"].exists() {
        tripStatus = rqObj["provider_status"].intValue
        }
        
        if rqObj["provider_name"].exists() && rqObj["provider_name"].stringValue != "null"{
            driver_name = rqObj["provider_name"].stringValue
        }
        
        if rqObj["status"].exists() {
            driverStatus = rqObj["status"].intValue
        }
        
        if rqObj["provider_mobile"].exists() && rqObj["provider_mobile"].stringValue != "null"{
            driver_mobile = rqObj["provider_mobile"].stringValue
        }
        
        if rqObj["provider_picture"].exists() && rqObj["provider_picture"].stringValue != "null"{
            driver_picture = rqObj["provider_picture"].stringValue
        }
        
        if rqObj["request_status_type"].exists() {
            request_type = rqObj["request_status_type"].stringValue
        }
        
        no_tolls = rqObj["number_tolls"].stringValue
        driver_id = rqObj["provider_id"].stringValue
        driver_rating = rqObj["rating"].stringValue
        s_address = rqObj["s_address"].stringValue
        d_address = rqObj["d_address"].stringValue
        
        s_lat = rqObj["s_latitude"].stringValue
        s_lon = rqObj["s_longitude"].stringValue
        d_lat = rqObj["d_latitude"].stringValue
        d_lon = rqObj["d_longitude"].stringValue
        
        car_image = rqObj["car_image"].stringValue
        model = rqObj["model"].stringValue
        plate_no = rqObj["plate_no"].stringValue
        color = rqObj["color"].stringValue
        
        if rqObj["driver_latitude"].exists() && rqObj["driver_latitude"].stringValue != "null" {
            driver_latitude = rqObj["driver_latitude"].doubleValue
        }
        else{
            driver_latitude = 0.0
        }
        if rqObj["driver_longitude"].exists() && rqObj["driver_longitude"].stringValue != "null" {
            driver_longitude = rqObj["driver_longitude"].doubleValue
        }
        else{
            driver_longitude = 0.0
        }
        vehical_img = rqObj["type_picture"].stringValue
    }
    
    func initInvoice(rqObj: JSON) {
       
        if let tripTime = Double(rqObj["total_time"].stringValue) {
            
            trip_time = String(format: "%.2f",tripTime)
        } else {
             trip_time = rqObj["total_time"].stringValue
        }
        payment_mode = rqObj["payment_mode"].stringValue
   
        if let tripBasePrice = Double(rqObj["base_price"].stringValue) {
            
            trip_base_price = String(format: "%.2f",tripBasePrice)
        } else {
            trip_base_price = rqObj["base_price"].stringValue
        }
        if let tripTotalPrice = Double(rqObj["total"].stringValue) {
            
            trip_total_price = String(format: "%.2f",tripTotalPrice)
        } else {
                trip_total_price = rqObj["total"].stringValue
        }
        if let tripDistance = Double(rqObj["distance_travel"].stringValue) {
            
            trip_distance = String(format: "%.2f",tripDistance)
        } else {
            trip_distance = rqObj["distance_travel"].stringValue
        }
   
        if let tripDistanceUnit = Double(rqObj["distance_unit"].stringValue) {
            
            trip_distance_unit = String(format: "%.2f",tripDistanceUnit)
        } else {
            trip_distance_unit = rqObj["distance_unit"].stringValue
        }
        
    }
    
}
