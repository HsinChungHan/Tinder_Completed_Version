//
//  CustomTextField.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/1.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    var padding: CGFloat
    var height: CGFloat
    
    init(padding: CGFloat, height: CGFloat = 50) {
        self.padding = padding
        self.height = height
        super.init(frame: .zero)
        layer.cornerRadius = 25
        backgroundColor = .white
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        //have a padding for placeholder
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        //when you r editting, there is a padding
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize{
        return .init(width: 0, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

