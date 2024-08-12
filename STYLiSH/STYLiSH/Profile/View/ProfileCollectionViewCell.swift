//
//  CollectionViewCell.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/20.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemLabel.lineBreakMode = .byWordWrapping
    }
}




