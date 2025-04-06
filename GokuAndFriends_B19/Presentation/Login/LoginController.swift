//
//  LoginController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//

import UIKit

class LoginViewModel {
    //    let token = "eyJraWQiOiJwcml2YXRlIiwiYWxnIjoiSFMyNTYiLCJ0eXAiOiJKV1QifQ.eyJpZGVudGlmeSI6IjdBQjhBQzRELUFEOEYtNEFDRS1BQTQ1LTIxRTg0QUU4QkJFNyIsImVtYWlsIjoiYmVqbEBrZWVwY29kaW5nLmVzIiwiZXhwaXJhdGlvbiI6NjQwOTIyMTEyMDB9.Dxxy91hTVz3RTF7w1YVTJ7O9g71odRcqgD00gspm30s"
    
    private var secureData: SecureDataProtocol
    
    init(secureData: SecureDataProtocol = SecureDataProvider()) {
        self.secureData = secureData
    }
    // puse _ token: String
    func saveToken(_ token: String) {
        secureData.setToken(token)
    }
}
class LoginController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    private var viewModel: LoginViewModel
    //        init(viewModel: LoginViewModel = .init() ) {
    //            self.viewModel = viewModel
    //            super.init(nibName: String(describing: LoginController.self), bundle: nil)
    //        }
    
    // MARK: - Api Provider añadido y cambiado por el LoginViewModel
    private var apiProvider: ApiProvider
    
    init(apiProvider: ApiProvider = ApiProvider(), viewModel: LoginViewModel = LoginViewModel()) {
        self.apiProvider = apiProvider
        self.viewModel = viewModel
        super.init(nibName: String(describing: LoginController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Al presionar el botón de Login
    @IBAction func loginTapped(_ sender: Any) {
        // Primera verififacion del login
        guard let email = userNameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError(message: "Please enter correct email and password")
            return
        }
        
        
        print("Email: \(email)")
        print("Password: \(password)")
        // Tras recibir el token tras el login se guarda en el key chain
        //        viewModel.saveToken()
        apiProvider.authenticateUser(email: email, password: password) { [weak self] result in
            
            switch result {
            case .success(let token):
                DispatchQueue.main.async {
                    // Guardar token en el Keychain
//                    self?.saveToken(token: token)
                    
                    self?.viewModel.saveToken(token)
                    
                    // Navegar a HeroesController
                    let heroesVC = HeroesController()
                    self?.navigationController?.pushViewController(heroesVC, animated: true)
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    //                self?.showError(message: "Intente nuevamente")
                    print("Email2: \(email)")
                    print("Password2: \(password)")
                    self?.showError(message: "Error")
                }
            }
            
            
        }
    }
    
    
    // Función para guardar el token en ekl KeyChain
    private func saveToken(token: String) {
        // Guardar el token en el kaychain
//        SecureDataProvider().setToken(token)
        viewModel.saveToken(token)
    }
    
    // Función de mostrar alerta si hay error en el login
    private func showError(message: String) {
        // Mostar una alerta
        let alert = UIAlertController(title: "Credenciales incorrectas", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
