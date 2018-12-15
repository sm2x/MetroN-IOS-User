//
//  DATA.swift
//  Nikola
//
//  Created by Sutharshan on 5/31/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class DATA {
    
    let USER_ID: String = "id";
    let DRIVER_ID: String = "driver_id";
    let EMAIL: String = "email";
    let PASSWORD: String = "password";
    let PICTURE: String = "picture";
    let DEVICE_TOKEN: String = "device_token";
    let TOKEN: String = "token";
    let LOGIN_BY: String = "login_by";
    let SOCIAL_ID: String = "social_id";
    public static let PROPERTY_REG_ID: String = "registration_id";
    public static let PROPERTY_APP_VERSION: String = "appVersion";
    private static let PRE_LOAD: String = "preLoad";
    
    let REQ_TIME: String = "req_time";
    let REQUEST_ID: String = "request_id";
    let NAME: String = "name";
    let ACCEPT_TIME: String = "accept_time";
    let CURRENT_TIME: String = "current_time";
//    let CURRENCY: String = "currency";
    let LANGUAGE: String = "language";
    let REQUEST_TYPE: String = "type";
    let PAYMENT_MODE: String = "payment_mode";
    let TAXI_TYPES_DATA: String = "taxi_types_data";
    let AIRPORTS_LIST_DATA: String = "airports_list_data";
    let TAXI_TYPE_DEFAULT: String = "taxi_type_default";
    let FARE_ESTIMATE: String = "fare_estimate";
    let RIDE_HISTORY_DATA: String = "ride_history_data";
    let RIDE_HISTORY_SELECTED_DATA: String = "ride_history_selected_data";
    
    func clearRequestData(){
        putRequestId(reqId: Const.NO_REQUEST)
        putDriverId(driverId: "")
        putRequestTime(reqTime: 0)
        putAcceptTime(acceptTime: 0)
        //putCurrentTime(currentTime: Int64)
    }
    
    func putUserId(_ userId: Int){
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: USER_ID)
    }
    
    func getUserId()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: USER_ID)
    }

    
    func putRequestId(reqId: Int){
        let defaults = UserDefaults.standard
        defaults.set(reqId, forKey: REQUEST_ID)
    }
    
    func getRequestId()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: REQUEST_ID)
    }
    
    
    func putRequestTime(reqTime: Int64){
        let defaults = UserDefaults.standard
        defaults.set(reqTime, forKey: REQ_TIME)
    }
    
    func putAcceptTime(acceptTime: Int64){
        let defaults = UserDefaults.standard
        defaults.set(acceptTime, forKey: ACCEPT_TIME)
    }
    
    func putCurrentTime(currentTime: Int64){
        let defaults = UserDefaults.standard
        defaults.set(currentTime, forKey: ACCEPT_TIME)
    }
    
    func putDriverId(driverId: String){
        let defaults = UserDefaults.standard
        defaults.set(driverId, forKey: DRIVER_ID)
    }
    
    func getDriverId()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: DRIVER_ID)
    }
    
//    func putCurrency(currency: String) {
//        let defaults = UserDefaults.standard
//        return defaults.set(forKey: Const.CURRENCY)
//
//    }
//
    
    func putTaxiType(serviceType: String){
        let defaults = UserDefaults.standard
        defaults.set(serviceType, forKey: Const.Params.SERVICE_TYPE)
    }
    
    func getTaxiType()->Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: Const.Params.SERVICE_TYPE)
    }
    
    
    func putTaxiTypesData(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: TAXI_TYPES_DATA)
    }
    
    func getTaxiTypesData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: TAXI_TYPES_DATA) != nil {
            return defaults.string(forKey: TAXI_TYPES_DATA)!
        }else {
            return ""
        }
    }
    
    func putAirPortsListData(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: AIRPORTS_LIST_DATA)
    }
    
    func getAirPortsListData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: AIRPORTS_LIST_DATA) != nil {
            return defaults.string(forKey: AIRPORTS_LIST_DATA)!
        }else {
            return ""
        }
    }
    
    func putDefaultTaxiType(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: TAXI_TYPE_DEFAULT)
    }
    
    func getDefaultTaxiType()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: TAXI_TYPE_DEFAULT) != nil {
            return defaults.string(forKey: TAXI_TYPE_DEFAULT)!
        }else {
            return ""
        }
    }
    
    func putToken(data: String){
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: TOKEN)
    }
    
    func getToken()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: TOKEN) != nil {
            return defaults.string(forKey: TOKEN)!
        }else {
            return ""
        }
    }
    
    func putDeviceToken(data: String){
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: DEVICE_TOKEN)
    }
    
    func getDeviceToken()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: DEVICE_TOKEN) != nil {
            return defaults.string(forKey: DEVICE_TOKEN)!
        }else {
            return ""
        }
    }
    
    func putFareEstimateData(data: String){
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: FARE_ESTIMATE)
    }
    
    func getFairEstimateData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: FARE_ESTIMATE) != nil {
            return defaults.string(forKey: FARE_ESTIMATE)!
        }else {
            return ""
        }
    }
    
    func putRideHistoryData(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: RIDE_HISTORY_DATA)
    }
    
    func getRideHistoryData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: RIDE_HISTORY_DATA) != nil {
            return defaults.string(forKey: RIDE_HISTORY_DATA)!
        }else {
            return ""
        }
    }
    
    func putRideHistorySelectedData(request: String){
        let defaults = UserDefaults.standard
        defaults.set(request, forKey: RIDE_HISTORY_SELECTED_DATA)
    }
    
    func getRideHistorySelectedData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: RIDE_HISTORY_DATA) != nil {
            return defaults.string(forKey: RIDE_HISTORY_SELECTED_DATA)!
        }else {
            return ""
        }
    }
    
        
    func getCurrentDriverData()->String{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Const.CURRENT_DRIVER_DATA) != nil {
            return defaults.string(forKey: Const.CURRENT_DRIVER_DATA)!
        }else {
            return ""
        }
    }
    
    
    
}
