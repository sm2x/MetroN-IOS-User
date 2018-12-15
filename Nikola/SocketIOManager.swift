//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    static let nickName = String(DATA().getUserId())
    
//    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: Const.Url.SOCKET_URL)!)
    
//    var socket: SocketIOClient = SocketIOClient(manager: Const.Url.SOCKET_URL as! SocketManagerSpec, nsp: "")
    
    
     var socket = SocketIOClient(socketURL: URL(string: Const.Url.SOCKET_URL)!, config: [.connectParams(["type": "user","id": nickName])])
    
    override init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
        
        let socketConnectionStatus = SocketIOManager.sharedInstance.socket.status
        
        switch socketConnectionStatus {
            
            
        case SocketIOClientStatus.connected:
            print("socket connected")
        case SocketIOClientStatus.connecting:
            print("socket connecting")
        case SocketIOClientStatus.disconnected:
            print("socket disconnected")
        case SocketIOClientStatus.notConnected:
            print("socket not connected")
        }
        
        print(socket.status)
        
        
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    func connectToServerWithNickname(_ nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        
        //var jObj: JSON = ["sender": DATA().getUserId(), "receiver": DATA().getDriverId()]
        
        socket.emit("update sender", ["sender": DATA().getUserId(), "receiver": DATA().getDriverId()])
        
//        socket.emit("connectUser", nickname as String)
//        socket.on("userList") { ( dataArray, ack) -> Void in
//            completionHandler(dataArray[0] as! [[String: AnyObject]])
//        }
        
        listenForOtherMessages()
    }
    
    func exitChatWithNickname(_ nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname as String)
        completionHandler()
    }
    
    
    func sendMessage(_ message: String, withNickname nickname: String) {
        
        let payLoad = ["sender": 15, "receiver": 43 , "message":message,"type": "sent","data_type": "TEXT","status": "1", "request_id": DATA().getRequestId()] as [String : Any]
        
        print(String(format:"%f",DATA().USER_ID))
        
        
        let usdd : String = String(format:"%f",DATA().USER_ID)
        
        
//        socket.emit("send location", ["sender": DATA().getUserId(), "receiver": DATA().getDriverId() , "message":message,"type": "sent","data_type": "TEXT","status": "1", "request_id": DATA().getRequestId()] )
        
          socket.emit("send_message_to_provider", ["provider_id": "\(DATA().getDriverId())" , "message":message,"request_id": DATA().getRequestId()])
        

        //socket.emit("chatMessage", nickname as String, message as String)
    }
    
    
    func getChatMessage(_ completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
//        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
//            var messageDictionary = [String: AnyObject]()
//            messageDictionary["nickname"] = dataArray[0] as! String as AnyObject
//            messageDictionary["message"] = dataArray[1] as! String as AnyObject
//            messageDictionary["date"] = dataArray[2] as! String as AnyObject
//            
//            completionHandler(messageDictionary)
//        }
        
//        socket.on("message") { (dataArray, socketAck) -> Void in
//            //print("new message arrived")
//            //print(dataArray)
//            var messageDictionary = [String: AnyObject]()
//
//            messageDictionary["message"] = dataArray[0] as AnyObject //as! String
//            //messageDictionary["message"] = dataArray[1] as! String as AnyObject
//            //messageDictionary["date"] = dataArray[2]  as AnyObject // as! String
//
//            //let data: String = dataArray[0] as! String
//            //messageDictionary["message"] = dataArray[0] as! String as AnyObject
//
//            //let msgObj : JSON = JSON.init(parseJSON:data)
//
//
////            do{
////                messageDictionary["message"] = msgObj["hello"].stringValue as AnyObject
////                //messageDictionary["message"] = try msgObj["message"].stringValue
////            }catch {
////                print(error)
////            }
//
//            completionHandler(messageDictionary)
//        }
        
        
        
        socket.on("new_message_from_provider") { (dataArray, socketAck) -> Void in
            //print("new message arrived")
            //print(dataArray)
            var messageDictionary = [String: AnyObject]()
            
            messageDictionary["message"] = dataArray[0] as AnyObject //as! String
            //messageDictionary["message"] = dataArray[1] as! String as AnyObject
            //messageDictionary["date"] = dataArray[2]  as AnyObject // as! String
            
            //let data: String = dataArray[0] as! String
            //messageDictionary["message"] = dataArray[0] as! String as AnyObject
            
            //let msgObj : JSON = JSON.init(parseJSON:data)
            
            
            //            do{
            //                messageDictionary["message"] = msgObj["hello"].stringValue as AnyObject
            //                //messageDictionary["message"] = try msgObj["message"].stringValue
            //            }catch {
            //                print(error)
            //            }
            
            print(messageDictionary)
            
            completionHandler(messageDictionary)
        }
        
    }
    
    
    fileprivate func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userTypingNotification"), object: dataArray[0] as? [String: AnyObject])
        }
        
        socket.on("new_message_from_provider") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userMessageFromProvider"), object: dataArray[0] as? [String: AnyObject])
        }
        
    }
    
    
    func sendStartTypingMessage(_ nickname: String) {
        socket.emit("startType", nickname)
    }
    
    
    func sendStopTypingMessage(_ nickname: String) {
        socket.emit("stopType", nickname)
    }
}
