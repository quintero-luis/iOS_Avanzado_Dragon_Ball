//
//  LoginController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//

import UIKit

class LoginViewModel {
    
    let token = "eyJraWQiOiJwcml2YXRlIiwiYWxnIjoiSFMyNTYiLCJ0eXAiOiJKV1QifQ.eyJpZGVudGlmeSI6IjdBQjhBQzRELUFEOEYtNEFDRS1BQTQ1LTIxRTg0QUU4QkJFNyIsImVtYWlsIjoiYmVqbEBrZWVwY29kaW5nLmVzIiwiZXhwaXJhdGlvbiI6NjQwOTIyMTEyMDB9.Dxxy91hTVz3RTF7w1YVTJ7O9g71odRcqgD00gspm30s"
    
    private var secureData: SecureDataProtocol
    
    init(secureData: SecureDataProtocol = SecureDataProvider()) {
        self.secureData = secureData
    }
    
    func saveToken() {
        secureData.setToken(token)
    }
}
class LoginController: UIViewController {
    
    private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel = .init() ) {
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
    
    @IBAction func loginTapped(_ sender: Any) {
        // Tras recibir el token tras el login se guarda en el key chain
        viewModel.saveToken()
        let heroesVC = HeroesController()
        navigationController?.pushViewController(heroesVC, animated: true)
    }
    
}
