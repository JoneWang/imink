//
//  LoginViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import Combine

class LoginViewController: UIViewController {

    static let storyboardID = "Login"
    static func instantiateFromStoryboard() -> LoginViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? LoginViewController
    }
    
    @IBOutlet weak var clientTokenTextField: UITextField!
    
    @Published var loginFinished: Bool = false
    
    var cancelBag = Set<AnyCancellable>()
    
    private var loginViewModel = LoginViewModel()
    
    private var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = .init(width: 300, height: 200)
        
        loginViewModel.$status
            .sink { [weak self] status in
                if status == .loading {
                    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)

                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.style = UIActivityIndicatorView.Style.medium
                    loadingIndicator.startAnimating();

                    alert.view.addSubview(loadingIndicator)
                    self?.present(alert, animated: true, completion: nil)
                    
                    self?.alert = alert
                } else if status == .loginSuccess {
                    self?.loginFinished = true
                    if let alert = self?.alert {
                        alert.dismiss(animated: true) {
                            self?.dismiss(animated: true)
                        }
                    }
                } else if status == .waitTypeToken {
                    if let alert = self?.alert {
                        alert.dismiss(animated: true)
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
    @IBAction func okTouch(_ sender: Any) {
        loginViewModel.clientToken = clientTokenTextField.text ?? ""
        loginViewModel.login()
    }
    
}
