//
//  ViewController.swift
//  DemoCourierApp
//
//  Created by Margels on 14/07/23.
//

import UIKit
import Foundation
import FirebaseAuth
import Courier_iOS

class ViewController: UIViewController {
    
    let userId = "YOUR_USER_ID"
    let myAccessToken = "YOUR_ACCESS_TOKEN"
    let myClientKey = "YOUR_CLIENT_KEY"
    let myNotificationTemplate = "YOUR_NOTIFICATION_TEMPLATE"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {

            try await Courier.shared.signIn(
                accessToken: self.myAccessToken,
                clientKey: self.myClientKey,
                userId: self.userId
            )
            
            Courier.shared.isUserSignedIn ? print("Successfully logged in as \(Courier.shared.userId ?? "[USERNAME_UNAVAILABLE]")") : print("Log in failed.")
            
        }
    }
    
    private func sendNotification(
        model: NotificationModel
    ) {
        
        guard let url = URL(string: "https://api.courier.com/send"),
              let jsonData = try? JSONEncoder().encode(model)
        else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.myAccessToken)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            guard let data = data else { return }
            do {
                let model = try JSONDecoder().decode(ResponseModel.self, from: data)
                print("Response: {\n   requestId: \(model.requestId)\n}")
            } catch let jsonErr {
                print("Error: \(jsonErr.localizedDescription)")
            }
        }
        
        task.resume()
        
    }


}

struct NotificationModel: Codable {
    let message: MessageModel
}

struct MessageModel: Codable {
    let to: RecipientModel
    let template: String
}

struct RecipientModel: Codable {
    let user_id: String
}

struct ResponseModel: Decodable {
    let requestId: String
}
