//
//  MoreInfoViewController.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/18.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
import SDWebImage

class UserDetailController: UIViewController {
    
    //You should really create a differnet viewModel for UserDetail Viewmodel
    var cardViewModel: CardViewModel?{
        didSet{
            infoLabel.attributedText = cardViewModel?.attributedString
//            guard let urlStr = cardViewModel?.imageNames.first, let url = URL.init(string: urlStr) else {
//                return
//            }
//            imageView.sd_setImage(with: url, completed: nil)
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    lazy var scrollView: UIScrollView = {
       let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        //因為在設定alwaysBounceVertical會讓scrollView裡的subView，自動有一個safeArea的距離
        //但我們並不想要
        sv.contentInsetAdjustmentBehavior = .never
        
        sv.delegate = self
        
        return sv
    }()
    
//    let imageView: UIImageView = {
//        let iv = UIImageView.init(image: #imageLiteral(resourceName: "lady2-d"))
//        iv.contentMode = .scaleAspectFill
//        iv.clipsToBounds = true
//        return iv
//    }()
    
    //how do I swap a UIImageView with a UIViewController component
    let swipingPhotosController = SwipingPhotosController()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User name GG \nDoctor\nbio text doen below"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleTapDismiss(sender:)), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleTapDismiss(sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    //3 bottom control buttons
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    @objc func handleDislike(){
        
    }
    
    lazy var superlikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))
    
    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))
    
    
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton{
        let button = UIButton.init(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
//        let dismissTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissView))
//        view.addGestureRecognizer(dismissTapGesture)
        
        setupLayout()
    }
    
    
    
    
    fileprivate func setupLayout(){
        view.addSubview(scrollView)
        scrollView.fillSuperView()
        
        let swipingView = swipingPhotosController.view!
        
        scrollView.addSubview(swipingView)
        //why frame instead of auto layout
        //在scrollView中若是使用autoLayout來設定imageView的位置
        //將無法做scroll滑動造成imageView的縮放
        
        //等等會發現swipingPhotosController跑版，原因是因為在ViewDidLoad中，scrollView還未生成
        //就把imageView加進去，造成swipingPhotosController無發抓到正確的位置
        //解法：應該要在viewWillLayoutSubview設定swipingPhotosController
//        imageView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, bottom: nil, leading: scrollView.leadingAnchor, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor, bottom: nil, leading: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 25), size: CGSize.init(width: 50, height: 50))
        
        setupVisualEffectView()
        
        setupBottomButtonControls()
    }
    
    
    //讓圖片不要是正方形的
    fileprivate let extraSwipingHeight: CGFloat = 80
    
    //等等會發現swipingPhotosController跑版，原因是因為在ViewDidLoad中，scrollView還未生成
    //就把imageView加進去，造成swipingPhotosController無發抓到正確的位置
    //解法：應該要在viewWillLayoutSubview設定swipingPhotosController
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)

    }
    
    
    fileprivate func setupBottomButtonControls(){
        let stackView = UIStackView.init(arrangedSubviews: [dislikeButton, superlikeButton, likeButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    fileprivate func setupVisualEffectView(){
        let blurEffect = UIBlurEffect.init(style: .regular)
        let visualEffectView = UIVisualEffectView.init(effect: blurEffect)
        
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
    }
}


extension UserDetailController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        let width = max(view.frame.width + changeY * 2, view.frame.width)
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect.init(x: min(-changeY, 0) , y: min(-changeY, 0), width: width, height: width + extraSwipingHeight)
        
    }
}
