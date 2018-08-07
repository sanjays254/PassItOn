//
//  LoginViewController.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-22.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseAuth


public var loggedInBool: Bool!
public var firstTimeUser: Bool!
public var guestUser: Bool!

class LoginViewController: UIViewController, UITextFieldDelegate, AlertDelegate{
    
    var rememberMeKey = "rememberMe"
    var useTouchID = "useTouchID"
    
    var schemaURL: URL!

    let maxPasswordLength = 20
    let signupTitleStr = "Create Account"
    let loginTitleStr = "Log In"
    let signupBtnStr = "Let's do this!"
    let loginBtnStr = "Go!"
    let signupSwitchStr = "Already have an account?"
    let loginSwitchStr = "Don't have an account yet?"
    let signupSwitchBtnStr = "Go to the login screen"
    let loginSwitchBtnStr = "Go to the sign up screen"
    let loginPasswordLabelStr = "Password"
    let signupPasswordLabelStr = "Password (8-20 characters)"
    
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
    @IBOutlet weak var touchIDSwitch: UISwitch!
    
    @IBOutlet weak var guestLoginButton: UIButton!
    
    var signupFailureReason: String!
    
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTimeUser = true
        usernameTextfield.delegate = self
        passwordTextfield.delegate = self
        emailTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        if(UserDefaults.standard.bool(forKey: rememberMeKey) == true){
            rememberMeSwitch.setOn(true, animated: false)
        }
        if(UserDefaults.standard.bool(forKey: useTouchID) == true){
            touchIDSwitch.setOn(true, animated: false)
        }
        
        goButton.tintColor = UIProperties.sharedUIProperties.whiteColour
        goButton.layer.borderWidth = 3.0
        goButton.layer.cornerRadius = 7.0
        goButton.backgroundColor = UIProperties.sharedUIProperties.purpleColour
        goButton.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        toggleButton.tintColor = UIProperties.sharedUIProperties.purpleColour
        
        guestLoginButton.tintColor = UIProperties.sharedUIProperties.purpleColour
        
