//
//  LoginViewController.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-22.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseAuth

public let rememberMeKey = "rememberMe"
public var loggedInBool: Bool!

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var schemaURL: URL!

    let maxPasswordLength = 20
    let signupTitleStr = "Sign Up"
    let loginTitleStr = "Log In"
    let signupBtnStr = "Create Account"
    let loginBtnStr = "Log In"
    let signupSwitchStr = "Already have an account?"
    let loginSwitchStr = "Don't have an account yet?"
    let signupSwitchBtnStr = "Go to the login screen"
    let loginSwitchBtnStr = "Go to the sign up screen"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextfield.delegate = self
        passwordTextfield.delegate = self
        emailTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        setToLogIn()
        login()
    }
    
    func login(){
        if Auth.auth().currentUser != nil && UserDefaults.standard.bool(forKey: rememberMeKey) == true {
            print("\((Auth.auth().currentUser?.displayName)!)")
            print ("\((Auth.auth().currentUser?.email)!)")
            emailTextfield.text = Auth.auth().currentUser?.email
            
            
            AuthenticationManager.loginWithTouchID(email: (Auth.auth().currentUser?.email)!,
                                                   completionHandler: { (success) -> Void in
                                                    if success == true {
                                                        loggedInBool = true
                                                        self.loginSuccess()
                                                        
                                                        //if scheme link was opened, then add the notification observer
                                                        
                                                        if(self.schemaURL != nil){
                                                                                                                    NotificationCenter.default.addObserver(self, selector: #selector(self.rateUser), name: NSNotification.Name(rawValue: "myUsersDownloadNotificationKey"), object: nil)
                                                        }
                                                        
                                                    }
                                                    else {
                                                        print("Error logging in")
                                                    }
            })
        }
    }
    

    //this is called from the AppDelegate, if the app was opened with a URL Schema, and we werent logged in
    func loginAndRate(url: URL){
        
        self.schemaURL = url
        
        //if our loggedIn status has changed, pop the alert and go to HomeVC
        if(loggedInBool == true){
            popLoggedOutAlert()
            performSegue(withIdentifier: "continueToHome", sender: self)
            
            //if scheme link was opened, then add the notification observer, so we can rate a user when the data has been downloaded
            //do we really need this if statement? this function is only called when we open the app with a schema!!!!
            if(self.schemaURL != nil){
                NotificationCenter.default.addObserver(self, selector: #selector(self.rateUser), name: NSNotification.Name(rawValue: "myUsersDownloadNotificationKey"), object: nil)
            }
        }
        //else if we are still logged out, login like normal.
        else {
            login()
        }
    }
    
    //this is called just after we log in
    @objc func popLoggedOutAlert(){
        if(self.presentedViewController is UIAlertController) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //rateUser calls the ratingFunction and alert from the AppDelegate
    @objc func rateUser() {
        
        if(AppData.sharedInstance.onlineUsers.count == 0){
            let noUsersFoundAlert =  UIAlertController(title: "Oops", message: "No users were found", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            noUsersFoundAlert.addAction(okayAction)
            present(noUsersFoundAlert, animated: true, completion: nil)
        }
        
        else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.openedThroughSchema(url: schemaURL)
        }
    }
    
    @IBAction func toggleScreen(_ sender: Any) {
        print("Toggling...")
        if titleLabel.text == signupTitleStr {
            setToLogIn()
        }
        else if titleLabel.text == loginTitleStr {
            setToSignUp()
        }
    }
    
    func setToSignUp() {
        titleLabel.text = signupTitleStr
        switchLabel.text = signupSwitchStr
        goButton.setTitle(signupBtnStr, for: .normal)
        toggleButton.setTitle(signupSwitchBtnStr, for: .normal)
        usernameLabel.isHidden = false
        usernameTextfield.isHidden = false
        confirmPasswordTextfield.isHidden = false
        confirmPasswordLabel.isHidden = false
    }
    
    func setToLogIn() {
        titleLabel.text = loginTitleStr
        switchLabel.text = loginSwitchStr
        goButton.setTitle(loginBtnStr, for: .normal)
        toggleButton.setTitle(loginSwitchBtnStr, for: .normal)
        usernameLabel.isHidden = true
        usernameTextfield.isHidden = true
        confirmPasswordTextfield.isHidden = true
        confirmPasswordLabel.isHidden = true
    }
    
    @IBAction func goPressed(_ sender: Any) {

        if titleLabel.text == signupTitleStr {
            print("trying to sign up...")
            if validateInputOf(textfield: usernameTextfield).valid &&
                validateInputOf(textfield: emailTextfield).valid &&
                validateInputOf(textfield: passwordTextfield).valid {
                print("Signing up...")
                AuthenticationManager.signUp(withEmail: emailTextfield.text!, password: passwordTextfield.text!, name: usernameTextfield.text!, completionHandler: { (success) -> Void in
                    if success == true {
                        loggedInBool = true
                        self.loginSuccess()
                        
                    }
                    else {
                        print("Error logging in")
                    }
                })
                setUserDefaults()
            }
            else {
                print("Signup failed: invalid input")
            }
        }
        else if titleLabel.text == loginTitleStr {
            print("trying to log in...")
            if validateInputOf(textfield: emailTextfield).valid &&
                validateInputOf(textfield: passwordTextfield).valid {
                print("Logging in...")
                AuthenticationManager.login(withEmail: emailTextfield.text!, password: passwordTextfield.text!, completionHandler: { (success) -> Void in
                    if success == true {
                        loggedInBool = true
                        self.loginSuccess()
                    }
                    else {
                        print("Error logging in")
                    }
                })
                setUserDefaults()
            }
            else {
                print("Login failed: invalid input")
            }
        }
    }
    
    func setUserDefaults() {
        if UserDefaults.standard.bool(forKey: rememberMeKey) != rememberMeSwitch.isOn {
            UserDefaults.standard.set(rememberMeSwitch.isOn, forKey: rememberMeKey)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateInputOf(textfield:UITextField) -> (valid: Bool, reason: String?) {
        var validated = false
        var reason: String?
        if textfield === usernameTextfield {
            validated = true
        }
        else if textfield === emailTextfield {
            validated = true
        }
        else if textfield === confirmPasswordTextfield {
            if passwordTextfield.text == confirmPasswordTextfield.text {
                validated = true
            }
            else {
                reason = "Passwords do not match"
            }
        }
        else if textfield === passwordTextfield {
            if confirmPasswordTextfield.isHidden == true {
                validated = true
            }
            else if passwordTextfield.text == confirmPasswordTextfield.text {
                validated = true
            }
            else {
                reason = "Passwords do not match"
            }
        }
        return (validated, reason)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === passwordTextfield || textField === confirmPasswordTextfield {
            if textField.text!.count + string.count > maxPasswordLength {
                return false
            }
        }
        else if textField === usernameTextfield {
            
        }
        return true
    }
    
    func loginSuccess() {
        performSegue(withIdentifier: "continueToHome", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        //tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.removeGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        usernameTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        confirmPasswordTextfield.resignFirstResponder()
        emailTextfield.resignFirstResponder()
        
        //self.view.endEditing(true)
    }
}
