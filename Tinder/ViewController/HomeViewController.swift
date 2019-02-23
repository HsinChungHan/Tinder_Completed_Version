//
//  MainViewController.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/1/19.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeViewController: UIViewController {
    let topStackView = TopNavigationStackView()
    
    let cardsDeckView = UIView()
    let bottomControlsStackView = HomeBottomStackView()
    
    var cardViewModels = [CardViewModel]()
    fileprivate var lastFetchUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //access topStackView's setting button
        topStackView.settingButton.addTarget(self, action: #selector(handleSetting), for: .touchUpInside)
        
        bottomControlsStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControlsStackView.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControlsStackView.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        setupLayout()
        fetchCurrentUser()
        
        
        
        
//        setupFirestoreUserCards()
//        fetchUserFromFirestore()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //you want to kick urser out when they log out
        print(Auth.auth().currentUser?.uid)
        if Auth.auth().currentUser == nil{
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            present(navController, animated: true)
            
        }
    }
    
    
    @objc func handleRefresh(sender: UIButton){
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
//        fetchUserFromFirestore()
        fetchSwipes()
    }
    
    @objc func handleSetting(sender: UIButton){
        let settingVC = SettingController()
        settingVC.delegate = self
        let naviController = UINavigationController.init(rootViewController: settingVC)
        present(naviController, animated: true, completion: nil)
    }
    
    
    
    //MARK:- FilePrivate
    fileprivate func setupLayout(){
        let overallStackView = UIStackView.init(arrangedSubviews: [topStackView, cardsDeckView, bottomControlsStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 8, bottom: 0, right: 8)
        
        //讓我的cardView永遠都在stackView之上
        overallStackView.bringSubviewToFront(cardsDeckView)
        
    }
    
    
    var user: User?
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate func fetchCurrentUser(){
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        //fetch user from Firstore
        Firestore.firestore().fetchCurrentUser { [unowned self](user, error) in
            self.hud.dismiss()
            if let error = error{
                print("Failed to fetch current user: ", error.localizedDescription)
                return
            }
            self.user = user
            self.fetchSwipes()
            
//            self.fetchUserFromFirestore()
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes(){
        guard let uid = Auth.auth().currentUser?.uid else {return}

        Firestore.firestore().collection("swipes").document(uid).getDocument { [unowned self
            ](snapshot, err) in
            if let err = err {
                print("failed to fetch swipes info for currently logged in user:", err)
                return
            }
            
            print("Swipes:", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else {
                return
            }
            self.swipes = data
            self.fetchUserFromFirestore()
        }
        
    }
    
    
    fileprivate func setupFirestoreUserCards(){
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView.init(frame: .zero)
            cardView.setupViewModel(viewModel: cardVM)
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperView()
        }
    }
    
    
    
    fileprivate func fetchUserFromFirestore(){
        
        let minAge = user?.minSeekingAge ?? SettingController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingController.defaultMaxSeekingAge
        
        let hud = JGProgressHUD.init(style: .dark)
        hud.textLabel.text = "Tap Refresh to Fetch Users"
        hud.show(in: view)
        
        //I am gonna introduce pagination here to page through 2 users at one time
//        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchUser?.uid ?? ""]).limit(to: 2)
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        topCardView = nil
        query.getDocuments {[unowned self] (snapshot, error) in
            hud.dismiss()
            if let error = error{
                print("Failed to fetch user: \(error.localizedDescription)")
                return
            }
            
            //we are going to set up the nextCardView relationship for all cards somehow?
            
            //Linked List
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({[unowned self] (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User.init(dictionary: userDictionary)
                
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                var hasNotSwipedBefore = self.swipes[user.uid] == nil
                
                //方便我們實作之後的動畫，先設定hasNotSwipedBefore為true
                hasNotSwipedBefore = true
                if isNotCurrentUser && hasNotSwipedBefore {
                     let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView

                    if self.topCardView == nil{
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    var topCardView: CardView?
    
    fileprivate func performSwipAnimation(translation: CGFloat, angle: CGFloat) {
        //        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {[unowned self] in
        //            self.topCardView!.frame = CGRect.init(x: 600 , y: 0, width: self.topCardView!.frame.width, height: self.topCardView!.frame.height)
        //            let angle = 15*CGFloat.pi/180
        //            self.topCardView?.transform = CGAffineTransform.init(rotationAngle: angle)
        //        }) { (_) in
        //            self.topCardView?.removeFromSuperview()
        //            self.topCardView = self.topCardView?.nextCardView
        //        }
        
        //用CABasicAnimation的方式做動畫，不會讓你的mainThread阻塞
        //用UIView.animate()的方式去做，會造成你的button如果快速點擊的話
        //動畫會不見
        let translationAnimation = CABasicAnimation.init(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = 0.5
        //讓topCardView不會回到原位
        translationAnimation.fillMode = .forwards
        //讓你的讓你的animation不會被移除
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
//        rotationAnimation.toValue = 15
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = 0.5
        
        //當animation做完後，執行completion block裡面的動作
        //這一段code是動畫流暢與否的關鍵
        //新增一個區域變數cardView
        //要移出也針對這個cardView去做
        //並對這個cardView的layer層加上animation
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        CATransaction.commit()
    }
    
    @objc func handleLike(){
        topCardView?.likeImageView.alpha = 1.0
        saveSwipeToFireStore(didLike: 1)
        performSwipAnimation(translation: 700, angle: 15)
    }
    
    fileprivate func saveSwipeToFireStore(didLike: Int){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        guard let cardUid = topCardView?.cardViewModel.uid else {return}
        let documentData = [
            cardUid : didLike
        ]
        
        
        //updateData不會覆寫(但一定要確保有swipe這一個collection在firebase中)
        //可用getDocument來確保
        Firestore.firestore().collection("swipes").document(uid).getDocument { [unowned self](snapshot, error) in
            if let error = error{
                print("Failed to fetch swipes document from firebase: \(error)")
                return
            }
            
            //如果swipes/uid這個document是存在的
            if snapshot?.exists == true{
                //用update的方式，不要去覆寫原本的資料
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) {[unowned self] (error) in
                    if let error = error{
                        print("Failed to save swiped data in Firebase: \(error)")
                        return
                    }
                    print("Successfully updated swipe...")
                    if didLike == 1{
                        self.checkIfMatchExists(cardUid: cardUid)
                    }
                }
            }else{
                //否則新創一個swipes/uid document
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) {[unowned self] (error) in
                    if let error = error{
                        print("Failed to save swiped data in Firebase: \(error)")
                        return
                    }
                    if didLike == 1{
                        self.checkIfMatchExists(cardUid: cardUid)
                    }
                }
            }
        }
        
       
    }
    
    fileprivate func checkIfMatchExists(cardUid: String){
        //How to detect our match between two users

        //先檢查我們選取的卡片中有關我們id的欄位所存取的值
        //如果是1代表對方也喜歡我們
        //如果是0代表對方討厭我們
        Firestore.firestore().collection("swipes").document(cardUid).getDocument { (snapshot, error) in
            if let error = error{
                print("Failed to fetch document for card user: \(error)")
                return
            }
            guard let data = snapshot?.data() else {return}
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched{
                self.presentMatchedView(cardUID: cardUid, currentUser: self.user!)
            }
        }
    }
    
    fileprivate func presentMatchedView(cardUID: String, currentUser: User){
        let matchedView = MatchedView.init(frame: .zero)
        matchedView.cardUid = cardUID
        matchedView.currentUser = currentUser
        view.addSubview(matchedView)
        matchedView.fillSuperView()
    }
    
    
    @objc func handleDislike(){
        topCardView?.nopeImageView.alpha = 1.0
        saveSwipeToFireStore(didLike: 0)
        performSwipAnimation(translation: -700, angle: -15)

    }
    
    @discardableResult
    fileprivate func setupCardFromUser(user: User) -> CardView{
        let cardView = CardView.init(frame: .zero)
        cardView.setupViewModel(viewModel: user.toCardViewModel())
        cardsDeckView.addSubview(cardView)
        //Inorder to avoid card flickering
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperView()
        cardView.delegate = self
        return cardView

    }
}

extension HomeViewController: SettingControllerDelegate{
    func didSaveSetting() {
        fetchCurrentUser()
    }
    
    
}
extension HomeViewController: LoginControllerDelegate{
    func didFinishLogin() {
        fetchCurrentUser()
    }
}

extension HomeViewController: CardViewDelegate{
    func didRemoveCard(cardView: CardView) {
        topCardView?.removeFromSuperview()
        topCardView = cardView.nextCardView
    }
    
    func didPressMoreInfoButton(cardViewModel: CardViewModel) {
        let userDetailVC = UserDetailController()
        userDetailVC.delegate = self
        userDetailVC.cardViewModel = cardViewModel
        present(userDetailVC, animated: true, completion: nil)
    }
    
    
}


extension HomeViewController: UserDetailControllerDelegate{
    func nope(userDetailController: UserDetailController) {
        userDetailController.dismiss(animated: true) {
            self.handleDislike()
        }
    }
    
    func like(userDetailController: UserDetailController) {
        userDetailController.dismiss(animated: true) {
            self.handleLike()
        }
    }
    
}




