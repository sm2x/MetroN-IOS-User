import Foundation
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation


class API{
    
    static let url = "http://104.236.68.155/api/"
    
    //static let url = "http://45.55.3.158:3002"
    // static let url = "http://192.168.1.14:3002"
    static var current_user: User!
    
    //   static let manager = Alamofire.SessionManager.default
    //    manager.session.configuration.timeoutIntervalForRequest = 120
    //    static let shared = API()
    //    var manager: SessionManager {
    //        let manager = Alamofire.SessionManager.default
    //        manager.session.configuration.timeoutIntervalForRequest = 10
    //        return manager
    //    }
    
    class func getURL(url: String, query: [String:String] = [:]) -> String{
        
        let query_json = JSON(query)
        let query_string = API.prepareQueryString(json: query_json)
        
        return API.url+url+query_string
        
    }
    
    class func googlePlaceAPICall(with apiPath: String, completionHandler: @escaping ([String : AnyObject]?, NSError?) -> ()) {
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        
        manager.request(apiPath, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch (response.result) {
            case .success:
                if let json = response.result.value {
                    completionHandler(json as? [String : AnyObject],nil)
                }
                break
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                }
                completionHandler(nil,error as NSError)
                break
            }
        }
    }
    class func deleteUser(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!]
        
        print(parameters)
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(Const.Url.DELETE_USER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func getMessageChatApi(request_id: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.REQUEST_ID: request_id,
                                           Const.Params.DEVICE_TYPE: "ios",
                                           Const.Params.ID : id!,
                                           Const.Params.TOKEN:sessionToken!
            
        ]
        
        //confirm this
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        Alamofire.request( Const.Url.GET_MESSAGE_API, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    

    class func applyReferralCode(referalCode : String,completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let parameters:[String:String] = [ Const.Params.REFERRAL_CODE: referalCode]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(Const.Url.APPLY_REFERRAL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil, error)
                
            }
        }
    }
    class func userLogout(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!]
        
        print(parameters)
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(Const.Url.LOG_OUT, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil, error)
                
            }
        }
    }
    class func getServerVersionNumber(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.FORCE_UPDATE_URL, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    

    class func walletPaymentgateType(completionHandler: @escaping ([String : AnyObject]?, NSError?) -> ()) {
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        //        let id : String = defaults.string(forKey: Const.Params.ID)!
        let wallet_bay_key : String = defaults.string(forKey: Const.Params.WALLET_BAY_KEY)!
        
        
        let headers = [
            "Authorization": wallet_bay_key
        ]
        
        
        manager.request(Const.Url.WALLET_TYPES, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //            debugPrint(response)
            
            switch (response.result) {
            case .success:
                //do json stuff
                
                if let json = response.result.value {
                    
                    completionHandler(json as? [String : AnyObject],nil)
                    
                }
                
                break
            case .failure(let error):
                
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil,error as NSError)
                
                print("\n\nAuth request failed with error:\n \(error)")
                break
            }
            
            
        }
        
    }
    
    
    
    
    
    class func walletBalance(completionHandler: @escaping ([String : AnyObject]?, NSError?) -> ()) {
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id : String = defaults.string(forKey: Const.Params.ID)!
        let fristName : String = defaults.string(forKey: Const.Params.FIRSTNAME)!
        let lastName : String = defaults.string(forKey: Const.Params.LAST_NAME)!
        let phoneNo : String = defaults.string(forKey: Const.Params.PHONE)!
        let email : String = defaults.string(forKey: Const.Params.EMAIL)!
        
        let wallet_bay_key : String = defaults.string(forKey: Const.Params.WALLET_BAY_KEY) ?? ""
        
        
        let headers = [
            "Authorization": wallet_bay_key
        ]
        
        
        
        let url : String = Const.Url.WALLET_BALANCE + "\(id)" + "/balance?" + "name=\(fristName)\(lastName)" + "&full_mobile_no=\(phoneNo)" + "&email=\(email)"

        print(url)
       
        
        manager.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //            debugPrint(response)
            
            
            
            switch (response.result) {
            case .success:
                //do json stuff
                
                if let json = response.result.value {
                    //                                            print("JSON: \(json)")
                    
                    completionHandler(json as? [String : AnyObject],nil)
                    
                    
                }
                
                break
            case .failure(let error):
                
                
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil,error as NSError)
                
                print("\n\nAuth request failed with error:\n \(error)")
                break
            }
            
            
        }
        
        
        
        
    }
    
    
    class func TornWalletBalance(completionHandler: @escaping ([String : AnyObject]?, NSError?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id : String = defaults.string(forKey: Const.Params.ID)!
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id, Const.Params.TOKEN: sessionToken!, "type": "ios" ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
         let url : String = Const.Url.GET_TORN_WALLET_BALANCE
        print(url)
        
        manager.request( url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                if let json = response.result.value {
                 
                    completionHandler(json as? [String : AnyObject],nil)
               
                }
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                 completionHandler(nil,error as NSError)
                
            }
        }
    }
    
    class func TornWalletAddBalance(Amount:String,completionHandler: @escaping ([String : AnyObject]?, NSError?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id : String = defaults.string(forKey: Const.Params.ID)!
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id, Const.Params.TOKEN: sessionToken!, "type": "ios",Const.Params.USDAMOUNT:Amount]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let url : String = Const.Url.TORN_WALLET_BALANCE_ADD
        print(url)
        
        manager.request( url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                if let json = response.result.value {
                    
                    completionHandler(json as? [String : AnyObject],nil)
                    
                }
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil,error as NSError)
                
            }
        }
    }
    
    
    class func walletPaymentCredit(with paymenType : String,paymentId : String,amount : String ,completionHandler: @escaping ([String : AnyObject]?, NSError?) -> ()) {
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id : String = defaults.string(forKey: Const.Params.ID)!
        let wallet_bay_key : String = defaults.string(forKey: Const.Params.WALLET_BAY_KEY)!
        
        
        let headers = [
            "Authorization": wallet_bay_key
        ]
        
        let parameters:[String:String] = [ Const.GATEWAY: paymenType, Const.PAYMENT_ID: paymentId, Const.AMOUNT: amount ]
        
        let url : String = Const.Url.WALLET_BALANCE + "\(id)" + "/balance/credit"
        
        print(url)
        
        manager.request(url, method: .post,parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //            debugPrint(response)
            
            
            
            switch (response.result) {
            case .success:
                //do json stuff
                
                if let json = response.result.value {
                    //                                            print("JSON: \(json)")
                    
                    completionHandler(json as? [String : AnyObject],nil)
                    
                    
                }
                
                break
            case .failure(let error):
                
                
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil,error as NSError)
                
                print("\n\nAuth request failed with error:\n \(error)")
                break
            }
            
            
        }
        
        
        
        
    }
    
    
    class func signUpFaceBook(firstname: String, lastName: String, email: String, mobile: String, countryCode: String, currency: String, timezone: String, password: String, gender: String,socialId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let deviceToken : String!
        
        if let devToken = UserDefaults.standard.string(forKey: "deviceToken") {
            
            deviceToken = DATA().getDeviceToken()
        }
        else {
            
            deviceToken = "asjdl29834jrljp9123j4r20090"
            
            print("no token")
            
        }
        
        
        let parameters:[String:String] = [Const.Params.FIRSTNAME: firstname, Const.Params.LAST_NAME: lastName, Const.Params.EMAIL: email, Const.Params.PHONE: mobile, Const.COUNTRY_CODE:countryCode, Const.Params.TIMEZONE: timezone, Const.PASSWORD: password, Const.Params.GENDER:gender, Const.Params.CURRENCEY: currency, Const.Params.DEVICE_TYPE: "ios", Const.Params.LOGIN_BY: Const.SOCIAL_FACEBOOK, Const.Params.PICTURE:"",Const.Params.DEVICE_TOKEN: deviceToken, Const.Params.SOCIAL_ID: socialId]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        
        manager.request( Const.Url.REGISTER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    class func signUpGoogle(firstname: String, lastName: String, email: String, mobile: String, countryCode: String, currency: String, timezone: String, password: String, gender: String,socialId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        //        let deviceToken = DATA().getDeviceToken()
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let deviceToken : String!
        
        if let devToken = UserDefaults.standard.string(forKey: "deviceToken") {
            
            deviceToken = DATA().getDeviceToken()
        }
        else {
            
            deviceToken = "asjdl29834jrljp9123j4r20090"
            
            print("no token")
            
        }
        
        
        let parameters:[String:String] = [Const.Params.FIRSTNAME: firstname, Const.Params.LAST_NAME: lastName, Const.Params.EMAIL: email, Const.Params.PHONE: mobile, Const.COUNTRY_CODE:countryCode, Const.Params.TIMEZONE: timezone, Const.PASSWORD: password, Const.Params.GENDER:gender, Const.Params.CURRENCEY: currency, Const.Params.DEVICE_TYPE: "ios", Const.Params.LOGIN_BY: Const.SOCIAL_GOOGLE, Const.Params.PICTURE:"",Const.Params.DEVICE_TOKEN: deviceToken, Const.Params.SOCIAL_ID: socialId]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        
        manager.request( Const.Url.REGISTER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func signInWithGoogle(socialId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        //        let pushToken = DATA().getDeviceToken()
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let deviceToken : String!
        
        if let devToken = UserDefaults.standard.string(forKey: "deviceToken") {
            
            deviceToken = DATA().getDeviceToken()
        }
        else {
            
            deviceToken = "asjdl29834jrljp9123j4r20090"
            
            print("no token")
            
        }
        
        
        let parameters:[String:String] = [Const.Params.SOCIAL_ID: socialId,Const.Params.DEVICE_TOKEN: deviceToken, Const.Params.LOGIN_BY: Const.SOCIAL_GOOGLE, Const.Params.DEVICE_TYPE: Const.DEVICE_TYPE_IOS ]
        
        manager.request( Const.Url.LOGIN, method: .post, parameters: parameters, headers: API.getHeaders()).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    class func prepareQueryString(json: JSON) -> String{
        
        var query_string: String = "?"
        
        for (key,value):(String, JSON) in json {
            
            query_string = query_string + "&\(key)=\(value)"
        }
        
        return query_string
        
    }
    
    
    
    
    class func login(mobile: String, password: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        
        let parameters:[String:String] = [ Const.PHONE: mobile, Const.PASSWORD: password, "type": "ios" ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        
        manager.request( "url", method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func signIn(email: String, password: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let deviceToken : String!
        
        if let devToken = UserDefaults.standard.string(forKey: "deviceToken") {
            
            deviceToken = DATA().getDeviceToken()
        }
        else {
            
            deviceToken = "asjdl29834jrljp9123j4r20090"
            
            print("no token")
            
        }
        
        
        print(deviceToken)
        
        
        let parameters:[String:String] = [ Const.Params.EMAIL: email, Const.Params.PASSWORD: password, Const.Params.DEVICE_TOKEN: deviceToken, Const.Params.DEVICE_TYPE: "ios", Const.Params.LOGIN_BY: Const.MANUAL ]
        
        
        print(parameters)
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.LOGIN, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func signUp(firstname: String, lastName: String, email: String, mobile: String, countryCode: String, currency: String, timezone: String, password: String, gender: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        //        let deviceToken = DATA().getDeviceToken()
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let deviceToken : String!
        
        if let devToken = UserDefaults.standard.string(forKey: "deviceToken") {
            
            deviceToken = DATA().getDeviceToken()
        }
        else {
            
            deviceToken = "asjdl29834jrljp9123j4r20090"
            
            print("no token")
            
        }
        
        let parameters:[String:String] = [Const.Params.FIRSTNAME: firstname, Const.Params.LAST_NAME: lastName, Const.Params.EMAIL: email, Const.Params.PHONE: mobile, Const.COUNTRY_CODE:countryCode, Const.Params.TIMEZONE: timezone, Const.PASSWORD: password, Const.Params.GENDER:gender, Const.Params.CURRENCEY: currency, Const.Params.DEVICE_TYPE: "ios", Const.Params.LOGIN_BY: Const.MANUAL, Const.Params.PICTURE:"",Const.Params.DEVICE_TOKEN: deviceToken, ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        
        manager.request( Const.Url.REGISTER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func signInWithFacebook(socialId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let pushToken = DATA().getDeviceToken()
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let deviceToken : String!
        
        if let devToken = UserDefaults.standard.string(forKey: "deviceToken") {
            
            deviceToken = DATA().getDeviceToken()
        }
        else {
            
            deviceToken = "asjdl29834jrljp9123j4r20090"
            
            print("no token")
            
        }
        
        
        
        let parameters:[String:String] = [Const.Params.SOCIAL_ID: socialId,Const.Params.DEVICE_TOKEN: deviceToken, Const.Params.LOGIN_BY: Const.SOCIAL_FACEBOOK, Const.Params.DEVICE_TYPE: Const.DEVICE_TYPE_IOS ]
        
        manager.request( Const.Url.LOGIN, method: .post, parameters: parameters, headers: API.getHeaders()).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    class func getTaxiTypes(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.TAXI_TYPE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getTaxiTypesWithDistanceTime(dist: String, time: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.DISTANCE: dist,
                                           Const.Params.TIME: time,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.TAXI_TYPE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func promoCodeApply(with procode: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.PROMO_CODE: procode]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.PROMOCODE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    class func fetchRideHistory(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.GET_HISTORY, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func fetchSheduledRides(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.GET_LATER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func requestTaxi(serviceType: String,EstimatedFare:String,completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let promo_code: String!
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let dr_lat: String = defaults.string(forKey: Const.DR_LATITUDE)!
        let dr_lon: String = defaults.string(forKey: Const.DR_LONGITUDE)!
        
        let pi_address: String = defaults.string(forKey: Const.PI_ADDRESS)!
        let dr_address: String = defaults.string(forKey: Const.DR_ADDRESS)!
        
        if let promo = defaults.string(forKey: "PROMOCODE") {
            promo_code = promo
        }else {
            promo_code = ""
        }
        var parameters:[String:String] = [:]
        
        //if(!(pi_lat ?? "").isEmpty)
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.S_LATITUDE : pi_lat,
                       Const.Params.S_LONGITUDE : pi_lon,
                       Const.Params.D_LATITUDE : dr_lat,
                       Const.Params.D_LONGITUDE : dr_lon,
                       Const.Params.S_ADDRESS : pi_address,
                       Const.Params.D_ADDRESS : dr_address,
                       Const.Params.REQ_STATUS_TYPE : "1",
                       Const.Params.SERVICE_TYPE : serviceType,
                       Const.Params.DEVICE_TYPE: "ios",
                       Const.Params.ESTIMATED_FARE:EstimatedFare,
                       Const.Params.PROMO_CODE:promo_code]
        
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.REQUEST_TAXI, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func requestAirportTaxi(serviceType: String, airportPackageId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let promo_code: String!
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let dr_lat: String = defaults.string(forKey: Const.DR_LATITUDE)!
        let dr_lon: String = defaults.string(forKey: Const.DR_LONGITUDE)!
        
        let pi_address: String = defaults.string(forKey: Const.PI_ADDRESS)!
        let dr_address: String = defaults.string(forKey: Const.DR_ADDRESS)!
        if let promo = defaults.string(forKey: "PROMOCODE") {
            promo_code = promo
        }else {
            promo_code = ""
        }
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.S_LATITUDE : pi_lat,
                       Const.Params.S_LONGITUDE : pi_lon,
                       Const.Params.D_LATITUDE : dr_lat,
                       Const.Params.D_LONGITUDE : dr_lon,
                       Const.Params.S_ADDRESS : pi_address,
                       Const.Params.D_ADDRESS : dr_address,
                       Const.Params.REQ_STATUS_TYPE : "3",
                       Const.Params.SERVICE_TYPE : serviceType,
                       Const.Params.AIRPORT_PACKAGE_ID : airportPackageId,
                       Const.Params.DEVICE_TYPE: "ios",
                       Const.Params.PROMO_CODE:promo_code]
        
        
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.REQUEST_TAXI, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func requestAirportTaxiLater(dateTime: String, serviceType: String, airportPackageId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let promo_code: String!
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let dr_lat: String = defaults.string(forKey: Const.DR_LATITUDE)!
        let dr_lon: String = defaults.string(forKey: Const.DR_LONGITUDE)!
        
        let pi_address: String = defaults.string(forKey: Const.PI_ADDRESS)!
        let dr_address: String = defaults.string(forKey: Const.DR_ADDRESS)!
        
        if let promo = defaults.string(forKey: "PROMOCODE") {
            promo_code = promo
        }else {
            promo_code = ""
        }
        
        
        print("time \(dateTime)")
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.LATITUDE : pi_lat,
                       Const.Params.LONGITUDE : pi_lon,
                       Const.Params.D_LATITUDE : dr_lat,
                       Const.Params.D_LONGITUDE : dr_lon,
                       Const.Params.S_ADDRESS : pi_address,
                       Const.Params.D_ADDRESS : dr_address,
                       Const.Params.REQ_STATUS_TYPE : "3",
                       Const.Params.SERVICE_TYPE : serviceType,
                       Const.Params.AIRPORT_PACKAGE_ID : airportPackageId,
                       "requested_time": dateTime,
                       Const.Params.DEVICE_TYPE: "ios",
                       Const.Params.PROMO_CODE:promo_code]
        
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        print(parameters)
        
        manager.request( Const.Url.REQUEST_LATER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func requestHourlyTaxi(serviceType: String, hourlyPackageId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        let promo_code: String!
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let pi_address: String = defaults.string(forKey: Const.PI_ADDRESS)!
        
        if let promo = defaults.string(forKey: "PROMOCODE") {
            promo_code = promo
        }else {
            promo_code = ""
        }
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.S_LATITUDE : pi_lat,
                       Const.Params.S_LONGITUDE : pi_lon,
                       Const.Params.D_LATITUDE : "",
                       Const.Params.D_LONGITUDE : "",
                       Const.Params.S_ADDRESS : pi_address,
                       Const.Params.D_ADDRESS : "",
                       Const.Params.REQ_STATUS_TYPE : "2",
                       Const.Params.SERVICE_TYPE : serviceType,
                       Const.Params.HOURLY_PACKAGE_ID : hourlyPackageId,
                       Const.Params.DEVICE_TYPE: "ios",
                       Const.Params.PROMO_CODE:promo_code]
        
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.REQUEST_TAXI, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func requestHourlyTaxiLater(dateTime: String, serviceType: String, hourlyPackageId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        let promo_code: String!
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let pi_address: String = defaults.string(forKey: Const.PI_ADDRESS)!
        if let promo = defaults.string(forKey: "PROMOCODE") {
            promo_code = promo
        }else {
            promo_code = ""
        }
        print("time \(dateTime)")
        var parameters:[String:String] = [:]
        
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.LATITUDE : pi_lat,
                       Const.Params.LONGITUDE : pi_lon,
                       Const.Params.D_LATITUDE : "",
                       Const.Params.D_LONGITUDE : "",
                       Const.Params.S_ADDRESS : pi_address,
                       Const.Params.D_ADDRESS : "",
                       Const.Params.REQ_STATUS_TYPE : "2",
                       Const.Params.SERVICE_TYPE : serviceType,
                       Const.Params.HOURLY_PACKAGE_ID : hourlyPackageId,
                       "requested_time": dateTime,
                       Const.Params.DEVICE_TYPE: "ios",
                       Const.Params.PROMO_CODE:promo_code]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        print(parameters)
        
        manager.request( Const.Url.REQUEST_LATER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    class func checkRequestStatus(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
         debugPrint(sessionToken)
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.CHECKREQUEST_STATUS, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func requestTaxiLater(dateTime: String, serviceType: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let pi_lat: String = defaults.string(forKey: Const.PI_LATITUDE)!
        let pi_lon: String = defaults.string(forKey: Const.PI_LONGITUDE)!
        
        let dr_lat: String = defaults.string(forKey: Const.DR_LATITUDE)!
        let dr_lon: String = defaults.string(forKey: Const.DR_LONGITUDE)!
        
        let pi_address: String = defaults.string(forKey: Const.PI_ADDRESS)!
        let dr_address: String = defaults.string(forKey: Const.DR_ADDRESS)!
        
        print("time \(dateTime)")
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.LATITUDE : pi_lat,
                       Const.Params.LONGITUDE : pi_lon,
                       Const.Params.D_LATITUDE : dr_lat,
                       Const.Params.D_LONGITUDE : dr_lon,
                       Const.Params.S_ADDRESS : pi_address,
                       Const.Params.D_ADDRESS : dr_address,
                       Const.Params.REQ_STATUS_TYPE : "1",
                       Const.Params.SERVICE_TYPE : serviceType,
                       "requested_time": dateTime,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        print(parameters)
        
        manager.request( Const.Url.REQUEST_LATER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
                
                
                
            case .success(let value):
                
                let json = JSON(value)
                
                print(json)
                
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func cancelRide(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let requestId = defaults.string(forKey: Const.Params.REQUEST_ID)
        let resasonId = defaults.string(forKey: Const.Params.REASON_ID)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.REQUEST_ID: requestId!,Const.Params.REASON_ID: resasonId!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.CANCEL_RIDE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                }
                
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func cancelRideReason(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        //let requestId = defaults.string(forKey: Const.Params.REQUEST_ID)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.CANCEL_RIDE_REASON, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func cancelCreateRequest(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!, Const.Params.TOKEN: sessionToken!, Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.CANCEL_CREATE_REQUEST, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func getFare(distance:String, duration: String, serviceType: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.TIME : duration,
                       Const.Params.DISTANCE : distance,
                       Const.Params.TAXI_TYPE : serviceType,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.FARE_CALCULATION, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func sendPay(isPaid:String, paymentMode: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let requestId = defaults.string(forKey: Const.Params.REQUEST_ID)
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.REQUEST_ID : requestId!,
                       Const.Params.IS_PAID : isPaid,
                       Const.Params.PAYMENT_MODE : paymentMode,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        print(parameters)
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.PAYNOW, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func updatePayment(paymentMode: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let requestId = defaults.string(forKey: Const.Params.REQUEST_ID)
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.REQUEST_ID : requestId!,
                       Const.Params.PAYMENT_MODE : paymentMode,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.PAYMENT_MODE_UPDATE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    class func getPayment(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id: String = defaults.string(forKey: Const.Params.ID)!
        let sessionToken : String = defaults.string(forKey: Const.Params.TOKEN)!
        
        
        let conte_URL: String = "\(Const.Url.GET_PAYMENT_MODE)id=\(id)&token=\(sessionToken)"
        
        
        print(conte_URL)
        
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( conte_URL, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    
    
    class func giveRating(rating:String, comment: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        let requestId = defaults.string(forKey: Const.Params.REQUEST_ID)
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.REQUEST_ID : requestId!,
                       Const.Params.COMMENT : comment,
                       Const.Params.RATING : rating,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.RATE_PROVIDER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getProviders(latlong:CLLocationCoordinate2D, completionHandler: @escaping (JSON?, Error?) -> ()){
        print("getproviders")
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        if id == nil || sessionToken == nil {
            return
        }
        print("getproviders - id \(id)")
        print("getproviders - token \(sessionToken)")
        var parameters:[String:String] = [:]
        var taxiType: String = "\(DATA().getTaxiType())"
        if (taxiType ?? "").isEmpty || taxiType == "0"{ // if selected taxi type is empty then select the first as default
            let defaultTaxi = DATA().getDefaultTaxiType()
            if String.isNilOrEmpty(defaultTaxi) == true{
//            if !(defaultTaxi ?? "").isEmpty{ // if default is empty then check the list
                let typesString = DATA().getTaxiTypesData()
                if !(typesString ?? "").isEmpty
                {
                    let typesArray = JSON.init(parseJSON: typesString).arrayValue
                    for type: JSON in typesArray {
                        taxiType = TaxiType.init(taxiObj: type).id
                        DATA().putDefaultTaxiType(request: taxiType)
                        break
                    }
                }
            }
            else
            {
                
                taxiType = defaultTaxi
            }
            
        }
        
        if (taxiType ?? "").isEmpty || taxiType == "0"{ // if its still empty then just return
            return
        }
        
        var lat:String = "\(latlong.latitude)"
        var lon:String = "\(latlong.longitude)"
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.LATITUDE : lat,
                       Const.Params.LONGITUDE : lon,
                       Const.Params.TAXI_TYPE : taxiType,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.GET_PROVIDERS, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getAirports(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        manager.request( Const.Url.AIRPORT_LST, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getLocations(key: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.KEY: key,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        manager.request( Const.Url.LOCATION_LST, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getFareAirportPackage(airport_details_id:String, location_details_id: String, service_id: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.SERVICE_TYPE : service_id,
                       "airport_details_id": airport_details_id,
                       "location_details_id": location_details_id,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        print(parameters)
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.AIRPORT_PACKAGE_FARE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func getFareHourlyPackage(numberOfHours:String, service_id: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.SERVICE_TYPE : service_id,
                       Const.Params.NO_HOUR : numberOfHours,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.HOURLY_PACKAGE_FARE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func cancelScheduledRide(reqId: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.REQUEST_ID: reqId,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        manager.request( Const.Url.CANCEL_LATER_RIDE, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func getOTP(mobile: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let parameters:[String:String] = [ Const.Params.PHONE: mobile,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        manager.request( Const.Url.GET_OTP, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func register2(firstName: String, lastName: String, email: String, password: String, mobile: String,  completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let deviceToken = DATA().getDeviceToken()
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let parameters:[String:String] = [Const.Params.FIRSTNAME: firstName,
                                          Const.Params.LAST_NAME: lastName,
                                          Const.Params.PHONE: mobile,
                                          Const.Params.PASSWORD: password,
                                          Const.Params.EMAIL: email,
                                          Const.Params.CURRENCEY: "1",
                                          Const.Params.DEVICE_TOKEN: deviceToken,
                                          Const.Params.DEVICE_TYPE: "ios",
                                          Const.Params.LOGIN_BY: Const.MANUAL,
                                          Const.Params.TIMEZONE: TimeZone.current.identifier]
        print("timezone",TimeZone.current.identifier)
        
        print(parameters)
        
        //confirm this
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        print(Const.Url.REGISTER)
        
        manager.request( Const.Url.REGISTER, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    class func getBrainTreeClientToken(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        //confirm this
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        manager.request( Const.Url.GET_BRAIN_TREE_TOKEN_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func forgotPassword(email: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.EMAIL: email,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        //confirm this
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        manager.request( Const.Url.FORGOT_PASSWORD, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func sendNonce(nonce:String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.PAYMENT_METHOD_NONCE : nonce,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.CREATE_ADD_CARD_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    class func getAddedCards(completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"        ]
        
        manager.request( Const.Url.GET_ADDED_CARDS_URL, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json, nil)
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func setDefaultCard(cardNumber:String,type:String,cardId:String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.PAYMENT_MODE : type,
                       Const.Params.CARD_ID : cardId,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.CREATE_SELECT_CARD_URL, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func removeCard(cardId:String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        
        var parameters:[String:String] = [:]
        
        parameters = [ Const.Params.ID: id!,
                       Const.Params.TOKEN: sessionToken!,
                       Const.Params.CARD_ID : cardId,
                       Const.Params.DEVICE_TYPE: "ios" ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        manager.request( Const.Url.REMOVE_CARD, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
    }
    
    class func updateProfile(firstName: String, lastName: String, gender: String, phone: String, email: String, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.FIRSTNAME: firstName,
                                           Const.Params.LAST_NAME: lastName,
                                           Const.Params.GENDER: gender,
                                           Const.Params.EMAIL: email,
                                           Const.Params.PHONE: phone,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        manager.request( Const.Url.UPDATE_PROFILE, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                completionHandler(json, nil)
                
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                completionHandler(nil, error)
                
            }
        }
        
    }
    
    class func updateProfileWithImage(firstName: String, lastName: String, gender: String, phone: String, email: String, image: UIImage, completionHandler: @escaping (JSON?, Error?) -> ()){
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: Const.Params.ID)
        let sessionToken = defaults.string(forKey: Const.Params.TOKEN)
        
        let parameters:[String:String] = [ Const.Params.ID: id!,
                                           Const.Params.TOKEN: sessionToken!,
                                           Const.Params.FIRSTNAME: firstName,
                                           Const.Params.LAST_NAME: lastName,
                                           Const.Params.GENDER: gender,
                                           Const.Params.EMAIL: email,
                                           Const.Params.PHONE: phone,
                                           Const.Params.DEVICE_TYPE: "ios"]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        
        manager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: Const.Params.PICTURE,fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                       to:Const.Url.UPDATE_PROFILE)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print(response.result.value)
                    let json = JSON(response.result.value)
                    completionHandler(json, nil)
                }
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
                    completionHandler(nil,error as NSError)
                    
                    
                }
                print(error)
                completionHandler(nil, error)
                
            }
        }
    }
    
    
    
    
    
    
    
    
    class func authenticate(authenticate_user: User){
        
        
        
        let user_defaults = UserDefaults.standard
        
        
        user_defaults.set(true, forKey: "isloggedin")
        user_defaults.set(authenticate_user.name, forKey: "user_name")
        user_defaults.set(authenticate_user.email, forKey: "user_email")
        user_defaults.set(authenticate_user.id, forKey: "user_id")
        user_defaults.set(authenticate_user.token, forKey: "user_token")
        user_defaults.set(authenticate_user.img_url, forKey: "user_image")
        user_defaults.set(authenticate_user.is_user, forKey: "is_user")
        user_defaults.set(authenticate_user.is_seller, forKey: "is_seller")
        user_defaults.set(authenticate_user.phone, forKey: "phone")
        user_defaults.synchronize()
        
        
        
        
        
        API.loadUser()
        
        
    }
    
    
    class func  isLoggedIn() -> Bool{
        
        let user_defaults = UserDefaults.standard
        let isloggedin: Bool = user_defaults.bool(forKey: "isloggedin")
        
        if(isloggedin){
            return true
        }
        else{
            return false
        }
        
        print("No one logged")
        return false
    }
    
    
    class func loadUser(){
        
        if(API.isLoggedIn()){
            
            let user_defaults = UserDefaults.standard
            
            let name = user_defaults.string(forKey: "user_name")
            let email = user_defaults.string(forKey: "user_email")
            let id = user_defaults.string(forKey: "user_id")
            let token = user_defaults.string(forKey: "user_token")
            let img_url = user_defaults.string(forKey: "user_image")
            
            let is_seller = user_defaults.bool(forKey: "is_seller")
            let is_user = user_defaults.bool(forKey: "is_user")
            let phone = user_defaults.string(forKey: "phone")
            
            let current_user = User(id: id!, name: name!, email: email!, token: token!, phone: phone!)
            
            current_user.is_seller = is_seller
            current_user.is_user = is_user
            
            current_user.img_url = img_url
            
            
            API.current_user = current_user
            
            let nc = NotificationCenter.default // Note that default is now a property, not a method call
            nc.post(name:Notification.Name(rawValue:"MyNotification"),
                    object: nil,
                    userInfo: [:])
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            //     appDelegate.setup_pubnub()
            
        }
        
    }
    
    
    class func logout(){
        
        let user_defaults = UserDefaults.standard
        user_defaults.set(false, forKey: "isloggedin")
        user_defaults.set("", forKey: "user_name")
        user_defaults.set("", forKey: "user_email")
        user_defaults.set("", forKey: "user_id")
        user_defaults.set("", forKey: "user_token")
        user_defaults.set("", forKey: "user_image")
        user_defaults.set(false, forKey: "is_user")
        user_defaults.set(false, forKey: "is_seller")
        user_defaults.set("", forKey: "phone")
        user_defaults.synchronize()
        API.current_user = nil
    }
    
    
    
    class func getHeaders(headers: [String:String] = [:]) -> [String:String]{
        
        var new_headers: [String:String] = headers
        let defaults = UserDefaults.standard
        
        if(API.isLoggedIn()){
            
            if let token = defaults.string(forKey: Const.TOKEN) {
                print(token) // Some String Value
                new_headers["Authorization"] = token //API.current_user.token!
            }
        }
        return new_headers
    }
    
    
    
    class func loadActivityIndicator() -> NVActivityIndicatorView{
        
        let activity = NVActivityIndicatorView(frame: CGRect(x:0,y:0,width:0,height:0), type: NVActivityIndicatorType.ballClipRotate, color: UIColor.clear)
        return activity
    }
    
    
    
}

extension String
{   //  returns false if passed string is nil or empty
    static func isNilOrEmpty(_ string:String?) -> Bool
    {   if  string == nil                   { return true }
        return string!.isEmpty
    }
}// extension: String
