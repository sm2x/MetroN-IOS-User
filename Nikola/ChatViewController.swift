 //
 //  ChatViewController.swift
 //  SocketChat
 //
 //  Created by Gabriel Theodoropoulos on 1/31/16.
 //  Copyright © 2016 AppCoda. All rights reserved.
 //
 
 import UIKit
 import SwiftyJSON
 import RealmSwift
 
 class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tblChat: UITableView!
    
    @IBOutlet weak var lblOtherUserActivityStatus: UILabel!
    
    @IBOutlet weak var tvMessageEditor: UITextView!
    
    @IBOutlet weak var conBottomEditor: NSLayoutConstraint!
    
    @IBOutlet weak var lblNewsBanner: UILabel!
    
    
    @IBOutlet weak var buttonConstrains: NSLayoutConstraint!
    
    var nickname: String! = ""
    
    var senderID : String!
    
    
    var chatMessages = [[String: String]]()
    
    var bannerLabelTimer: Timer!
    
    let dateFormatter = DateFormatter()
    let dateFormatter2 = DateFormatter()
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var hud : MBProgressHUD = MBProgressHUD()
    var isAlreadyExists = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
         SocketIOManager.sharedInstance.establishConnection()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        dateFormatter2.dateFormat = "MMM-dd HH:mm"
        nickname = "\(DATA().getUserId())"
        // Do any additional setup after loading the view.
        
        let realm = try! Realm()
        let chats = realm.objects(Chat.self).sorted(byKeyPath: "date", ascending: true)
        
        print("count \(chats.count)")
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "blackBackIcon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(HelpViewController.backButton), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        self.navItem.setLeftBarButton(item1, animated: true)
        
        
        APiGetMessage()
        
        for chat in chats {
            var msg = [String : AnyObject]()
            print(chat.message)
            msg["message"] = chat.message as AnyObject
            msg["request_id"] = chat.requestId as AnyObject
            msg["sender"] = chat.sender as AnyObject
            msg["time"] = chat.date as AnyObject
            //            chatMessages.append(msg)
        }
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.handleKeyboardDidShowNotification(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.handleKeyboardDidHideNotification(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.handleConnectedUserUpdateNotification(_:)), name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.handleDisconnectedUserUpdateNotification(_:)), name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.handleUserTypingNotification(_:)), name: NSNotification.Name(rawValue: "userTypingNotification"), object: nil)
        
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        
        GetchatMessageFromSocket()
        
       
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func backButton(sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    
    func GetchatMessageFromSocket()
    {
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                if let val = messageInfo["message"] as! [String: AnyObject]? {
                    if val.keys.contains("message") {
                        
                        
                        var MSG = [String:String]()
                        
                        MSG["message"]  = "\(val["message"]!)"
                        MSG["request_id"] = val["request_id"]?.stringValue
                        
                        MSG["sender"] = val["id"]?.stringValue
                        MSG["type"] = "\(val["type"]!)"
                        
                        
                        print(MSG)
                        self.chatMessages.append(MSG)
                        self.tblChat.reloadData()
                        self.scrollToBottom()
                    }
                }
            })
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        configureNewsBannerLabel()
        configureOtherUserActivityLabel()
        
        let defaults = UserDefaults.standard
        senderID = defaults.string(forKey: Const.Params.ID)
        
        
        
        tvMessageEditor.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        let realm = try! Realm()
        //        try! realm.write {
        //            realm.deleteAll()
        //        }
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        buttonConstrains.constant = 330
        textView.text = nil
        textView.textColor = UIColor.black
        
        
        //        if textView.textColor == UIColor.lightGray {
        //            textView.text = nil
        //            textView.textColor = UIColor.black
        //        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        SocketIOManager.sharedInstance.exitChatWithNickname(nickname) { () -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                //                self.nickname = nil
                //                self.users.removeAll()
                //                self.tblUserList.isHidden = true
                //                self.askForNickname()
            })
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: IBAction Methods
    
    
    
    func APiGetMessage()
    {
        API.getMessageChatApi(request_id:"\(DATA().getRequestId())"){ json, error in
            
            if (error != nil) {
                print(error.debugDescription)
                self.hideLoader()
                self.view.makeToast(message: (error?.localizedDescription)!)
            }else{
                do{
                    
                    let status = json![Const.STATUS_CODE].boolValue
                    let statusMessage = json![Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        self.hideLoader()
                        print( json!)
                        
                        
                        let chat =   json!["data"].arrayValue
                        print(self.chatMessages.count)
                        print(chat.count)
                        
                        
                        if(self.chatMessages.count != chat.count)
                        {
                            self.chatMessages = [[String: String]]()
                            for chats in chat
                            {
                                let chat = Chat()
                                var MSG = [String:String]()
                                
                                MSG["message"]  = chats["message"].stringValue
                                MSG["request_id"] = chats["request_id"].stringValue
                                
                                MSG["sender"] = chats["is_user"].stringValue
                                MSG["type"] = chats["type"].stringValue
                                
                                
                                
                                self.chatMessages.append(MSG)
                                self.nickname = "1"
                                self.tblChat.reloadData()
                                self.scrollToBottom()
                                
                            }
                        }
                        print(self.chatMessages)
                        self.isAlreadyExists = false
                        //self.goToDashboard()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            //                        self.goToDashboard()
                        })
                        
                    }else{
                        self.hideLoader()
                        print(statusMessage)
                        print(json ?? "json empty")
                        var msg = try json!["error"].stringValue
                        self.isAlreadyExists = false
                        //                        self.view.makeToast(message: msg)
                    }
                }catch {
                    self.hideLoader()
                    self.view.makeToast(message: "Server Error")
                    print("json error")
                    self.isAlreadyExists = false
                }
            }
        }
        
    }
    
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        if tvMessageEditor.text.characters.count > 0 {
            
            var msg = [String: String]()
            msg["message"] = tvMessageEditor.text  as! String
            msg["request_id"] = "\(DATA().getRequestId())"
            msg["sender"] = String(DATA().getUserId())
            msg["type"] = String("up")
            
            let chat = Chat()
            chat.message = tvMessageEditor.text
            chat.requestId = DATA().getRequestId()
            //            chat.sender = "\(DATA().getUserId())"
            
            chat.sender = String(DATA().getUserId() )
            
            print(String(chat.sender) ?? "string")
            
            
            nickname = senderID
            
            //let timeString = val["time"] as! String
            //let date: Date = dateFormatter.date(from: timeString)!
            chat.date = self.dateFormatter.string(from: Date())
            
            msg["time"] = chat.date  as! String
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(chat)
            }
            
            SocketIOManager.sharedInstance.sendMessage(tvMessageEditor.text!, withNickname: nickname)
            
            tvMessageEditor.text = ""
            tvMessageEditor.resignFirstResponder()
            
            self.chatMessages.append(msg as! [String : String])
            //            self.chatMessages.append(msg as )
            self.tblChat.reloadData()
            self.scrollToBottom()
        }
        
        //          self.sendMessage()
    }
    
    
    // MARK: Custom Methods
    
    func configureTableView() {
        tblChat.delegate = self
        tblChat.dataSource = self
        tblChat.register(UINib(nibName: "ChatSendCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        
        tblChat.register(UINib(nibName: "ChatReceiveCell", bundle: nil), forCellReuseIdentifier: "chatReceive")
        
        tblChat.separatorStyle = .none
        tblChat.estimatedRowHeight = 90.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    func configureNewsBannerLabel() {
        lblNewsBanner.layer.cornerRadius = 15.0
        lblNewsBanner.clipsToBounds = true
        lblNewsBanner.alpha = 0.0
    }
    
    
    func configureOtherUserActivityLabel() {
        lblOtherUserActivityStatus.isHidden = true
        lblOtherUserActivityStatus.text = ""
    }
    
    func handleKeyboardDidShowNotification(_ notification: Notification) {
  
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
            self.view.frame.origin.y -= keyboardSize.height
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    func handleKeyboardDidHideNotification(_ notification: Notification) {
    
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        self.view.frame.origin.y = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)) { () -> Void in
            if self.chatMessages.count > 0 {
                let lastRowIndexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                self.tblChat.scrollToRow(at: lastRowIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    
    func showBannerLabelAnimated() {
        UIView.animate(withDuration: 0.75, animations: { () -> Void in
            self.lblNewsBanner.alpha = 1.0
            
        }, completion: { (finished) -> Void in
            self.bannerLabelTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ChatViewController.hideBannerLabel), userInfo: nil, repeats: false)
        })
    }
    
    
    func hideBannerLabel() {
        if bannerLabelTimer != nil {
            bannerLabelTimer.invalidate()
            bannerLabelTimer = nil
        }
        
        UIView.animate(withDuration: 0.75, animations: { () -> Void in
            self.lblNewsBanner.alpha = 0.0
            
        }, completion: { (finished) -> Void in
        })
    }
    
    
    
    func dismissKeyboard() {
        if tvMessageEditor.isFirstResponder {
            tvMessageEditor.resignFirstResponder()
            
            SocketIOManager.sharedInstance.sendStopTypingMessage(nickname)
        }
    }
    
    
    func handleConnectedUserUpdateNotification(_ notification: Notification) {
        let connectedUserInfo = notification.object as! [String: AnyObject]
        let connectedUserNickname = connectedUserInfo["nickname"] as? String
        lblNewsBanner.text = "User \(connectedUserNickname!.uppercased()) was just connected."
        showBannerLabelAnimated()
    }
    
    
    func handleDisconnectedUserUpdateNotification(_ notification: Notification) {
        let disconnectedUserNickname = notification.object as! String
        lblNewsBanner.text = "User \(disconnectedUserNickname.uppercased()) has left."
        showBannerLabelAnimated()
    }
    
    
    func handleUserTypingNotification(_ notification: Notification) {
        if let typingUsersDictionary = notification.object as? [String: AnyObject] {
            var names = ""
            var totalTypingUsers = 0
            for (typingUser, _) in typingUsersDictionary {
                if typingUser != nickname {
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUsers += 1
                }
            }
            
            if totalTypingUsers > 0 {
                let verb = (totalTypingUsers == 1) ? "is" : "are"
                
                lblOtherUserActivityStatus.text = "\(names) \(verb) now typing a message..."
                lblOtherUserActivityStatus.isHidden = false
            }
            else {
                lblOtherUserActivityStatus.isHidden = true
            }
        }
        
    }
    
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = ChatCell()
        
        print(nickname)
        
        let currentChatMessage = chatMessages[indexPath.row]
        
        
        
        
        print(currentChatMessage)
        //let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String//as! [String: AnyObject]
        //let messageDate = currentChatMessage["date"] as! String
        
        
        let send : String = currentChatMessage["sender"] as! String
        
        //        let senderNickname = "\(currentChatMessage["sender"] as! String)"
        
        let chatType : String = currentChatMessage["type"] as! String
        
        
        nickname = String(DATA().getUserId())
        
        
        print(send)
        
        let senderNickname = send
        
        if chatType == "up" {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "idCellChat", for: indexPath) as! ChatCell
            
            
            cell.lblChatMessage.textAlignment = NSTextAlignment.right
            cell.lblMessageDetails.textAlignment = NSTextAlignment.right
            
            cell.lblChatMessage.textColor = lblNewsBanner.backgroundColor
            
            //            let date = self.dateFormatter.date(from: currentChatMessage["time"] as! String)!
            //            let newDate = self.dateFormatter2.string(from: date)
            
            cell.lblChatMessage.text = "\(message)" // + "\(message["sender"] as! String)"
            //cell.lblMessageDetails.text = "by \(senderNickname.uppercased()) @ \(messageDate)"
            //            cell.lblMessageDetails.text = "@ \(newDate)"
            
            cell.lblChatMessage.textColor = UIColor.white
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatReceive", for: indexPath) as! ChatCell
            
            
            cell.lblChatMessage.textAlignment = NSTextAlignment.left
            //            cell.lblMessageDetails.textAlignment = NSTextAlignment.left
            cell.lblChatMessage.textColor = lblNewsBanner.backgroundColor
            
            
            cell.lblChatMessage.textAlignment = NSTextAlignment.right
            //            cell.lblMessageDetails.textAlignment = NSTextAlignment.right
            
            cell.lblChatMessage.textColor = lblNewsBanner.backgroundColor
            
            //            let date = self.dateFormatter.date(from: currentChatMessage["time"] as! String)!
            //            let newDate = self.dateFormatter2.string(from: date)
            
            cell.lblChatMessage.text = "\(message)" // + "\(message["sender"] as! String)"
            //cell.lblMessageDetails.text = "by \(senderNickname.uppercased()) @ \(messageDate)"
            //            cell.lblMessageDetails.text = "@ \(newDate)"
            
            cell.lblChatMessage.textColor = UIColor.black
            
            
            
            
            return cell
        }
        
        
        
        
        return cell
    }
    
    
    // MARK: UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        
        
        SocketIOManager.sharedInstance.sendStartTypingMessage(nickname)
        
        return true
    }
    
    
    // MARK: UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
 }
 
 class Chat: Object {
    dynamic var message = ""
    dynamic var sender = ""
    dynamic var date = ""
    dynamic var requestId = 0
    
    override static func primaryKey() -> String? {
        return "date"
    }
    
 }
 
 
 extension ChatViewController:MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
 }
