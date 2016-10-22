//
//  LoginViewController.swift
//  On The Map
//
//  Created by Andrew Olson on 8/14/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private enum StateMachine
    {
        case Initial
        case LoggingIn
        case Reset
    }
    
    let URLInstance = URLClient.getSharedInstance()
    let classroomInstance  = Classroom.getSharedInstance()
    let accountClient = AccountClient.getSharedInstance()
    
    override func viewWillAppear(animated: Bool)
    {
        subscribeToKeyboardNotifications()
        setup(.Initial)
    }
    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    /*MARK: Login Button */
    @IBAction func loginAction(sender: UIButton)
    {
        setup(.LoggingIn)
        let username = self.emailTextField.text!
        let password = self.passwordTextField.text!

        //getSessionIdAndAccountKey(username, password: password)
        accountClient.getSessionIdAndAccountKey(username, password: password)
        {
            message in
            
            if message == "Success"
            {
                self.performSegueWithIdentifier("OnTheMapViewNavigationController", sender: self)
            }
            else
            {
                self.displayErrorAndReset(message)
            }
        
        }
    }
    @IBAction func signUpAction(sender: AnyObject)
    {
        let app = UIApplication.sharedApplication()
        let signUpURL = "https://www.udacity.com/account/auth#!/signup"
        guard app.openURL(NSURL(string: signUpURL)!)
            else
        {
            print("Not A URL!")
            displayErrorAndReset("No Internet Access!")
            return
        }
    }
    /*MARK: Initial Setup */
    private func setup(state: StateMachine)
    {
        switch(state)
        {
            case .Initial:
                setEnabled(true)
                print("Initial Setup")
            case .LoggingIn:
                setEnabled(false)
                self.activityIndicator.startAnimating()
                print("Logging In")
            case .Reset:
                setEnabled(true)
                self.activityIndicator.stopAnimating()
                print(print("Reset"))
        }
    }
    
    private func setEnabled(enabled: Bool)
    {
        self.emailTextField.enabled = enabled
        self.passwordTextField.enabled = enabled
        self.loginButton.enabled = enabled
        self.activityIndicator.hidden = enabled
    }
    
    func displayErrorAndReset(message: String)
    {
        self.showErrorAlert(message)
        performUIUpdatesOnMain()
        {
                self.setup(.Reset)
        }
    }
    /*Mark: KeyBoard Notifications */
    func subscribeToKeyboardNotifications()
    {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(LoginViewController.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(LoginViewController.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
    }
    
    func unsubscribeToKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillHideNotification,object: nil)
    }
    /*Mark: Keyboard Functionality */
    func keyboardWillShow(notification: NSNotification)
    {
        let yOrigin = view.frame.origin.y
        
        if yOrigin == 0
        {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    func keyboardWillHide(notification: NSNotification)
    {
        view.frame.origin.y = 0
    }
    func getKeyboardHeight(notification: NSNotification)-> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    /*Mark: TextField Delegate */
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