        AuthenticationManager.alertDelegate = self
        
        
        setToLogIn()
        login()
        
        
    }
    
    func login(){
        if Auth.auth().currentUser != nil && UserDefaults.standard.bool(forKey: rememberMeKey) == true && UserDefaults.standard.bool(forKey: useTouchID) == true {
            
            firstTimeUser = false
            print("\((Auth.auth().currentUser?.displayName)!)")
            print ("\((Auth.auth().currentUser?.email)!)")
            emailTextfield.text = Auth.auth().currentUser?.email
            
            
            AuthenticationManager.loginWithTouchID(vc: self, email: (Auth.auth().currentUser?.email)!,
                                                   completionHandler: { (success) -> Void in
                                                    if success == true {
                                                        loggedInBool = true
                                                        self.loginSuccess()
                                                        
                                                        //if scheme link was opened, then add the notification observer
                                                        
                                                        if(self.schemaURL != nil){
                                                                                                                    NotificationCenter.default.addObserver(self, selector: #selector(self.rateUser), name: NSNotification.Name(rawValue: NotificationKeys.shared.usersDownloadedNotificationKey), object: nil)
                                                        }
                                                        
                                                    }
                                                    else {
                                                        print("Error logging in")
                                                    }
            })
        }
        else if (Auth.auth().currentUser != nil && UserDefaults.standard.bool(forKey: rememberMeKey) == true && UserDefaults.standard.bool(forKey: useTouchID) == false){
            emailTextfield.text = Auth.auth().currentUser?.email
            
            firstTimeUser = false
            
        }
    }
    
    //delegated method
    func presentAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
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
                NotificationCenter.default.addObserver(self, selector: #selector(self.rateUser), name: NSNotification.Name(rawValue: NotificationKeys.shared.usersDownloadedNotificationKey), object: nil)
            }
        }
        //else if we are still logged out, login like normal.
        else {
            login()
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
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.openedThroughSchema(url: schemaURL)
            }
        }
    }
    
    //this is called just after we log in
    @objc func popLoggedOutAlert(){
        if(self.presentedViewController is UIAlertController) {
            
            let alertVC = presentedViewController as! UIAlertController
            if alertVC.title == "Oops" {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }

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
        passwordLabel.text =  signupPasswordLabelStr
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
        passwordLabel.text = loginPasswordLabelStr
        goButton.setTitle(loginBtnStr, for: .normal)
        toggleButton.setTitle(loginSwitchBtnStr, for: .normal)
        usernameLabel.isHidden = true
        usernameTextfield.isHidden = true
        confirmPasswordTextfield.isHidden = true
        confirmPasswordLabel.isHidden = true
    }
    
    @IBAction func goPressed(_ sender: Any) {
        
        BusyActivityView.show(inpVc: self)

        if titleLabel.text == signupTitleStr {
            firstTimeUser = true
            print("trying to sign up...")
            if validateInputOf(textfield: usernameTextfield).valid &&
                validateInputOf(textfield: emailTextfield).valid &&
                validateInputOf(textfield: passwordTextfield).valid {
                print("Signing up...")
                AuthenticationManager.signUp(withEmail: emailTextfield.text!, password: passwordTextfield.text!, name: usernameTextfield.text!, completionHandler: { (success) -> Void in
                    
                    BusyActivityView.hide()
                    
                    if success == true {
                        loggedInBool = true
                        self.loginSuccess()
                        self.setUserDefaults()
                        
                    }
                    else {
                        let signUpFailedAlert = UIAlertController(title: "Signup failed", message: "There was an error", preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
                        signUpFailedAlert.addAction(okayAction)
                        self.present(signUpFailedAlert, animated: true, completion: nil)
                    }

                    
                })
                
                
                if (loggedInBool == true){
                    setUserDefaults()
                }
                else {
//                    let signUpFailedAlert = UIAlertController(title: "Signup failed", message: "Invalid email", preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
//                    signUpFailedAlert.addAction(okayAction)
//                    present(signUpFailedAlert, animated: true, completion: nil)
                }
                
            }
            else {
                let signUpFailedAlert = UIAlertController(title: "Signup failed", message: signupFailureReason, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
                signUpFailedAlert.addAction(okayAction)
                present(signUpFailedAlert, animated: true, completion: nil)
            }
        }
        else if titleLabel.text == loginTitleStr {
            firstTimeUser = false
            print("trying to log in...")
            if validateInputOf(textfield: emailTextfield).valid &&
                validateInputOf(textfield: passwordTextfield).valid {
                print("Logging in...")
                AuthenticationManager.login(withEmail: emailTextfield.text!, password: passwordTextfield.text!, completionHandler: { (success) -> Void in
                    
                    BusyActivityView.hide()
                    
                    if success == true {
                        loggedInBool = true
                        self.loginSuccess()
                        self.setUserDefaults()
                    }
                    else {
                        let loginFailedAlert = UIAlertController(title: "Login failed", message: "Incorrect Email or Password", preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
                        loginFailedAlert.addAction(okayAction)
                        self.present(loginFailedAlert, animated: true, completion: nil)
                    }
                })
                
                if (loggedInBool == true){
                    setUserDefaults()
                }

            }
            else {
                
                BusyActivityView.hide()
                
                print("Login failed: invalid input")
                let loginFailedAlert = UIAlertController(title: "Login failed", message: "Incorrect Email or Password", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
                loginFailedAlert.addAction(okayAction)
                present(loginFailedAlert, animated: true, completion: nil)
                
            }
        }
    }
    
    func setUserDefaults() {
        if UserDefaults.standard.bool(forKey: rememberMeKey) != rememberMeSwitch.isOn {
            UserDefaults.standard.set(rememberMeSwitch.isOn, forKey: rememberMeKey)
        }
        if UserDefaults.standard.bool(forKey: useTouchID) != touchIDSwitch.isOn {
            UserDefaults.standard.set(touchIDSwitch.isOn, forKey: useTouchID)
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
            if (usernameTextfield.isHidden == false){
                guard (usernameTextfield.text != "") else {
                    reason = "Display name is empty"
                    signupFailureReason = reason
                    validated = false
                    return (validated, reason)
                }
                validated = true
            }
            else {
                validated = true
            }
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
                signupFailureReason = reason
                mismatchingPasswordsAlert()
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
                signupFailureReason = reason
                mismatchingPasswordsAlert()
                
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
        
        if let homeNavV = self.presentingViewController as? UINavigationController {
            let homeVC = homeNavV.viewControllers[0] as! HomeViewController
            homeVC.readCurrentUser()
            
            self.dismiss(animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: "continueToHome", sender: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
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
    }
    
    func mismatchingPasswordsAlert(){
        let mismatchingPasswordsAlert = UIAlertController(title: "Oops", message: "Passwords don't match", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
        mismatchingPasswordsAlert.addAction(okayAction)
        present(mismatchingPasswordsAlert, animated: true, completion: nil)
    }
    
    @IBAction func guestLogin(_ sender: UIButton) {
        
        loggedInBool = true
        guestUser = true
        self.loginSuccess()
    }
    
}
