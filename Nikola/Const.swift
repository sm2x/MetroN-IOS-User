//
//  Const.swift
//  Alicia
//
//  Created by Sutharshan on 5/3/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class Const {
    
    //Paypal values
    //static let CONFIG_ENVIRONMENT = PayPalConfiguration.ENVIRONMENT_SANDBOX
    static let CONFIG_CLIENT_ID = "Abi3t-ED76WNwMH8k07hISLmKO-Y8SZZ0KMNGq28jR-76HK0Gg1cuhDuxweJuUkVFZ-Y495Qj8XzyPNS"
    
    // Stripe token
    static let  STRIPE_TOKEN = "pk_test_vt56v3vGaWN3D4Ov2KoYxYoV" // virtusa account
    
      static let googlePlaceAPIkey = "AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik"
 // static let googlePlaceAPIkey = "AIzaSyCVmS_V5hGTX2Yj0T0aFcdElDyEliaT6ys"
    
    //static let offersUrl = "http://104.236.68.155/offers"
    
    static let BALANCE = "balance"
    static let _ID = "id"
    static let USER_ID = "user_id"
    static let ORDER_ID = "order_id"
    static let OTHER_USER_NAME = "other_user_name"
    static let OTHER_MOBILE_NUMBER = "other_mobile_no"
    static let TRANSACTION_TYPE = "t_type"
    static let OTP_CODE = "otp_code"
    static let FIRST_NAME = "first_name"
    static let LAST_NAME = "last_name"
    static let STATUS_CODE = "success"
    static let STATUS = "status"
    static let STATUS_MESSAGE = "text"
    static let MESSAGE = "message"
    static let DATA = "data"
    static let NEW_ERROR = "error_messages"
    static let ERROR_MSG = "error_message"
    static let ERROR = "error"
    static let ERROR_CODE = "error_code"
    static let INVOICE = "invoice"
    static let RESPONSE = "data"
    static let EMAIL = "email"
    static let PASSWORD = "password"
    static let NEW_PASSWORD = "new_password"
    
    static let TOKEN = "access_token"
    static let AMOUNT = "amount"
    static let AUTHORIZATION = "Authorization"
    static let PHONE = "mobile_no"
    //static let PHONE = "mobile_no"
    static let PHONE_RECEIVER = "receiver_mobile"
    static let REMARKS = "remarks"
    static let TIMESTAMP = "timestamp"
    static let GATEWAY = "gateway"
    static let PAYMENT_ID = "payment_id"
    static let COUNTRY_CODE = "country_code"
    static let MOBILE_VERIFIED = "is_mobile_verified"
    static let AUTH_TOKEN = "auth_token"
      static let IS_RIDE_CANCELLED = "is_cancelled"
    static let nikola : Bool = true
    static let ridey : Bool = false
    static let Torn_Wallet_Address = "torn_wallet_address"
    static let Torn_Current_value = "torn_current_value"
    
    public class Url {
        //        static let HOST_URL = "http://13.59.95.239/"
        
        //    static let HOST_URL = "http://13.59.95.239/"
//    static let HOST_URL = "http://staging.nikola.world/"
        static let HOST_URL = "http://46.101.106.16/"
     //  static let HOST_URL = "http://178.128.33.48/"
         static let FORCE_UPDATE_URL = "http://nikola.world/get_version"
        
//         static let HOST_URL = "http://stagging.nikola.world/"
        
        static let WALLET_HOST_URL = "http://walletbay.net/apps"
        
        //    static let HOST_URL = "http://goridey.com/"// live server
        static let SOCKET_URL : String = "http://178.128.33.48:3000"
        static let BASE_URL = HOST_URL + "userApi/"
        static let WALLET_BASE_URL = WALLET_HOST_URL + "/api/business/"
        static let WALLET_TYPES = WALLET_BASE_URL + "payment-gateways"
        static let WALLET_BALANCE = WALLET_HOST_URL + "/api/businesses/users/"
        static let WALLET_CRIDT = WALLET_BALANCE + "/balance/credit"
        static let LOGIN :String = BASE_URL + "login"
        static let REGISTER:String = BASE_URL + "register"
        static let UPDATE_PROFILE:String = BASE_URL + "updateProfile"
        static let FORGOT_PASSWORD:String = BASE_URL + "forgotpassword"
        static let TAXI_TYPE:String = BASE_URL + "serviceList"
        static let PROMOCODE:String = BASE_URL + "validate_promo"
        static let GET_PROVIDERS:String = BASE_URL + "guestProviderList"
        static let FARE_CALCULATION:String = BASE_URL + "fare_calculator"
        static let REQUEST_TAXI:String = BASE_URL + "sendRequest"
        static let CANCEL_CREATE_REQUEST:String = BASE_URL + "waitingRequestCancel"
        static let CHECKREQUEST_STATUS:String = BASE_URL + "requestStatusCheck"
        static let PAYNOW:String = BASE_URL + "payment"
        static let RATE_PROVIDER:String = BASE_URL + "rateProvider"
        static let CANCEL_RIDE:String = BASE_URL + "cancelRequest"
        static let CANCEL_RIDE_REASON:String = BASE_URL + "cancellationReasons"
        static let GET_HISTORY:String = BASE_URL + "history"
        static let GET_PAYMENT_MODES:String = BASE_URL + "getPaymentModes?"
        static let PAYMENT_MODE_UPDATE:String = BASE_URL + "PaymentModeUpdate"
        static let GET_BRAIN_TREE_TOKEN_URL:String = BASE_URL + "getbraintreetoken"
        static let CREATE_ADD_CARD_URL:String = BASE_URL + "addcard"
        static let GET_ADDED_CARDS_URL:String = BASE_URL + "getcards?"
        static let REMOVE_CARD:String = BASE_URL + "deletecard"
        static let CREATE_SELECT_CARD_URL:String = BASE_URL + "selectcard"
        static let REQUEST_LATER:String = BASE_URL + "laterRequest"
        static let GET_LATER:String = BASE_URL + "upcomingRequest"
        static let CANCEL_LATER_RIDE:String = BASE_URL + "cancel_later_request?"
        static let HOURLY_PACKAGE_FARE:String = BASE_URL + "hourly_package_fare"
        static let USER_MESSAGE_NOTIFY:String = BASE_URL + "message_notification?"
        static let AIRPORT_LST:String = BASE_URL + "airport_details?"
        static let LOCATION_LST:String = BASE_URL + "location_details?"
        static let AIRPORT_PACKAGE_FARE:String = BASE_URL + "airport_package_fare"
        static let GET_OTP: String = BASE_URL + "sendOtp?"
        
        static let GET_PAYMENT_MODE: String = BASE_URL + "getPaymentModes?"
        static let LOG_OUT: String = BASE_URL + "logout"
        static let DELETE_USER: String = BASE_URL + "delete_account"
        static let APPLY_REFERRAL: String = BASE_URL + "applyReferral"
        
        static let GET_MESSAGE_API = BASE_URL + "message/get";
        static let GET_TORN_WALLET_BALANCE = BASE_URL + "tron/wallet/balance"
        static let TORN_WALLET_BALANCE_ADD = BASE_URL + "tron/wallet/balance/add"
        

    }
    
    // Placesurls
    static let PLACES_API_BASE = "https://maps.googleapis.com/maps/api/place";
    static let TYPE_AUTOCOMPLETE = "/autocomplete";
    static let TYPE_NEAR_BY = "/nearbysearch";
    static let OUT_JSON = "/json";
    
    // direction API
    static let DIRECTION_API_BASE = "https://maps.googleapis.com/maps/api/directions/json?";
    
    static let googleGeocoderAPIURL = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    static let ORIGIN = "origin";
    static let DESTINATION = "destination";
    static let EXTANCTION = "sensor=false&mode=driving&alternatives=true&key=AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik";
    
    static let googleAutoCompleteAPIURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    
    static let Key = "key"
    static let address = "address"
    
    
    static let REQUEST_ACCEPT = "REQUEST_ACCEPT";
    static let REQUEST_CANCEL = "REQUEST_CANCEL";
    static let NO_REQUEST = -1;
    static let DRIVER_STATUS = "driverstatus";
    static let DELAY = 0;
    static let TIME_SCHEDULE = 5 * 1000;
    static let DELAY_OFFLINE = 15 * 60 * 1000;
    static let TIME_SCHEDULE_OFFLINE = 15 * 60 * 1000;
    
   // static let PLACES_AUTOCOMPLETE_API_KEY = "AIzaSyDRf_sgXH_Vk_2QkIO_E9my-UUPZlZdwtg";
     static let PLACES_AUTOCOMPLETE_API_KEY = "AIzaSyC5fNTsNIv5Ji8AuOx-rJwouEAreUVC3s0";
    // AIzaSyCSYiLzX_yhDwBznjxO2b5tvnKqOIFOkMk // ios api key
    
    //Fragments
    static let HOME_MAP_FRAGMENT = "home_map_fragment";
    static let TRAVEL_MAP_FRAGMENT = "travel_map_fragment";
    static let RATING_FRAGMENT = "rating_fragment";
    static let REGISTER_FRAGMENT = "register_fragment";
    static let FORGOT_PASSWORD_FRAGMENT = "forgot_fragment";
    static let SEARCH_FRAGMENT = "search_fragment";
    static let REQUEST_FRAGMENT = "request_fragment";
    static let HOURLY_FRAGMENT = "hourly_fragment";
    static let AIRPORT_FRAGMENT = "airport_fragment";
    
    //  Trip request status
    static let IS_CREATED = 0;
    static let IS_ACCEPTED = 1;
    static let IS_DRIVER_DEPARTED = 2;
    static let IS_DRIVER_ARRIVED = 3;
    static let IS_DRIVER_TRIP_STARTED = 4;
    static let IS_DRIVER_TRIP_ENDED = 5;
    static let IS_DRIVER_RATED = 6;
    
    static let DEVICE_TYPE = "android";
    static let DEVICE_TYPE_ANDROID = "android";
    static let DEVICE_TYPE_IOS = "ios";
    static let SOCIAL_FACEBOOK = "facebook";
    static let SOCIAL_GOOGLE = "google";
    static let MANUAL = "manual";
    static let SOCIAL = "social";
    static let REQUEST_DETAIL = "requestDetails";
    
    
    static let GOOGLE_MATRIX_URL = "https://maps.googleapis.com/maps/api/distancematrix/json?";
    
    public class Params {
        static let ID = "id";
        static let TOKEN = "token";
        static let REFERRAL_BONUS = "referee_bonus";
        static let REFERRAL_CODE_LOGIN = "referral_code";
        static let KEY = "key";
        static let PROMO_CODE = "promo_code"
        static let SOCIAL_ID = "social_unique_id";
        static let URL = "url";
        static let PICTURE = "picture";
        static let EMAIL = "email";
        static let PASSWORD = "password";
        static let REFERRAL_CODE = "referral_code";
        static let REPASSWORD = "confirm_password";
        static let FIRSTNAME = "first_name";
        
        static let LAST_NAME = "last_name";
        static let PHONE = "mobile";
        static let OTP = "otp";
        static let SSN = "ssn";
        static let DEVICE_TOKEN = "device_token";
        static let ICON = "icon";
        static let DEVICE_TYPE = "device_type";
        static let LOGIN_BY = "login_by";
        static let CURRENCEY = "currency_code";
        static let LANGUAGE = "language";
        static let REQUEST_ID = "request_id";
        
        static let REASON_ID = "reason_id";
        static let DRIVER_ID = "provider_id";
        static let GENDER = "gender";
        static let COUNTRY = "country";
        static let TIMEZONE = "timezone";
        static let LATITUDE = "latitude";
        static let LONGITUDE = "longitude";
        static let TAXI_TYPE = "service_id";
        static let SERVICE_TYPE = "service_type";
        static let ORIGINS = "origins";
        static let DESTINATION = "destinations";
        static let SENSOR = "sensor";
        static let MODE = "mode";
        static let DISTANCE = "distance";
        static let TIME = "time";
        static let S_LATITUDE = "s_latitude";
        static let S_LONGITUDE = "s_longitude";
        static let D_LATITUDE = "d_latitude";
        static let D_LONGITUDE = "d_longitude";
        static let S_ADDRESS = "s_address";
        static let D_ADDRESS = "d_address";
        static let PAYMENT_MODE = "payment_mode";
        static let PAYMENT_MODE_STATUS = "payment_mode_status"
        static let WALLET_BAY_KEY = "wallet_bay_key"
        static let IS_PAID = "is_paid";
        static let COMMENT = "comment";
        static let RATING = "rating";
        static let PAYMENT_METHOD_NONCE = "payment_method_nonce";
        static let LAST_FOUR = "last_four";
        static let CARD_ID = "card_id";
        static let NO_HOUR = "number_hours";
        static let REQ_STATUS_TYPE = "request_status_type";
        static let HOURLY_PACKAGE_ID = "hourly_package_id";
        static let AIRPORT_PACKAGE_ID = "airport_price_id";
        static let USDAMOUNT = "usd_amount";
        static let ESTIMATED_FARE = "estimated_fare";
    }
    
    static let PI_LATITUDE = "pic_latitude";
    static let PI_LONGITUDE = "pic_longitude";
    static let DR_LATITUDE = "drp_latitude";
    static let DR_LONGITUDE = "drp_longitude";
    
    static let PI_ADDRESS = "pi_address";
    static let DR_ADDRESS = "drp_address";
    
    static let CURRENT_DRIVER_DATA = "current_driver_data";
    static let CURRENT_INVOICE_DATA = "current_invoice_data";
    
    static let CURRENT_ADDRESS = "current_address";
    static let CURRENT_LATITUDE = "current_latitude";
    static let CURRENT_LONGITUDE = "current_longitude";
    
    
    
    static let TAXI_LONG_PRESS = "taxi_long_press";
    
    static let CURRENCEY = "currency"
    
    static let CANCELLATION_FINE = "cancellation_fine"
    
    static let Publish_key:String = "pub-c-e19fa9a9-2cc6-4cba-8a75-6b5c26208f5c";
    static let Subscribe_key:String = "sub-c-e268740e-4ec3-11e7-99ed-0619f8945a4f";
    static let CHANNEL_ID:String = "Location";
    
    static let LATER_MINUTES_TO_ADD: Int = 30
    
    
    static let LOCATION_CHOICE = "location_choice";
}
