//
//  AgeRangeCell.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/18.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class AgeRangeCell: UITableViewCell {
    let minSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()
    
    let maxSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()
    
    let minLabel: AgeRangeLabel = {
       let label = AgeRangeLabel()
        label.text = "Min 44"
        return label
    }()
    
    let maxLabel: AgeRangeLabel = {
        let label = AgeRangeLabel()
        label.text = "Max 44"
        return label
    }()
    
    class AgeRangeLabel: UILabel{
        override var intrinsicContentSize: CGSize{
            return .init(width: 80, height: 0)
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    fileprivate func setupLayout(){
        let overallStackView = UIStackView.init(arrangedSubviews: [
            UIStackView.init(arrangedSubviews: [minLabel, minSlider]),
            UIStackView.init(arrangedSubviews: [maxLabel, maxSlider])
        ])
        overallStackView.axis = .vertical
        addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16), size: .zero)
    }
}
