//
//  ViewController.swift
//  ChatModule
//
//  Created by Akash Belekar on 23/07/24.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    private let loaderView = LoaderView()
    private var chatConfig:ChatConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoader()
        chatConfig = ChatConfig(chatURL: "https://keekchat-dev.api.keek.com/chat", chatAuthURL: "https://keekchat-dev.api.keek.com/auth", chatHubURL: "https://keekchat-dev.api.keek.com/chat/chat", chatToken: "", appName: "MiiTV", fileUploadURL: "https://upload-dev.api.keek.com/files", pinnedHost: "dev.api.keek.com", userID: "")
        
        AuthenticationConnector().loginPeeks("achat002", password: "letmein@123") { success, error in
            print("Success--",success)
            AuthenticationConnector().lookupUser(userId: "100000343093") { success, error, user in
                self.chatConfig.userID = "100000343093"
      //          self.chatConfig.chatToken = KeychainService.loadKeekChatToken() ?? ""
                self.chatConfig.chatToken = UniChatBuilder.shared.setToken()
                print("=======Success=======")
            }
           // AuthenticationConnector().getKeekChatToken()
        }
    }
     func setupLoader() {
          loaderView.frame = view.bounds
          view.addSubview(loaderView)
        loaderView.startLoading()
        performSomeOperation()
      }

      private func performSomeOperation() {
          loaderView.startLoading()
            DispatchQueue.global().asyncAfter(deadline: .now() + 15) {
              DispatchQueue.main.async {
                  self.loaderView.stopLoading()
              }
          }
      }
    
    @IBAction func chatBtn(){
        print("hey")
        
//        ChatStyle.shared.messageTitle = .init(text: "messa", textColor: .blue, font: .MiitvIconFont(size: 18), aligment: .right, numberOfLines: 0)
//        ChatStyle.shared.conversation = .init(text: "sdfsdf", textColor: .systemPink, font: .MiitvIconFont(size: 13), aligment: .center, numberOfLines: 0)
//        ChatStyle.shared.groups = .init(text: "gropuesssss", textColor: .red, font: .MiitvIconFont(size: 13), aligment: .center, numberOfLines: 0)
        if  let vc = KeekMainChatViewController(nibName: "KeekMainChatViewController", bundle: nil) as? KeekMainChatViewController{
            vc.chatConfig = chatConfig
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    static func getOSVersion() -> String{
         let OSVersion = UIDevice.current.systemVersion
         return OSVersion
     }
    
   static var timestamp: String {
        let time = "\(Date().timeIntervalSince1970)" as NSString
        
        return time.substring(with: NSRange(location: 0, length: 10))
    }
    
}

