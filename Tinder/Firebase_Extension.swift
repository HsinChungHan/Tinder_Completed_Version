//
//  Firebase_Extension.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/18.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation
import Firebase
extension Firestore{
    func fetchCurrentUser(completion:@escaping (_ user: User?, _ error: Error?) -> ()){
        //fetch user from Firstore
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { [unowned self](snapshot, error) in
            if let error = error{
                print(error)
                return
            }
            guard let dictionary = snapshot?.data() else {return}
            completion(User.init(dictionary: dictionary), nil)
        }
        
        
    }
}
