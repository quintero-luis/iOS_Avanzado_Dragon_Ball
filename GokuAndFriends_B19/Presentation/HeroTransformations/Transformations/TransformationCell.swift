//
//  TransformationCell.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//

import UIKit

class TransformationCell: UITableViewCell {
    
    @IBOutlet weak var transformationName: UILabel!
    
    @IBOutlet weak var transformationDescription: UILabel!
    
    
    @IBOutlet weak var transformationImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    func configureTransformationCell(with transformation: MOHeroTransformations) {
//        transformationName.text = transformation.name
//        transformationDescription.text = transformation.info
//        
//        if let url = URL(string: transformation.photo ?? "") {
//            transformationImageView.setImage(url: url)
//        }
//    }
    func configureTransformationCell(with transformation: HeroTransformations) {
        transformationName.text = transformation.name
        transformationDescription.text = transformation.id
        
        if let url = URL(string: transformation.photo ?? "") {
            transformationImageView.setImage(url: url)
        }
    }
    
}
