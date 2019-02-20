//
//  TopNavigationStackView.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/21.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class TopNavigationStackView: UIStackView {
    //space views here
    let settingButton = UIButton.init(type: .system)
    let messageButton = UIButton.init(type: .system)
    let fireImageView: UIImageView = {
       let imv = UIImageView.init(image: #imageLiteral(resourceName: "app_icon"))
        imv.contentMode = .scaleAspectFit
        return imv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .equalCentering
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        settingButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        [settingButton, fireImageView, messageButton].forEach { (view) in
            addArrangedSubview(view)
        }
        
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
