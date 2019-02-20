//
//  UIVIew_Extension.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/19.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit


struct AnchoredConstraints {
    var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}
extension UIView{
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero ) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchoredConstraints = AnchoredConstraints()
        if let top = top{
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let bottom = bottom{
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let leading = leading{
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let trailing = trailing{
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if size.width != 0{
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0{
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        
        //忘記把heightAnchor加進去了
        [anchoredConstraints.top, anchoredConstraints.bottom, anchoredConstraints.leading, anchoredConstraints.trailing, anchoredConstraints.width, anchoredConstraints.height].forEach { (constraint) in
            constraint?.isActive = true
        }
        return anchoredConstraints
    }
    
    
    func fillSuperView(padding: UIEdgeInsets = .zero){
        translatesAutoresizingMaskIntoConstraints = false
        if let superViewTopAnchor = superview?.topAnchor{
            topAnchor.constraint(equalTo: superViewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superViewBottomAnchor = superview?.bottomAnchor{
            bottomAnchor.constraint(equalTo: superViewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superViewLeadingAnchor = superview?.leadingAnchor{
            leadingAnchor.constraint(equalTo: superViewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superViewTrailingAnchor = superview?.trailingAnchor{
            trailingAnchor.constraint(equalTo: superViewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func centerInSuperView(size: CGSize = .zero){
        translatesAutoresizingMaskIntoConstraints = false
        if let superViewCneterXAnchor = superview?.centerXAnchor{
            centerXAnchor.constraint(equalTo: superViewCneterXAnchor).isActive = true
        }
        
        if let superViewCneterYAnchor = superview?.centerYAnchor{
            centerYAnchor.constraint(equalTo: superViewCneterYAnchor).isActive = true
        }
        
        if size.width != 0{
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0{
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        
    }
}
