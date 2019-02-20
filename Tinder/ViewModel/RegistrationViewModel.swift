//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/2.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegistrationViewModel {
    
    var fullName: String?{didSet{checkFormValidity()}}
    var email: String?{didSet{checkFormValidity()}}
    var password: String?{didSet{checkFormValidity()}}
    
    func checkFormValidity(){
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
    
    //Reactive programming
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()
    
    fileprivate func saveImageToFirebase(completion: @escaping (_ error: Error?) -> ()) {
        //Only upload image to storage once you are authorized
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/images/\(fileName)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        storageRef.putData(imageData, metadata: nil, completion: { [unowned self] (_, error) in
            if let error = error{
                completion(error)
                return
            }
            print("Successfully upload image to storage!")
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error{
                    completion(error)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Download url of the image: \(url?.absoluteString ?? "")")
                //store the download url to the firestore in next lesson
                //just invoke the completion handler when successfully registered user
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion:@escaping (_ error: Error?) -> ()){
        let uid = Auth.auth().currentUser?.uid ?? ""
        let usersDocData: [String : Any] = [
            "fullName" : fullName ?? "",
            "uid" : uid,
            "imageUrl1": imageUrl,
            "age": SettingController.defaultUserAge,
            "minSeekingAge": SettingController.defaultMinSeekingAge,
            "maxSeekingAge": SettingController.defaultMaxSeekingAge
        ]
        Firestore.firestore().collection("users").document(uid).setData(usersDocData) { (error) in
            if let error = error{
                completion(error)
                return
            }
            print("Successfully upload user's information in firebase")
            completion(nil)
        }
        
        let swipesDocData = [String : Int]()
        Firestore.firestore().collection("swipes").document(uid).setData(swipesDocData){ (error) in
            if let error = error{
                completion(error)
                return
            }
            print("Successfully upload swipe information in firebase")
            completion(nil)
        }
    }
    
    
    func performRegistration(completion: @escaping (_ error: Error?) -> ()){
        guard let email = email, let password = password else {return}
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) {[unowned self] (result, error) in
            if let error = error{
                completion(error)
                return
            }
            
            print("Successfully register user: \(result?.user.uid ?? "")")
            self.saveImageToFirebase(completion: completion)
        }
    }
}
