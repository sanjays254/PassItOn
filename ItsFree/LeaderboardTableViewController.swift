//
//  LeaderboardTableViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-27.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseStorage



class LeaderboardTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
     let myDowloadCompletedNotificationKey = "myUsersDownloadNotificationKey"
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var leaderboardLabel: UILabel!
    @IBOutlet weak var findMeButton: UIButton!
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    var currentUserIndexPath: IndexPath!
    var crownImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        doneButton.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        doneButton.layer.backgroundColor = UIProperties.sharedUIProperties.blackColour.cgColor
        doneButton.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        doneButton.layer.borderWidth = 2.0
        doneButton.layer.cornerRadius = doneButton.frame.width/2
        
        findMeButton.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        findMeButton.layer.backgroundColor = UIProperties.sharedUIProperties.blackColour.cgColor
        findMeButton.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        findMeButton.layer.borderWidth = 2.0
        findMeButton.layer.cornerRadius = doneButton.frame.width/2
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: myDowloadCompletedNotificationKey), object: nil)
        
        ReadFirebaseData.readUsers()
        
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        leaderboardTableView.rowHeight = 80
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setupTitle(){
        let strokeTextAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            
            NSAttributedStringKey.foregroundColor : UIProperties.sharedUIProperties.lightGreenColour,
            NSAttributedStringKey.strokeWidth : -2.0,
            NSAttributedStringKey.font : UIFont(name: "GillSans-SemiBold", size: 25)!
        ]
        leaderboardLabel.attributedText = NSAttributedString(string: "Leaderboard", attributes: strokeTextAttributes)
    }
    
    @IBAction func dismissLeaderboard(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance.onlineUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sortedUsers = AppData.sharedInstance.onlineUsers.sorted(by: { $0.rating > $1.rating })
    
        let storageRef = Storage.storage().reference()
        let photoRef: String = sortedUsers[indexPath.row].profileImage
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardTableViewCell", for: indexPath) as! LeaderboardTableViewCell
        
        if(sortedUsers[indexPath.row].UID == AppData.sharedInstance.currentUser?.UID){
            cell.nameLabel.text = "You"
            cell.nameLabel.textColor = UIProperties.sharedUIProperties.whiteColour
            cell.positionLabel.textColor = UIProperties.sharedUIProperties.whiteColour
            cell.ratingLabel.textColor = UIProperties.sharedUIProperties.whiteColour
            cell.profileImageView.layer.borderColor = UIProperties.sharedUIProperties.whiteColour.cgColor
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
            cell.layer.cornerRadius = 5.0
            cell.backgroundColor = UIProperties.sharedUIProperties.purpleColour
            
            currentUserIndexPath = indexPath
        }
            
        else {
            cell.nameLabel.text = sortedUsers[indexPath.row].name
            cell.nameLabel.textColor = UIProperties.sharedUIProperties.blackColour
            cell.positionLabel.textColor = UIProperties.sharedUIProperties.blackColour
            cell.ratingLabel.textColor = UIProperties.sharedUIProperties.blackColour
            cell.profileImageView.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
            cell.layer.cornerRadius = 0.0
            cell.backgroundColor = UIProperties.sharedUIProperties.whiteColour
        }
        
        if(indexPath.row == 0){
            crownImageView = UIImageView(image: #imageLiteral(resourceName: "crown"))
            crownImageView.frame = CGRect(x: -8, y: -12, width: 30, height: 20)
            cell.positionLabel.addSubview(crownImageView)
            cell.positionLabel.text = ""
        }
        else {
            crownImageView.image = nil
            cell.positionLabel.text = String(indexPath.row+1)
        }
        
        cell.profileImageView.sd_setImage(with: storageRef.child(photoRef), placeholderImage: #imageLiteral(resourceName: "userPlaceholder") )
        
        //cell.profileImageView.image = sortedUsers[indexPath.row].profileImage
        cell.ratingLabel.text = String(sortedUsers[indexPath.row].rating)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    
    @IBAction func findMeAction(_ sender: UIButton) {
        leaderboardTableView.scrollToRow(at: currentUserIndexPath, at: .top, animated: true)
    }
    
    @objc func reload(){
        leaderboardTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
