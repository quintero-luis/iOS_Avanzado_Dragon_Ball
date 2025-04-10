//
//  TransformationDetailController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 10/04/25.
//

import UIKit

class TransformationDetailController: UIViewController {
    @IBOutlet weak var transformationImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var trans: HeroTransformations!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = trans.name
        descriptionLabel.text = trans.description
        
        if let url = URL(string: trans.photo ?? "") {
            transformationImageView.setImage(url: url)
        } else {
            transformationImageView.image = nil
        }

    }
}
