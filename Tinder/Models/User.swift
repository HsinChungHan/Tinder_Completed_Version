//
//  User.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/23.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

extension Dictionary{
    func toString(key: Key) -> String{
        return self[key] as? String ?? ""
    }
    
    func toInt(key: Key) -> Int{
        return self[key] as? Int ?? 0
    }
}

import Foundation
import UIKit
struct User: ProducesCardViewModel {
//    let name: String, age: Int, profession: String
    var name: String?, age: Int?, profession: String?
//    let imageNames: [String]
//    let imageUrl1: String
//    let uid: String
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String

    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    init(dictionary: [String: Any]) {
        //where we'll initialize our users here
//        self.name = dictionary["fullName"] as? String ?? ""
        self.name = dictionary.toString(key: "fullName")
//        self.age = 0
//        self.profession = "Jobless"
        self.age = dictionary.toInt(key: "age")
        self.profession = dictionary.toString(key: "profession")
//        self.imageNames = [dictionary["imageUrl1"] as? String ?? ""]
//        self.imageUrl1 = dictionary["imageUrl1"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
//        self.uid = dictionary["uid"] as? String ?? ""
        self.uid = dictionary.toString(key: "uid")
        self.minSeekingAge = dictionary.toInt(key: "minSeekingAge")
        self.maxSeekingAge = dictionary.toInt(key: "maxSeekingAge")
    }
    
    func toCardViewModel() -> CardViewModel{
        let nameAttributedText = NSAttributedString.init(string: name ?? "", attributes:
            [.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        let ageString = age != 0 ? "\(age!)" : "N\\A"
        let ageAttributedText = NSAttributedString.init(string: " \(ageString)", attributes: [.font : UIFont.systemFont(ofSize: 24, weight: .regular)])
        
        let professionString = profession != "" ? "\(profession!)" : "Not available"
        let professionAttributedText = NSAttributedString.init(string: "\n\(professionString)", attributes: [.font : UIFont.systemFont(ofSize: 18, weight: .heavy)])
        let attributedTexts = [nameAttributedText, ageAttributedText, professionAttributedText]
        let attributedText = NSMutableAttributedString.init()
        attributedTexts.forEach { (attributedString) in
            attributedText.append(attributedString)
        }
        
        var imageUrls = [String]()
        if let url = imageUrl1 {imageUrls.append(url)}
        if let url = imageUrl2 {imageUrls.append(url)}
        if let url = imageUrl3 {imageUrls.append(url)}
        
        return CardViewModel.init(uid: uid ?? "", imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
    }
}


