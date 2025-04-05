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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWith(hero: Hero) {
        lbName.text = hero.name
        lbInfo.text = hero.description
    }

}
