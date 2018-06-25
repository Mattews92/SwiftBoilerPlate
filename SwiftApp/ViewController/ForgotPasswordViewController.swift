//
//  ForgotPasswordViewController.swift
//  Mathews
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2017 Mathews. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    fileprivate var heightRatio: CGFloat = 1.0 //heightRatio for iPad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if UIApplication.shared.statusBarOrientation.isPortrait {
                self.heightRatio = UIScreen.main.bounds.width / 414
            }
            else {
                self.heightRatio = UIScreen.main.bounds.height / 414
            }
        default:
            break
        }
        
        self.configureViews()
        self.addTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.submitButton.layer.cornerRadius = self.submitButton.frame.size.height / 2
        self.submitButton.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ForgotPasswordViewController {
    func configureViews() {
        self.navigationController?.isNavigationBarHidden = true
        
        
        //string localization
        self.titleLabel.text = "Forgot Password"
        self.descriptionLabel.text = "Forgot your password?"
        self.submitButton.setTitle("Submit", for: .normal)
        
        
        self.titleLabel.font = UIFont(name: (self.titleLabel.font?.fontName)!, size:   (self.titleLabel.font?.pointSize)! * heightRatio)
        self.descriptionLabel.font = UIFont(name: (self.descriptionLabel.font?.fontName)!, size:   (self.descriptionLabel.font?.pointSize)! * heightRatio)
        self.submitButton.titleLabel?.font = UIFont(name: (self.submitButton.titleLabel?.font?.fontName)!, size:   (self.submitButton.titleLabel?.font?.pointSize)! * heightRatio)
        
        
        self.backButton.setImage(UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    
    func addTargets() {
        self.emailTextField.delegate = self
        
        self.submitButton.addTarget(self, action: #selector(self.submitButtonAction(sender:)), for: .touchUpInside)
        self.backButton.addTarget(self, action: #selector(self.closeScreen), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func closeScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func submitButtonAction(sender: UIButton) {
        self.validateFields()
    }
    
    fileprivate func validateFields() {
        var validFields = true
        if !((self.emailTextField.text ?? "").isValidEmail()) {
            validFields = false
//            self.emailTextField.displayErrorMessage(message: NSLocalizedString("INVALID_EMAIL", comment: ""))
        }
        if validFields {
            self.submitEmail()
        }
    }
    
    
    /// Invokes the forgot password network service
    func submitEmail() {
        if (!(Reachability()?.isReachable ?? false)) {
            self.showAlertWithTitle("", message: NSLocalizedString("NO_INTERNET", comment: ""), OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
        }
        else {
//            let params: [String: String] = ["email": self.emailTextField.text ?? ""]
//            let netWrkManager = NetworkManager()
//            self.showActivityIndicator(drawOnSelf: true)
//            netWrkManager.forgotPassword(parameter: params, completionHandler: { (status, response) in
//                self.removeActivityIndicator()
//                if status == .success {
//                    if response?.status ?? false {
//                        self.showAlertWithTitle("", message: response?.message ?? "", OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: { (action) in
//                            self.closeScreen()
//                        }, cancelButtonTitle: nil, cancelCompletion: nil)
//                    }
//                    else {
//                        self.showAlertWithTitle("", message: response?.message ?? "", OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
//                    }
//                }
//                else if status == .networkError {
//                    self.showAlertWithTitle("", message: NSLocalizedString("NETWORK_TIMEOUT", comment: ""), OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
//                }
//                else {
//                    self.removeActivityIndicator()
//                    self.showAlertWithTitle("", message: response?.message ?? "", OKButtonTitle: NSLocalizedString("OK", comment: ""), OKcompletion: nil, cancelButtonTitle: nil, cancelCompletion: nil)
//                }
//            })
        }
    }
}

// MARK: - UITextFieldDelegate
extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let enteredString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as String
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        self.validateFields()
        return true
    }
    
}
