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
            swipingPhotoController.cardViewModel = cardViewModel

            informationLabel.textAlignment = cardViewModel.textAlignment
            informationLabel.attributedText = cardViewModel.attributedString
            
            //some dummy bars for now
//            (0..<cardViewModel.imageUrls.count).forEach { (_) in
//                let view = UIView()
//                view.backgroundColor = barDeselectedColor
//                barStackView.addArrangedSubview(view)
//            }
//            barStackView.arrangedSubviews.first?.backgroundColor = UIColor.white
            setupImageIndexObserver()
            
            
        }
    }
    
    fileprivate func setupImageIndexObserver(){
        cardViewModel.imageIndexObserver = {[unowned self] (imageUrl, imageIndex) in
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
    
    lazy var moreInfoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handlePressMoreInfo(sender:)), for: .touchUpInside)
        return btn
    }()
    
    @objc func handlePressMoreInfo(sender: UIButton){
        //delegate solution
        delegate?.didPressMoreInfoButton(cardViewModel: cardViewModel)
        
    }
    
    let likeImageView: UIImageView = {
       let imv = UIImageView.init(image: #imageLiteral(resourceName: "like"))
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.alpha = 0
        return imv
    }()
    
    let nopeImageView: UIImageView = {
        let imv = UIImageView.init(image: #imageLiteral(resourceName: "nope"))
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.alpha = 0
        return imv
    }()
    
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
        
        addSubview(likeImageView)
        likeImageView.anchor(top: topAnchor, bottom: nil, leading: leadingAnchor, trailing: nil, padding: .init(top: 16, left: 16, bottom: 0, right: 0), size: .init(width: 130, height: 130))
        
        addSubview(nopeImageView)
        nopeImageView.anchor(top: topAnchor, bottom: nil, leading: nil, trailing: trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 16), size: .init(width: 150, height: 150))
        
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
        if cardViewModel.imageUrls.count > 1{
            addSubview(barStackView)
            barStackView.anchor(top: topAnchor, bottom: nil, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
            barStackView.spacing = 4
            barStackView.distribution = .fillEqually
        }
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
                self.nopeImageView.alpha = 0.0
                self.likeImageView.alpha = 0.0
                self.transform = .identity
            })
        }
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
        
        print("translation: \(translation.x/frame.width * 3)")
        if translation.x > 0{
            likeImageView.alpha = translation.x/frame.width * 3
        }else{
            nopeImageView.alpha = -translation.x/frame.width * 3
        }
        
    }
}
