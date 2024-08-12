//
//  CatalogCollectionViewCell.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/22.
//

import UIKit
import Kingfisher

class CatalogCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "D9D9D9")
            } else {
                contentView.backgroundColor = .white
            }
        }
    }
    
    func updateCell(with data: Product) {
        self.imageView.kf.setImage(with: URL(string: data.mainImage))
        self.nameLabel.text = data.title
        self.priceLabel.text = "NT$" + String(data.price)
    }
}
