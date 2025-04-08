//
//  TransformationsController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//

import UIKit

class TransformationsController: UITableViewController {
    
    
    
    private var viewModel: HeroDetailViewModel
    
    init(viewModel: HeroDetailViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
        viewModel.loadData()
        
        
    }

    // MARK: - Table view data source

}
