//
//  CardView.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/21.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didPressMoreInfoButton(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}

class CardView: UIView {
    
    var nextCardView: CardView?
    
    
    var delegate: CardViewDelegate?
    
    var cardViewModel: CardViewModel!{
        didSet{
            //accessing index 0 will crash, if images.count == 0
//            let imageName = cardViewModel.imageUrls.first ?? ""
//            imageView.image = UIImage.init(named: imageName)
            //load our image using url instead of image name
//            if let imageUrl = URL.init(string: imageName){
//                imageView.sd_setImage(with: imageUrl)
                
//                imageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "photo_placeholder"), options: .continueInBackground)
//            }
            
            swipingPhotoController.cardViewModel = cardViewModel

            informationLabel.textAlignment = cardViewModel.textAlignment
            informationLabel.attributedText = cardViewModel.attributedString
            
            //some dummy bars for now
            (0..<cardViewModel.imageUrls.count).forEach { (_) in
                let view = UIView()
                view.backgroundColor = barDeselectedColor
                barStackView.addArrangedSubview(view)
            }
            
            barStackView.arrangedSubviews.first?.backgroundColor = UIColor.white
            setupImageIndexObserver()
        }
    }
    
    fileprivate func setupImageIndexObserver(){
        cardViewModel.imageIndexObserver = {[unowned self] (imageUrl, imageIndex) in
//            self?.imageView.image = image
//            self.imageView.sd_setImage(with: imageUrl)
//            self.imageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "photo_placeholder"), options: .continueInBackground, completed: nil)
            
            self.barStackView.arrangedSubviews.forEach {(subview) in
                subview.backgroundColor = self.barDeselectedColor
            }
            self.barStackView.arrangedSubviews[imageIndex].backgroundColor = UIColor.white
        }
    }
    
    fileprivate let gradientLayer = CAGradientLayer()

    
    public func setupViewModel(viewModel: CardViewModel){
        cardViewModel = viewModel
    }
    

    //MARK:- Configuration
    let threhold: CGFloat = 100
    
//    fileprivate let imageView: UIImageView = {
//        let imv = UIImageView.init(image: #imageLiteral(resourceName: "lady2-a"))
//        imv.contentMode = .scaleAspectFill
//        imv.clipsToBounds = true
//        return imv
//    }()
    //Replace it with a UIPageViewController component which is our SwipingPhotoViewController
    fileprivate let swipingPhotoController = SwipingPhotosController.init(isCardViewMode: true)
    
    fileprivate let informationLabel: UILabel = {
        let lb = UILabel()
        lb.text = "TEST NAME TEST PROFESSION TEST AGE"
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        lb.numberOfLines = 0
        return lb
    }()
    
    
    //    fileprivate let imageView: UIImageView = {
    //        let imv = UIImageView.init(image: #imageLiteral(resourceName: "girl"))
    //        imv.contentMode = .scaleAspectFill
    //        imv.clipsToBounds = true
    //        return imv
    //    }()
    
    lazy var moreInfoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handlePressMoreInfo(sender:)), for: .touchUpInside)
        return btn
    }()
    
    @objc func handlePressMoreInfo(sender: UIButton){
        //present function is missing here
        //hack solution
//        let homeVC = UIApplication.shared.keyWindow?.rootViewController
//        let userDetailController = UserDetailController()
//        homeVC?.present(userDetailController, animated: true, completion: nil)
        
        //delegate solution
        delegate?.didPressMoreInfoButton(cardViewModel: cardViewModel)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()

        setupPanGesture()
        
        setupTapGesture()
    }
    
    
    fileprivate func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }
    
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handledChanged(gesture)
        case .ended:
            handledEnded(gesture)
        default:
            ()
        }
        
    }
    
    fileprivate func setupTapGesture(){
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        addGestureRecognizer(gesture)
    }
    
    var imageImdex = 0
    fileprivate let barDeselectedColor = UIColor.init(white: 0, alpha: 0.1)
    
    @objc func handleTap(gesture: UITapGestureRecognizer){
        print("Handling tap and cycling photos!")
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width/2 ? true : false
        if shouldAdvanceNextPhoto{
            cardViewModel.advanceToNextPhoto()
        }else{
            cardViewModel.goToPreviousPgoto()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    fileprivate func setupLayout(){
        //custom drawing code
        layer.cornerRadius = 10.0
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotoController.view!
        
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperView()

        //setup Bar StackView
//        setupBarStackView()
        
        //add gradient layer
        setupGradientLayer()
        

        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16), size: .zero)
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, bottom: bottomAnchor, leading: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
        
    }
    
    fileprivate func setupGradientLayer(){
        // how we can draw a gradient with swfit
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        //self.frame is a zero frame during init stage
        //this is a way or overide layout subView
//        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layer.addSublayer(gradientLayer)
    }
    
    fileprivate let barStackView = UIStackView()
    
    fileprivate func setupBarStackView(){
        addSubview(barStackView)
        barStackView.anchor(top: topAnchor, bottom: nil, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
        
    }
    
    override func layoutSubviews() {
        //In here you know what your cardView's frame will be
        gradientLayer.frame = frame
    }
    
    fileprivate func handledEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissedCard = abs(gesture.translation(in: nil).x) > threhold
        //        let shouldDismissedCard = gesture.translation(in: nil).x > threhold
        
        //hack solution:存取homeVC的like或dislike function
        if shouldDismissedCard{
            guard let homeVC = delegate as? HomeViewController else {return}
            if translationDirection == 1{
                homeVC.handleLike()
            }else{
                homeVC.handleDislike()
            }
        }else{
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {[unowned self] in
                self.transform = .identity
            })
        }
       
        
        
        
        
        
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {[unowned self] in
//            if shouldDismissedCard{
//                //這樣的寫法會有一點不好，他卡片在飛出去的時候，會往上跳一下(jumping Affect)
//                //                let offSecreenTransform = self?.transform.translatedBy(x: 1000, y: 0)
//                //                self?.transform = offSecreenTransform!
//
//                self.frame = CGRect.init(x: 600 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
//            }else{
//                self.transform = .identity
//            }
//        }) { (completed) in
//            self.transform = .identity
//            //在拖拉的過程時，frame的寬高會改變，所以需要用superView的寬高
//            //                self?.frame = CGRect.init(x: 0, y: 0, width: (self?.superview?.frame.width)! , height: (self?.superview?.frame.height)!)
//            if shouldDismissedCard{
//                self.removeFromSuperview()
//
//                //reset topCarView inside of HomeViewController somehow
//                self.delegate?.didRemoveCard(cardView: self)
//            }
//        }
    }
    
    fileprivate func handledChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        //此處的15是radians弧度，要改成degrees
        //convert degrees to radians
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        let rotationTransformation = CGAffineTransform.init(rotationAngle: angle)
        transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
        //        transform = CGAffineTransform.init(translationX: translation.x, y: translation.y)
    }
}
