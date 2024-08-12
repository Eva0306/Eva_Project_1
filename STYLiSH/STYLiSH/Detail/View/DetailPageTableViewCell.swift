//
//  DetailPageTableViewCell.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/26.
//

import UIKit
import Kingfisher

let variants = ["尺寸", "庫存", "材質", "洗滌", "產地", "備註"]

class ImageScrollViewCell: UITableViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var image1View: UIImageView!
    @IBOutlet weak var image2View: UIImageView!
    @IBOutlet weak var image3View: UIImageView!
    @IBOutlet weak var image4View: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        pageControl.pageIndicatorTintColor = .black
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}

class InfoTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}

class StoryTableViewCell: UITableViewCell {
    @IBOutlet weak var storyLabel: UILabel!
}

class ColorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var deviderView: UIView!
    
    
    private var colorViews: [UIView] = []
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        if let colorView = colorView {
            colorView.layer.borderWidth = 1.0
            colorView.layer.borderColor = UIColor.gray.cgColor
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.backgroundColor = .gray
        }
    }
    
    private func clearColorViews() {
        if let colorView = colorView {
            colorView.removeFromSuperview()
        }
        colorViews.forEach { $0.removeFromSuperview() }
        colorViews.removeAll()
    }
    
    func addColorViews(colors: [UIColor]) {
        
        clearColorViews()
        var previousView: UIView? = nil
        
        for color in colors {
            let newView = UIView()
            newView.layer.borderWidth = 1.0
            newView.layer.borderColor = UIColor.gray.cgColor
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.backgroundColor = color
            contentView.addSubview(newView)
            
            NSLayoutConstraint.activate([
                newView.leadingAnchor.constraint(equalTo: previousView?.trailingAnchor ?? deviderView.trailingAnchor, constant: 12),
                newView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                newView.widthAnchor.constraint(equalToConstant: 24),
                newView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            previousView = newView
            colorViews.append(newView)
        }
    }
}

class VariantsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var variantsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func updatCell(with data: Product, for variantsIndex: Int) {
        self.variantsLabel.text = variants[variantsIndex]
        switch variantsIndex{
        case 0:
            self.variantsLabel.text = variants[variantsIndex]
            self.descriptionLabel.text = "\(data.sizes.first!) - \(data.sizes.last!)"
        case 1:
            self.variantsLabel.text = variants[variantsIndex]
            self.descriptionLabel.text = "\(data.variants.map{ $0.stock }.reduce(0, +))"
        case 2:
            self.variantsLabel.text = variants[variantsIndex]
            self.descriptionLabel.text = data.texture
        case 3:
            self.variantsLabel.text = variants[variantsIndex]
            self.descriptionLabel.text = data.wash
        case 4:
            self.variantsLabel.text = variants[variantsIndex]
            self.descriptionLabel.text = data.place
        case 5:
            self.variantsLabel.text = variants[variantsIndex]
            self.descriptionLabel.text = data.note
        default:
            self.variantsLabel.text = "None"
            self.descriptionLabel.text = "None"
        }
    }
}
