//
//  AppDelegate.swift
//  Nikola
//
//  Created by Sutharshan on 5/22/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import NotificationCenter
import UserNotifications
//import FacebookCore
import DropDown
import PubNub
import UserNotifications
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FacebookShare
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PNObjectEventListener,GIDSignInDelegate { //, GCMReceiverDelegate {

    var window: UIWindow?
    var client: PubNub!
     weak var defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])

        DropDown.startListeningToKeyboard()
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
//                GMSServices.provideAPIKey("AIzaSyCVmS_V5hGTX2Yj0T0aFcdElDyEliaT6ys")
//                GMSPlacesClient.provideAPIKey("AIzaSyCVmS_V5hGTX2Yj0T0aFcdElDyEliaT6ys")
//        GMSServices.provideAPIKey("AIzaSyCVmS_V5hGTX2Yj0T0aFcdElDyEliaT6ys")
//        GMSPlacesClient.provideAPIKey("AIzaSyCVmS_V5hGTX2Yj0T0aFcdElDyEliaT6ys")
        
        GMSServices.provideAPIKey("AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik")
      GMSPlacesClient.provideAPIKey("AIzaSyDoujGbr86VY2F6vhh-bzZjsebCFoRn0ik")
        UIApplication.shared.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self //DID NOT WORK WHEN self WAS MyOtherDelegateClass()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // Enable or disable features based on authorization.
            if granted {
                // update application settings
            }
        }
        
        
//        let storyboard = UIStoryboard(name: "Splash", bundle: nil)
//
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        
        let nxt = SplashNewVC(nibName: "SplashNewVC", bundle: nil)
//        let nv = UINavigationController.init(rootViewController: nxt)
//        self.present(nv, animated: true, completion: nil)
        
        self.window?.rootViewController = nxt
        self.window?.makeKeyAndVisible()
        
        // Initialize and configure PubNub client instance
        let configuration = PNConfiguration(publishKey: "demo", subscribeKey: "demo")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        // Subscribe to demo channel with presence observation
        self.client.subscribeToChannels(["my_channel"], withPresence: true)
        
        
        GIDSignIn.sharedInstance().clientID = "230865319584-lh08e36670mvpjg168ei8tjoqha3e0rq.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        registerForPushNotifications()

        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }

    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        print("didRecieve->\(dump(userInfo))")
//    }


    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        logger.log.debug("Perform Fetch with completion handler TEST")
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication =  options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        
        let googleHandler = GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication: sourceApplication,
            annotation: annotation )
        
        let facebookHandler = SDKApplicationDelegate.shared.application (
            app,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation )
        
        return googleHandler || facebookHandler
    }
    
//    //MARK:- PushNotification Did Receive Methods
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")

        let aps = data[AnyHashable("aps")]!
        if let requestType: String = defaults?.string(forKey: "requestType") {
            if requestType == "requestAccepted" {
                debugPrint("reqestAccepted")
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierUpdateStatus"), object: nil,userInfo: nil)
            }
            else if requestType == "requesting" {
                debugPrint("reqestAccepted")
            }else if requestType == "scdeduledRequest" {
                debugPrint("ScdeduledRequest")
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierUpdateScdeduledRequest"), object: nil,userInfo: nil)
            }

        }else {
            debugPrint("nil")
        }
        print(aps)
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent: UNNotification,
                                withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        withCompletionHandler([.alert, .sound, .badge])

        if let requestType: String = defaults?.string(forKey: "requestType") {
            if requestType == "requestAccepted" {
                debugPrint("reqestAccepted")
                 NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierUpdateStatus"), object: nil,userInfo: nil)
            }
            else if requestType == "requesting" {
                debugPrint("reqestAccepted")
            }else if requestType == "scdeduledRequest" {
                debugPrint("ScdeduledRequest")
                 NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierUpdateScdeduledRequest"), object: nil,userInfo: nil)
            }

        }else {
            debugPrint("nil")
        }


    }
//
    func checkAppVersion() {
        
        API.getServerVersionNumber(){ json, error in
            
            if let error = error {
                
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    
                    if(status){
                        
                        let forceUpdateStatus = json["success"].boolValue
                        
                        if(forceUpdateStatus)
                        {
                            let info = Bundle.main.infoDictionary
                            let currentVersion = info!["CFBundleShortVersionString"] as? String
                            var serverVersion = json["ios_user_version"].stringValue
                            
                            if(serverVersion.doubleValue > (currentVersion?.doubleValue)!)
                            {
                                self.popupUpdateDialogue(serverVersion)
                                
                            }
                        }
                        
                    }
                    
                    
                }else {
                    
                    
                    debugPrint("Invalid Json")
                }
                
            }
            
            
        }
        
        
        
    }
    
    
    
    func popupUpdateDialogue(_ serverVersion : String){
        
        
        var alertMessage = ""
        let lang = UserDefaults.standard.string(forKey: "currentLocalization")
        if (lang == "nb")
        {
            alertMessage = String(format: "Oppdatering %@ er tilgjengelig i app store.", serverVersion);
        }
        else{
            alertMessage = String(format: "Version %@ is available on App store.", serverVersion);
        }
        
        
        let alert = UIAlertController(title: "New version".localized(), message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okBtn = UIAlertAction(title: "Update".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "https://itunes.apple.com/us/app/prai/id1355385305?ls=1&mt=8"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:"Skip this Version" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        // alert.addAction(noBtn)
        
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive: UNNotificationResponse,
                                withCompletionHandler: @escaping ()->()) {
        withCompletionHandler()
    }
    
    //MARK:- Defauft Appdelegate Methods
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        SocketIOManager.sharedInstance.closeConnection()

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.applicationIconBadgeNumber = 0

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0

        SocketIOManager.sharedInstance.establishConnection()
         checkAppVersion()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /** Initialize configuration of GCM */
//    func configureGCMServic e() {
//        let config = GCMConfig.defaultConfig()
//        config.receiverDelegate = self
//        config.logLevel = GCMLogLevel.Debug
//        GCMService.sharedInstance().startWithConfig(config)
//    }
    
    /** Register for remote notifications to get an APNs token to use for registration to GCM */
    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.alert, .badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

    }
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        
//        return SDKApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//        
//    }
    
    //MARK:- PushNotification Settings
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    

   
    
    //MARK:- RegisterForRemoteNotificationWithDeviceToken
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let tokenParts = deviceToken.map { data -> String in
//            return String(format: "%02.2hhx", data)
//        }
//
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        
        
         UserDefaults.standard.set(token, forKey: "deviceToken")
        
        print("Device Token: \(token)")
        DATA().putDeviceToken(data: token)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    // [START signin_handler]
    //MARK:- Google SignIn
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            let dicGooglePlusLoginDetials:[String: String] = ["userId": userId!, "idToken": idToken!, "fullName": fullName! , "familyName": familyName! , "email": email! ,"givenName": givenName!]
            // [START_EXCLUDE]
             GIDSignIn.sharedInstance().signOut()
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierGooglePlusLoginDetailsForSignUp"), object: nil,userInfo: dicGooglePlusLoginDetials)
            // [END_EXCLUDE]
        } else {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
        }
    }

    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        // [END_EXCLUDE]
    }
    
    
}
extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    } }

