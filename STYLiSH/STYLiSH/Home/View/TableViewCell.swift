//
//  TableViewCell.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/18.
//

import UIKit
import Kingfisher

class SingleImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var singleImageView: UIImageView!
    
    func updateCell(for product: Product) {
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        singleImageView.kf.setImage(with: URL(string: product.mainImage))
    }
}

class FourImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image1View: UIImageView!
    @IBOutlet weak var image2View: UIImageView!
    @IBOutlet weak var image3View: UIImageView!
    @IBOutlet weak var image4View: UIImageView!
    
    func updateCell(for product: Product) {
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        image1View.kf.setImage(with: URL(string: product.mainImage))
        image2View.kf.setImage(with: URL(string: product.images[0]))
        image3View.kf.setImage(with: URL(string: product.images[1]))
        image4View.kf.setImage(with: URL(string: product.images[2]))
    }
}
