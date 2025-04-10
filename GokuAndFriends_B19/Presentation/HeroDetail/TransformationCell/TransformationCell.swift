//
//  TransformationCell.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 08/04/25.
//

import UIKit

class TransformationCell: UICollectionViewCell {
    @IBOutlet weak var transformationImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static let identifier = String(describing: TransformationCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func configureWithTrans(transformation: HeroTransformations) {
        nameLabel.text = transformation.name
        descriptionLabel.text = transformation.description
        
        if let url = URL(string: transformation.photo ?? "") {
            transformationImage.setImage(url: url)
        } else {
            transformationImage.image = nil
        }
    }
}
