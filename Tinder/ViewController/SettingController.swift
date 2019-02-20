//
//  SettingController.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2019/2/8.
//  Copyright © 2019 Chung Han Hsin. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingControllerDelegate {
    func didSaveSetting()
}


class CustomImagePickerController: UIImagePickerController{
    var imageButton: UIButton?
}


class SettingController: UITableViewController {

    var user: User?
    var delegate: SettingControllerDelegate?
    
    static let defaultMinSeekingAge = 18
    static let defaultMaxSeekingAge = 50
    static let defaultUserAge = 18
    
    func createButton(selector: Selector) -> UIButton{
        let button = UIButton.init(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10.0
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    @objc fileprivate func handleSelectPhoto(sender: UIButton){
        let imagePickerController = CustomImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageButton = sender
        present(imagePickerController, animated: true, completion: nil)
    }
    
    lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.addSubview(image1Button)
        
        let image1Padding = UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 0)
        image1Button.anchor(top: headerView.topAnchor, bottom: headerView.bottomAnchor, leading: headerView.leadingAnchor, trailing: nil, padding: image1Padding, size: .zero)
        image1Button.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView.init(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        
        headerView.addSubview(stackView)
        let stackViewPadding = UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16)
        stackView.anchor(top: headerView.topAnchor, bottom: headerView.bottomAnchor, leading: image1Button.trailingAnchor, trailing: headerView.trailingAnchor, padding: stackViewPadding, size: .zero)
        
        return headerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        tableView.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        Firestore.firestore().fetchCurrentUser { (user, error) in
            if let error = error {
                print("Failed to fetch user:", error)
                return
            }
            self.user = user
            self.loadUserPhotos()
            self.tableView.reloadData()
        }
    }
    
