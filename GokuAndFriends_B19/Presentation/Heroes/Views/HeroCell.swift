//
//  HeroCell.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 31/3/25.
//

import UIKit

class HeroCell: UICollectionViewCell {
    
    static let identifier = String(describing: HeroCell.self)

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbInfo: UILabel!
    
    @IBOutlet weak var heroImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWith(hero: Hero) {
        lbName.text = hero.name
        lbInfo.text = hero.description
        
        if let url = URL(string: hero.photo ?? "") {
            heroImageView.setImage(url: url)
        } else {
            heroImageView.image = nil
        }
    }
}
