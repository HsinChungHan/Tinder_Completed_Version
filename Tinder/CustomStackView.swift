//
//  CustomStackView.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/19.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class CustomStackView: UIStackView {
    
    init(subViews: [UIView], axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution?, spacing: CGFloat){
        super.init(frame: .zero)
        subViews.forEach { (view) in
            addArrangedSubview(view)
        }
        
        self.axis = axis
        if let distribution = distribution{
            self.distribution = distribution
        }
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