    fileprivate func loadUserPhotos(){
        if let imageUrlStr1 = user?.imageUrl1, let imgUrl = URL.init(string: imageUrlStr1) {
            //Why dexactly do we use this SDWebImageManager class to load images?
            //因為這會存到cache，讓你不用重新下載一次
            SDWebImageManager.shared().loadImage(with: imgUrl, options: .continueInBackground, progress: nil) { (image,
                _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrlStr2 = user?.imageUrl2, let imgUrl = URL.init(string: imageUrlStr2) {
            SDWebImageManager.shared().loadImage(with: imgUrl, options: .continueInBackground, progress: nil) { (image,
                _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrlStr3 = user?.imageUrl3, let imgUrl = URL.init(string: imageUrlStr3) {
            SDWebImageManager.shared().loadImage(with: imgUrl, options: .continueInBackground, progress: nil) { (image,
                _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
    }
    
    class HeaderLabel: UILabel {
        override func draw(_ rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return headerView
        }
        let headerLabel = HeaderLabel()
        var text = ""
        switch section {
        case 1:
            text = "Name"
        case 2:
            text = "Profession"
        case 3:
            text = "Age"
        case 4:
            text = "Bio"
        default:
            text = "Seeking Age Range"
        }
        headerLabel.text = text
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 300 : 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingCell.init(style: .default, reuseIdentifier: nil)
        var placeHolder = ""
        var text: String?
        if indexPath.section == 5{
            let ageRangeCell = AgeRangeCell.init(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            let minAge = user?.minSeekingAge ?? SettingController.defaultMinSeekingAge
            let maxAge = user?.maxSeekingAge ?? SettingController.defaultMaxSeekingAge
            ageRangeCell.minLabel.text = "Min \(minAge)"
            ageRangeCell.maxLabel.text = "Max \(maxAge)"
            ageRangeCell.minSlider.value = Float(minAge)
            ageRangeCell.maxSlider.value = Float(maxAge)
            print("\(ageRangeCell.minLabel.text)")
            print("\(ageRangeCell.maxLabel.text)")
            return ageRangeCell
        }
        
        switch indexPath.section {
        case 1:
            placeHolder = "Enter Name"
            text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            placeHolder = "Enter Profession"
            text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            placeHolder = "Enter Age"
            if let age = user?.age{
                text = String(age)
            }
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
        default:
            placeHolder = "Enter Bio"
        }
        cell.textField.placeholder = placeHolder
        cell.textField.text = text
        return cell
    }
    
    @objc fileprivate func handleMinAgeChange(slider: UISlider){
//        print(slider.value)
//        //wanna to update minLabel in my AgeRangeCell...
//        let ageRangeCellIndexPath = IndexPath.init(row: 0, section: 5)
//        let ageRangeCell = tableView.cellForRow(at: ageRangeCellIndexPath) as! AgeRangeCell
//        ageRangeCell.minLabel.text = "Min \(Int(slider.value))"
//        user?.minSeekingAge = Int(slider.value)
        evaluateMinMax()
    }
    
    @objc fileprivate func handleMaxAgeChange(slider: UISlider){
//        print(slider.value)
//        let ageRangeCellIndexPath = IndexPath.init(row: 0, section: 5)
//        let ageRangeCell = tableView.cellForRow(at: ageRangeCellIndexPath) as! AgeRangeCell
//        ageRangeCell.maxLabel.text = "Max \(Int(slider.value))"
//        user?.maxSeekingAge = Int(slider.value)
//
        evaluateMinMax()
    }
    
    fileprivate func evaluateMinMax() {
        //[5, 0]: section = 5, row = 0
        guard let ageRangeCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 5)) as? AgeRangeCell else { return }
        let minValue = Int(ageRangeCell.minSlider.value)
        var maxValue = Int(ageRangeCell.maxSlider.value)
        maxValue = max(minValue, maxValue)
        ageRangeCell.maxSlider.value = Float(maxValue)
        ageRangeCell.minLabel.text = "Min \(minValue)"
        ageRangeCell.maxLabel.text = "Max \(maxValue)"
        
        user?.minSeekingAge = minValue
        user?.maxSeekingAge = maxValue
    }
    
    
    @objc fileprivate func handleNameChange(textField: UITextField){
        user?.name = textField.text ?? ""
    }
    
    @objc fileprivate func handleProfessionChange(textField: UITextField){
        user?.profession = textField.text ?? ""
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField){
        user?.age = Int(textField.text ?? "")
    }
    
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(handelCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(handelLogout)),
            UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(handelSave))
        ]
    }
    
    @objc fileprivate func handelCancel(sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handelSave(sender: UIBarButtonItem){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData: [String : Any] = [
            "uid" : uid,
            "fullName" : user?.name ?? "",
            "imageUrl1" : user?.imageUrl1 ?? "",
            "imageUrl2" : user?.imageUrl2 ?? "",
            "imageUrl3" : user?.imageUrl3 ?? "",
            "age" : user?.age ?? -1,
            "profession" : user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? SettingController.defaultMinSeekingAge,
            "maxSeekingAge": user?.maxSeekingAge ?? SettingController.defaultMaxSeekingAge
        ]
        
        let hud = JGProgressHUD.init(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        Firestore.firestore().collection("users").document(uid).setData(docData){[unowned self] (error) in
            hud.dismiss()
            if let error = error{
                print(error)
                return
            }
            print("Finish saving user info.")
            
            self.dismiss(animated: true){[unowned self] in
                //I want to refresh my card inside of HomeVC somehow
                self.delegate?.didSaveSetting()
            }
        }
    }
    
    @objc fileprivate func handelLogout(sender: UIBarButtonItem){
        try? Auth.auth().signOut()
        dismiss(animated: true)
    }
    
}


extension SettingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        //how do i set image on my button when i selecto photo
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
        
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(fileName)")
        let hud = JGProgressHUD.init(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else {return}
        ref.putData(uploadData, metadata: nil) { (_, error) in
            
            if let error = error{
                hud.dismiss()
                print(error.localizedDescription)
                return
            }
            print("Finished upload image!")
            ref.downloadURL(completion: { [unowned self](url, error) in
                hud.dismiss()
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                switch imageButton{
                case self.image1Button:
                    self.user?.imageUrl1 = url?.absoluteString
                case self.image2Button:
                    self.user?.imageUrl2 = url?.absoluteString
                default:
                    self.user?.imageUrl3 = url?.absoluteString
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
