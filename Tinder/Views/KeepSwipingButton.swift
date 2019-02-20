//
//  KeepSwipingButton.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/20.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class KeepSwipingButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
        let rightColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor
        gradientLayer.colors = [leftColor, rightColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        let cornerRadius = rect.height / 2
        //apply a mask using a small rectangle inside the gradient somehow
        let maskLayer = CAShapeLayer()
        let maskPath = CGMutablePath()
        
        maskPath.addPath(UIBezierPath.init(roundedRect: rect, cornerRadius: cornerRadius).cgPath)
        //punch out the middle
        maskPath.addPath(UIBezierPath.init(roundedRect: rect.insetBy(dx: 4, dy: 4) , cornerRadius: cornerRadius).cgPath)
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
        gradientLayer.mask = maskLayer
        
        
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = rect
    }

}
