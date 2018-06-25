//
//  LoginViewController.swift
//  GuardianRPM
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2017 guardian. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureViews()
        self.addTargets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height / 2
        self.loginButton.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}


// MARK: - Custom Methods
extension LoginViewController {
    
    func configureViews() {
        self.navigationController?.isNavigationBarHidden = true
        
        
        //string localization
        
        self.loginButton.setTitle("Login", for: .normal)
        self.helpButton.setTitle("Help", for: .normal)
        self.createAccountButton.setTitle("Create Account", for: .normal)
    }
    
    func addTargets() {
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.forgotPasswordButton.addTarget(self, action: #selector(self.forgotPasswordButtonAction(sender:)), for: .touchUpInside)
        self.loginButton.addTarget(self, action: #selector(self.loginButtonAction(sender:)), for: .touchUpInside)
        self.createAccountButton.addTarget(self, action: #selector(self.createAccountButtonAction(sender:)), for: .touchUpInside)
        self.helpButton.addTarget(self, action: #selector(self.helpButtonAction(sender:)), for: .touchUpInside)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showPasswordButtonAction(sender:)))
        self.showPasswordButton.adjustsImageWhenHighlighted = false
        self.showPasswordButton.addGestureRecognizer(longPressRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    /// Action target for the Show password button in password textfield
    ///
    /// - Parameter sender: UIBUtton instance which invoked the method
    @objc func showPasswordButtonAction(sender: UILongPressGestureRecognizer) {
        if self.passwordTextField.text == "" {
            return
        }
        switch(sender.state) {
        case .began:
            self.passwordTextField.isSecureTextEntry = false
            self.showPasswordButton.setImage(UIImage(named: "eyeIcon_gray"), for: .normal)
        case .ended:
            self.passwordTextField.isSecureTextEntry = true
            self.showPasswordButton.setImage(UIImage(named: "eyeIcon_white"), for: .normal)
        default:
            break
        }
    }
    
    @objc func forgotPasswordButtonAction(sender: UIButton) {
        self.dismissKeyboard()
//        let controller = UIStoryboard(name: StoryBoardID.mainStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func helpButtonAction(sender: UIButton) {
        self.dismissKeyboard()
//        let controller = UIStoryboard(name: StoryBoardID.mainStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
//        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @objc func createAccountButtonAction(sender: UIButton) {
        self.dismissKeyboard()
//        let controller = UIStoryboard(name: StoryBoardID.mainStoryBoard, bundle: Bundle.main).instantiateViewController(withIdentifier: StoryBoardID.createAccountViewController)
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func loginButtonAction(sender: UIButton) {
        self.dismissKeyboard()
        self.validateFields()
    }
    
    
    /// Validates the input textfields
    func validateFields() {
        var validFields = true
        if !((self.usernameTextField.text ?? "").isValidEmail()) {
            validFields = false
//            self.usernameTextField.displayErrorMessage(message: NSLocalizedString("INVALID_USERNAME", comment: ""))
        }
        if (self.passwordTextField.text ?? "").isEmpty {
            validFields = false
//            self.passwordTextField.displayErrorMessage(message: NSLocalizedString("PASSWORD_EMPTY", comment: ""))
        }
        if validFields {
            self.authenticateUser()
        }
    }
    
    
    /// Invokes the login network service
    func authenticateUser() {
        if (!(Reachability()?.isReachable ?? false)) {
            self.showAlertWithTitle("", message: NSLocalizedString("NO_INTERNET", comment: ""), OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
        }
        else {
//            let netWrkManager = NetworkManager()
//            self.showActivityIndicator()
//            let orgnizationName = self.organistaionIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
//
//            let loginParams: [String: String] = ["email": self.usernameTextField.text ?? "", "password": (self.passwordTextField.text ?? "").encryptSHA1()]
//            netWrkManager.login(parameter: loginParams, completionHandler: { (status, response) in
//                self.removeActivityIndicator()
//                if status == .success {
//                    if response?.status ?? false {
//                        self.saveUserProfile(response: response!, completionHandler: { (status) in
//                            self.loadHomeScreen()
//                        })
//                        KeychainService.saveKey(service: StringKeyConstants.passwordKey, value: (self.passwordTextField.text ?? "").encryptSHA1())
//                        UserDefaults.standard.set(String(format: "%@", self.usernameTextField.text ?? ""), forKey: StringKeyConstants.userNameKey)
//                        UserDefaults.standard.set(String(format: "%@", orgnizationName ?? ""), forKey: StringKeyConstants.organisationIDKey)
//                        UserDefaults.standard.set(String(format: "%@", response?.accessToken ?? ""), forKey: StringKeyConstants.accessTokenKey)
//                        UserDefaults.standard.set(String(format: "%@", response?.refreshToken ?? ""), forKey: StringKeyConstants.refreshTokenKey)
//
//                        UserDefaults.standard.set(response?.id!, forKey: StringKeyConstants.userIDKey)
//                        self.saveTimeZones(response: response)
//                        (UIApplication.shared.delegate as? AppDelegate)?.registerForInactivityTimer()
//
//                        if (UserDefaults.standard.value(forKey: StringKeyConstants.deviceTokenKey) as? String) != nil {
//                            netWrkManager.registerForRemoteNotifications(completionHandler: { (status, response) in
//                            })
//                        }
//
//                    }
//                    else {
//                        self.showAlertWithTitle("", message: response?.message ?? "", OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
//                    }
//                }
//                else if status == .networkError {
//                    self.showAlertWithTitle("", message: NSLocalizedString("NETWORK_TIMEOUT", comment: ""), OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
//                }
//                else {
//                    self.showAlertWithTitle("", message: response?.message ?? "", OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
//                }
//            })
        }
    }
    
    /// Saves the user profile into coredate
    ///
    /// - Parameter response: response json from Login API
    func saveUserProfile(response: Any) {
        
    }
    
    
    /// Loads the physician home screen
    func loadHomeScreen() {
    }
}


// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let enteredString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as String
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.usernameTextField:
            let _ = self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            self.dismissKeyboard()
            self.validateFields()
        default:
            self.dismissKeyboard()
        }
        return true
    }
    
}
