//
//  HomeButtonsControllerStackView.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/20.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class HomeBottomStackView: UIStackView {
    static func creatButton(image: UIImage) -> UIButton{
        let button = UIButton.init(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    let refreshButton = creatButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = creatButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superlikeButton = creatButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = creatButton(image: #imageLiteral(resourceName: "like_circle"))
    let specialButton = creatButton(image: #imageLiteral(resourceName: "boost_circle"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 120).isActive = true
        [refreshButton, dislikeButton, superlikeButton, likeButton, specialButton].forEach { (button) in
            self.addArrangedSubview(button)
        }

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
