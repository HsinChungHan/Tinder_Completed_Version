//
//  PhotoController.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/19.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit

class PhotoController: UIViewController{
    let imageView =  UIImageView.init(image: #imageLiteral(resourceName: "lady2-d"))
    
    init(imageUrlStr: String){
        if let url = URL.init(string: imageUrlStr){
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
