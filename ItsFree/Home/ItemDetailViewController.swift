//
//  ItemDetailViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-22.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseStorage
import Money
import Forex

class ItemDetailViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var starImageView: UIView!
    var detailViewTopAnchorConstant: CGFloat!
    var detailViewBottomAnchorConstant: CGFloat!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var itemDetailView: ItemDetailView!

    var poster: User?
    weak var currentItem: Item!
    let storageRef = Storage.storage().reference()
  
    var kindOfItem: String!

    var mainImageTapRecognizer: UITapGestureRecognizer!
    
    var itemActionDelegate: ItemActionDelegate!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
    
        setupCollectionView()
        setupItemDetailContainer()
        setupItemLabels()
        setupGestures()
        setupStar()
        
        self.itemDetailView.messageButton.isEnabled = false
        
        ReadFirebaseData.readUserBasics(userUID: currentItem.posterUID, completion: {(success, user) in
            if (success){
                
                self.poster = user
                
                self.itemDetailView.messageButton.isEnabled = true
                self.itemDetailView.posterUsername.text = user!.name
                self.itemDetailView.posterRating.text = "\(user!.rating)"
                
            }
            else {
                
                self.itemDetailView.messageButton.isEnabled = false
                Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Oops", inpMessage: "The poster seems to have left the app", inpOkTitle: "Ok")
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupStar() {
        let star = UIImageView(frame: starImageView.bounds)
        star.image = UIImage(named: "filledStar")
        star.tintColor = .white
        
        starImageView.addSubview(star)
        
//        star.leadingAnchor.constraint(equalTo: starImageView.leadingAnchor).isActive = true
//        star.trailingAnchor.constraint(equalTo: starImageView.trailingAnchor).isActive = true
//        star.topAnchor.constraint(equalTo: starImageView.topAnchor).isActive = true
//        star.bottomAnchor.constraint(equalTo: starImageView.bottomAnchor).isActive = true
        
        star.contentMode = .scaleAspectFit
        
    }

    func setupItemDetailContainer(){
        
        itemDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        let x = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.categoryLabel.frame.maxY))
        
        detailViewTopAnchorConstant = x - (44 + (UIApplication.shared.statusBarFrame.size.height)) - 20
        
        detailViewBottomAnchorConstant = 0
        
        NSLayoutConstraint.activate([
            itemDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            itemDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            itemDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: detailViewTopAnchorConstant),
            itemDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: detailViewBottomAnchorConstant)
            ])
        
        itemDetailView.alpha = 1
        itemDetailView.layer.cornerRadius = 30
        itemDetailView.layer.borderWidth = 5
        itemDetailView.layer.borderColor = UIColor.black.cgColor
        itemDetailView.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: itemDetailView.frame.height)
        gradient.colors = [UIProperties.sharedUIProperties.purpleColour.cgColor, UIColor.purple.cgColor]
        gradient.opacity = 1
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        itemDetailView.layer.insertSublayer(gradient, at: 0)
    }
    
    func setupGestures(){
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        itemDetailView.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        itemDetailView.addGestureRecognizer(swipeDown)
        
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutside))
        
        tapOutside.delegate = self
        self.view.addGestureRecognizer(tapOutside)
    }
    
    
    func setupItemLabels(){
        
        let previewPhotoRef: String = currentItem.photos[0]
        
        itemDetailView.itemTitleLabel.text = currentItem.name
        itemDetailView.categoryLabel.text = currentItem.itemCategory.rawValue
        itemDetailView.qualityLabel.text = currentItem.quality.rawValue
        itemDetailView.descriptionLabel.text = currentItem.itemDescription
        
        itemDetailView.mainImageView.isUserInteractionEnabled = true
        mainImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mainImageTapped))
        itemDetailView.mainImageView.addGestureRecognizer(mainImageTapRecognizer)
        itemDetailView.mainImageView.layer.borderColor = UIColor.black.cgColor
        itemDetailView.mainImageView.layer.borderWidth = 5
        itemDetailView.mainImageView.layer.cornerRadius = 5
        itemDetailView.mainImageView.sd_setImage(with: storageRef.child(previewPhotoRef), placeholderImage: UIImage.init(named: "placeholder"))
        
        itemDetailView.posterUsername.text = "Loading ..."
        itemDetailView.posterRating.text = "0"
        
    
        if (kindOfItem == "Offer"){
            //let value: CAD = (CAD(currentItem!.value))
            let value = Money(integerLiteral: currentItem.value)
            let locale = NSLocale.current

            
//            Forex.shared.rate(value: value, from: .CAD, to: CurrencyType()) { (exchange, error) in
//                print("Name:(exchange?.currency.description) Rate: (exchange?.value)")
//            }
            
              itemDetailView.itemValueLabel.text = "\(value)"
         

        }
        else if (kindOfItem == "Request"){
            itemDetailView.itemValueLabel.text = ""
        }
    }
    
    @objc func mainImageTapped(recognizer: UITapGestureRecognizer) {
        itemActionDelegate.fullscreenImage(imagePath: currentItem.photos[0], imageView: itemDetailView.mainImageView, inpVC: self)
    }
    
    func setupCollectionView(){
        
        itemDetailView.photoCollectionView.frame.size.height =  UIScreen.main.bounds.size.height/9
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemDetailView.photoCollectionView.frame.height, height: itemDetailView.photoCollectionView.frame.height)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing =  10
    
        itemDetailView.photoCollectionView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        
        itemDetailView.photoCollectionView.contentInsetAdjustmentBehavior = .never
        itemDetailView.photoCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        
        itemDetailView.photoCollectionView.setContentOffset(CGPoint(), animated: true)
        itemDetailView.photoCollectionView.delegate = self
        itemDetailView.photoCollectionView.dataSource = self
        
        itemDetailView.photoCollectionView.backgroundColor = .clear
        itemDetailView.photoCollectionView.isUserInteractionEnabled = true
        
        let nibName = UINib(nibName: "ItemPhotoCollectionViewCell", bundle:nil)
        itemDetailView.photoCollectionView.register(nibName, forCellWithReuseIdentifier: "itemPhotoCollectionViewCell")
        
        //itemDetailView.photoCollectionView.backgroundColor = UIProperties.sharedUIProperties.purpleColour
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (self.itemDetailView.photoCollectionView.bounds.contains(touch.location(in: self.itemDetailView.photoCollectionView))) {

            return false
        }
        
        else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let viewWidth = CGFloat(itemDetailView.photoCollectionView.frame.width * 1)
        let totalCellWidth = (itemDetailView.photoCollectionView.frame.size.height-30) * CGFloat(currentItem.photos.count);
        let totalSpacingWidth = 10 * CGFloat(currentItem.photos.count - 1);
        
        let leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
        let rightInset = leftInset;
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: itemDetailView.photoCollectionView.frame.size.height-30, height: itemDetailView.photoCollectionView.frame.size.height-30);
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        let photoRef: [String] = currentItem.photos
        return photoRef.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemPhotoCollectionViewCell", for: indexPath) as! ItemPhotoCollectionViewCell
        
        let photoRef: [String] = currentItem.photos
    
        cell.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        cell.layer.borderWidth = 5.0
        cell.layer.cornerRadius = 5.0
   
        cell.collectionViewImageVew.sd_setImage(with: storageRef.child(photoRef[indexPath.item]), placeholderImage: UIImage.init(named: "placeholder"))

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoRef: [String] = currentItem.photos
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemPhotoCollectionViewCell {
            if let imageView = cell.collectionViewImageVew {
            
            itemActionDelegate.fullscreenImage(imagePath: photoRef[indexPath.item], imageView: imageView, inpVC: self)
            }
        }
    }
    
    //When screen is tapped outside the itemDetailView, go back to Map
    @objc func tappedOutside(gesture: UIGestureRecognizer){
        if (gesture.location(in: view).y < detailViewTopAnchorConstant) {
            self.view.removeGestureRecognizer(gesture)
            self.navigationController?.navigationBar.removeGestureRecognizer(gesture)
            self.willMove(toParentViewController: nil)
            let theParentViewController = self.parent as! HomeViewController
            theParentViewController.itemDetailContainerView.removeFromSuperview()
            theParentViewController.homeMapView.deselectAnnotation(currentItem, animated: true)
            self.removeFromParentViewController()
        }
    }

    
    @objc func swipe(gesture: UIGestureRecognizer) {
        
        let topOfFullViewFrame = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.photoCollectionView.frame.maxY)) - (44 + (UIApplication.shared.statusBarFrame.size.height))
        
        let previewContentHeight = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.categoryLabel.frame.maxY))
        
        let topOfPreviewFrame = previewContentHeight - (44 + (UIApplication.shared.statusBarFrame.size.height)) - 20
        
        
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if (swipeGesture.direction == UISwipeGestureRecognizerDirection.down) {
                
                if (self.itemDetailView.frame.minY == topOfFullViewFrame){
                    
                    detailViewTopAnchorConstant = topOfPreviewFrame
                    
            
                    UIView.animate(withDuration: 0.5, animations: {
                        self.itemDetailView.frame = CGRect(x: 0, y: self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        
                        
                        
                        self.itemDetailView.leftUpArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi*2))
                        self.itemDetailView.rightUpArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * -0.9999*2))
                        
                    }, completion: {(finished: Bool) in
                    })
                    
                }
                
                else if (self.itemDetailView.frame.minY == topOfPreviewFrame){
 
                    UIView.animate(withDuration: 0.5, animations: {
                        self.itemDetailView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        
                       
                        
                    }, completion: {(finished: Bool) in
                        
                        self.willMove(toParentViewController: nil)
                        let theParentViewController = self.parent as! HomeViewController
                        theParentViewController.itemDetailContainerView.removeFromSuperview()
                        theParentViewController.homeMapView.deselectAnnotation(self.currentItem, animated: true)
                        
                        self.removeFromParentViewController()
                        
                    })
                }
                
            } else if (swipeGesture.direction == UISwipeGestureRecognizerDirection.up) {
            
                //this constant allows all details to be shown, and no empty space
                
                detailViewTopAnchorConstant = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.photoCollectionView.frame.maxY)) - (44 + (UIApplication.shared.statusBarFrame.size.height))
            
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.itemDetailView.frame = CGRect(x: 0, y:self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    
                    self.itemDetailView.leftUpArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * -0.9999))
                    self.itemDetailView.rightUpArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                    
                }, completion: {(finished: Bool) in
                    
                                        self.itemDetailView.frame = CGRect(x: 0, y:self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                })
            }
        }
        itemDetailView.updateConstraints()
    }
    
    
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        
            self.navigationController?.isNavigationBarHidden = false
            self.tabBarController?.tabBar.isHidden = false
            
            UIView.animate(withDuration: 0, animations: {}, completion: {(finished: Bool) in
                
                    self.itemDetailView.frame = CGRect(x: 0, y:self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
         
            })
            
            sender.view?.removeFromSuperview()
     
    }
    
    

    
    
    @IBAction func sendEmail(_ sender: UIButton) {
        //open chat here
        
        if let poster = poster {
        itemActionDelegate.sendPosterMessage(inpVC: self, currentItem: currentItem, destinationUser: poster)
        }
        else {
            
            Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Oops", inpMessage: "The poster is no longer using the app", inpOkTitle: "Ok")
            
        }
        
    }
    

    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .cancelled:
            break
            
        case .sent:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to mapView")
            
        case .failed:
            print ("Message sent failure")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
           break
            
        case .saved:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to mapView")
            
        case .sent:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to mapView")
            
        case .failed:
            print ("Mail sent failure: \([error!.localizedDescription])")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
