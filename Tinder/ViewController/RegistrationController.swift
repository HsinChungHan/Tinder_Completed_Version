//
//  RegistrationController.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/1.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class RegistrationController: UIViewController {

    var delegate: LoginControllerDelegate?
    
    //UI Component
    lazy var selectPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Select Photo", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.backgroundColor = UIColor.white
        btn.addTarget(self, action: #selector(handelSelectPhoto(sender:)), for: .touchUpInside)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16.0
        btn.heightAnchor.constraint(equalToConstant: 275).isActive = true
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }()
    
    @objc func handelSelectPhoto(sender: UIButton){
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        present(imgPickerController, animated: true, completion: nil)
        
    }
    
    let fullNameTextField: CustomTextField = {
       let tf = CustomTextField.init(padding: 24)
        tf.backgroundColor = .white
        tf.placeholder = "Enter full name..."
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)

        return tf
    }()
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField.init(padding: 24)
        tf.backgroundColor = .white
        tf.placeholder = "Enter email..."
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)

        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField.init(padding: 24)
        tf.backgroundColor = .white
        tf.placeholder = "Enter password..."
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)

        return tf
    }()
    
    @objc func handleTextChange(textField: UITextField){
        if textField == fullNameTextField{
            registrationViewModel.fullName = textField.text
        }else if textField == emailTextField{
            registrationViewModel.email = textField.text
        }else{
            registrationViewModel.password = textField.text
        }
    }
    
    lazy var registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        btn.addTarget(self, action: #selector(handleRegister(sender:)), for: .touchUpInside)
        btn.layer.cornerRadius = 25.0
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.backgroundColor = .lightGray
        btn.setTitleColor(.gray, for: .disabled)
        btn.isEnabled = false
        return btn
    }()
    
    let registeringHUB = JGProgressHUD.init(style: .dark)
    @objc func handleRegister(sender: UIButton){
        handleTapDismissKeyboard(gesture: nil)
        registrationViewModel.performRegistration {[unowned self] (error) in
            if let error = error{
                self.showHudWithError(error: error)
                return
            }
            print("Finished our user registering...")
            // Jump to HomeViewController
            self.dismiss(animated: true, completion: {
                self.delegate?.didFinishLogin()
            })
//            let homeViewController = HomeViewController()
//            self.present(homeViewController, animated: true, completion: nil)
        }
    }
    
    lazy var goToLoginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Go to Login", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        btn.addTarget(self, action: #selector(handleGoToLogin(sender:)), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleGoToLogin(sender: UIButton){
        let loginVC = LoginController()
        loginVC.delegate = delegate
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    let gradientLayer = CAGradientLayer()

    let registrationViewModel = RegistrationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        setupLayout()
        setupNotificationObserver()
        setupTapGesture()
        setupRegistrationViewModelObserver()
    }
    
    override func viewWillLayoutSubviews() {
        //can fetch current view's bound, whatever it's potrait or landscape
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass == .compact{
            overallStackView.axis = .horizontal
        }else{
            overallStackView.axis = .vertical
        }
    }
    
    //MARK:- Private
    fileprivate func setupRegistrationViewModelObserver(){
        registrationViewModel.bindableIsFormValid.bind { [unowned self] (isFormValid) in
            guard let isFormValid = isFormValid else {return}
            self.registerButton.isEnabled = isFormValid
            self.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8060349822, green: 0.03426375985, blue: 0.3326358795, alpha: 1) : .lightGray
            self.registerButton.setTitleColor(isFormValid ? .white : .lightGray, for: .normal)
        }
        
        registrationViewModel.bindableImage.bind { (image) in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        registrationViewModel.bindableIsRegistering.bind {[unowned self] (isRegistering) in
            guard let isRegistering = isRegistering else {return}
            if isRegistering{
                self.registeringHUB.textLabel.text = "Register..."
                self.registeringHUB.show(in: self.view)
            }else{
                self.registeringHUB.dismiss()
            }
        }
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 1, green: 0.3885170519, blue: 0.1416802406, alpha: 1)
        let bottomColor = #colorLiteral(red: 1, green: 0, blue: 0.6475832462, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.addSublayer(gradientLayer)
    }
    
    lazy var verticalStackView: UIStackView = {
        let sv =  UIStackView.init(arrangedSubviews: [
            fullNameTextField,
            emailTextField,
            passwordTextField,
            registerButton
            ])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8.0
        return sv
    }()
    
    
    lazy var overallStackView = UIStackView.init(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
        ])
    
    
    
    fileprivate func setupLayout(){
        navigationController?.navigationBar.isHidden = true

        view.addSubview(overallStackView)
        overallStackView.spacing = 8
        overallStackView.axis = .vertical
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 275).isActive = true
        overallStackView.anchor(top: nil, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50), size: .zero)
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(goToLoginButton)
        goToLoginButton.anchor(top: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
    }
    
    fileprivate func setupNotificationObserver(){
        //keyboard showing
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //keyboard hiding
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNotificationObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //beacuese NotificationCenter and observer both of them hold self
        super.viewWillDisappear(animated)
        //因為當我們從image picker回來的時候，會執行這個，造成我們的keyboard彈不出來
        NotificationCenter.default.removeObserver(self)//If you don't do it, u will have retain cycle
    }
    
    @objc func handelKeyboardWillShow(notification: Notification){
//        print("Keyboard will show...")
        //how to figure out how tall the keyboard actually is
        print(notification.userInfo)
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else{
            return
        }
        
        let keyboardFrame = value.cgRectValue
        //(x, y, width, height)
        print(keyboardFrame)
//        print(UIScreen.main.bounds.width)
        
        //let try to figure out how tall the gap is from the register button to the bottom of the screen
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        print(view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height)
        print(view.frame.height - overallStackView.frame.maxY)
        
        let additionalSpaing: CGFloat = 10.0
        let difference = keyboardFrame.height - bottomSpace + additionalSpaing
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {[weak self] in
            self?.view.transform = CGAffineTransform.init(translationX: 0, y: -difference)
        }, completion: nil)
    }
    
    @objc func handelKeyboardWillHide(){
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {[weak self] in
            self?.view.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    
    fileprivate func setupTapGesture(){
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapDismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapDismissKeyboard(gesture: UITapGestureRecognizer?){
        view.endEditing(true) //dismiss keyboard
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {[weak self] in
            self?.view.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    fileprivate func showHudWithError(error: Error){
        registeringHUB.dismiss()
        let hud = JGProgressHUD.init(style: .dark)
        hud.textLabel.text = "Faild registration!"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: view)
        hud.dismiss(afterDelay: 4, animated: true)
    }
}



extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        registrationViewModel.checkFormValidity()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
