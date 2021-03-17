//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/7/21.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginButton: LoadingButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        wipeLoginInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if userNameTextField.isEditing || passwordTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func loginButtonTapped(_ sender: LoadingButton) {
        setLoggingIn(true)
        OTMClient.login(username: self.userNameTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }

    @IBAction func signUpButtonTapped() {
        UIApplication.shared.open(OTMClient.Endpoints.signIn.url, options: [:], completionHandler: nil)
    }

    func handleLoginResponse(success: Bool, error: Error?) {
        if(success) {
            OTMClient.getUser(userId: OTMClient.Auth.accountKey, completion: handleGetUserResponse(user:error:))
        }
        else {
            showLoginFailure(error: error)
        }
    }
    
    func handleGetUserResponse(user: User?, error: Error?) {
        if let user = user {
            print("Logging in")
            setLoggingIn(false)
            OTMModel.user = user
            print("\(user.firstName) \(user.lastName)")
            self.performSegue(withIdentifier: "login", sender: nil)
        }
        else {
            showLoginFailure(error: error)
        }
    }

    func setLoggingIn(_ loggingIn: Bool) {
        userNameTextField.enableTextField(isEnabled: !loggingIn)
        passwordTextField.enableTextField(isEnabled: !loggingIn)
        loginButton.showLoading(isLoading: loggingIn)
        signUpButton.isEnabled = !loggingIn
    }
    
    func showLoginFailure(error: Error?) {
        let alertVC = UIAlertController(title: "Login Failed", message: error?.localizedDescription ?? "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in self.setLoggingIn(false)}))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func wipeLoginInfo() {
        self.userNameTextField.text = ""
        self.passwordTextField.text = ""
    }
    
}
