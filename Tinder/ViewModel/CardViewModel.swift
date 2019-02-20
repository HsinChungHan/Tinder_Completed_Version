//
//  CardViewModel.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/23.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import Foundation
import UIKit
protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

//View model should represent the state of the view
class CardViewModel {
    //We're gonna define the properties that are view will display/render out
//    let imageName: String
    let uid: String
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    fileprivate var imageIndex = 0{
        didSet{
//            let image = UIImage.init(named: imageNames[imageIndex])
            if let imageUrl = URL.init(string: imageUrls[imageIndex]){
                imageIndexObserver?(imageUrl, imageIndex)
            }
        }
    }
    
    
    //reactive programming
    var imageIndexObserver: ((_ imageUrl: URL, _ imageIndex: Int) -> ())?
    
    func advanceToNextPhoto(){
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    
    func goToPreviousPgoto() {
        imageIndex = max(0, imageIndex - 1)
    }
    
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
}

//What exactlly do we do with this card view model??


