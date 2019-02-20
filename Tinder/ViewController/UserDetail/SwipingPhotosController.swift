//
//  SwipingPhotosController.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/18.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
import SDWebImage

class SwipingPhotosController: UIPageViewController {
    var cardViewModel: CardViewModel!{
        didSet{
            controllers = cardViewModel.imageUrls.map({ (urlStr) -> PhotoController in
                let photoController = PhotoController.init(imageUrlStr: urlStr)
                return photoController
            })
            //這邊的controllers參數很怪，只可傳一個controller進去
            setViewControllers([controllers.first!], direction: .forward, animated: false, completion: nil)
            
            setupBarView()
        }
    }
    
    fileprivate let barsStackView = UIStackView.init(arrangedSubviews: [])
    fileprivate let deselectedBarColor = UIColor.init(white: 0, alpha: 0.1)
    
    var controllers = [PhotoController]()
//    let controllers = [
//        PhotoController.init(image: #imageLiteral(resourceName: "lady2-e")),
//        PhotoController.init(image: #imageLiteral(resourceName: "dismiss_down_arrow")),
//        PhotoController.init(image: #imageLiteral(resourceName: "lady2-a")),
//        PhotoController.init(image: #imageLiteral(resourceName: "lady1-a")),
//        PhotoController.init(image: #imageLiteral(resourceName: "lady2-e"))
//    ]
    
    fileprivate let isCardViewMode: Bool
    init(isCardViewMode: Bool = false){
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        
        if isCardViewMode{
            disableSwipingAbility()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer){
        let currentController = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentController as! PhotoController){
            barsStackView.arrangedSubviews.forEach { (view) in
                view.backgroundColor = deselectedBarColor
            }
            if gesture.location(in: view).x > view.frame.width/2{
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false, completion: nil)
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            }else{
                let previousIndex = max(index - 1, 0)
                let nextController = controllers[previousIndex]
                setViewControllers([nextController], direction: .forward, animated: false, completion: nil)
                barsStackView.arrangedSubviews[previousIndex].backgroundColor = .white
            }
            
            
        }
        
    }
    
    fileprivate func disableSwipingAbility(){
        view.subviews.forEach { (view) in
            if let view = view as? UIScrollView{
                view.isScrollEnabled = false
            }
        }
    }
    
    fileprivate func setupBarView(){
        cardViewModel.imageUrls.forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = .white
            barView.layer.cornerRadius = 2
            barView.backgroundColor = deselectedBarColor
            barsStackView.addArrangedSubview(barView)
        }
        
        if cardViewModel.imageUrls.count > 1{
            view.addSubview(barsStackView)
            barsStackView.axis = .horizontal
            barsStackView.spacing = 4
            barsStackView.distribution = .fillEqually
            //先預設第一個bar的顏色為白色
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            //用view.safeAreaLayoutGuide.topAnchor會因為我們的SwipingPhotoController會縮放，造成barstackViews的閃爍(會一直重新調整其位置)
            //所以我們可以給他一個固定的padding來解這個問題
            //        barsStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8), size: CGSize.init(width: 0, height: 4))
            var paddingTop: CGFloat = 8
            if !isCardViewMode{
                paddingTop += UIApplication.shared.statusBarFrame.height
            }
            barsStackView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 8, right: 8), size: .init(width: 0, height: 4))
        }
        
    }
    
}


extension SwipingPhotosController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //會回傳目前的controller在controllers中的index
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0{
            return nil
        }
        
        return controllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1{
            return nil
        }
        return controllers[index + 1]

    }
}

extension SwipingPhotosController: UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: { (controller) -> Bool in controller == currentPhotoController}){
            barsStackView.arrangedSubviews.forEach { (view) in
                view.backgroundColor = deselectedBarColor
            }
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
        
        print("Page transition complete!")
    }
}








