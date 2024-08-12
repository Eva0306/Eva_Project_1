//
//  DetailPageViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/24.
//

import UIKit
import Kingfisher

class DetailPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var DetailPageCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DetailPageCollectionView.dataSource = self
        DetailPageCollectionView.delegate = self
        DetailPageCollectionView.collectionViewLayout = configureLayout()
        
        adjustSafeAreaInsets()
        
        pageControl.frame = .zero
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustSafeAreaInsets()
    }
    
}

// MARK: - Safe Area Adjustments
extension DetailPageViewController {
    private func adjustSafeAreaInsets() {
        if let windowScene = view.window?.windowScene {
            let topPadding = windowScene.windows.first?.safeAreaInsets.top ?? 0
            self.additionalSafeAreaInsets.top = -topPadding
            DetailPageCollectionView.contentInset = UIEdgeInsets(top: -topPadding, left: 0, bottom: 0, right: 0)
            DetailPageCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: -topPadding, left: 0, bottom: 0, right: 0)
        }
    }
}

// MARK: - Collection View Layout
extension DetailPageViewController {
    
    func configureLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            if sectionIndex == 0{
                return self.imageLayout()
            } else {
                return self.infoLayout()
            }
        }
    }
    
    func imageLayout() -> NSCollectionLayoutSection {
        let viewWidth = view.frame.width
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(viewWidth), heightDimension: .absolute(viewWidth * 4 / 3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    func infoLayout() -> NSCollectionLayoutSection {
        let viewWidth = view.frame.width
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(viewWidth), heightDimension: .estimated(30))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0)
        
        section.interGroupSpacing = 24.0
        
        return section
    }
    
}

// MARK: - Collection View DataSource
extension DetailPageViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            4
        } else {
            9
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! ImageCollectionViewCell
            if let product = product{
                cell.imageView.kf.setImage(with: URL(string: product.images[indexPath.item]))
            }
            return cell
            
        } else {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCell", for: indexPath) as! InfoCollectionViewCell
                if let product = product {
                    cell.nameLabel.text = product.title
                    cell.idLabel.text = "\(product.id)"
                    cell.priceLabel.text = "NT$\(product.price)"
                }
                return cell
                
            } else if indexPath.item == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCollectionViewCell
                if let product = product {
                    cell.storyLabel.text = product.story
                }
                return cell
                
            } else if indexPath.item == 2{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
                cell.colorView.backgroundColor = UIColor(hexStr: "#3C5A78")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VariantsCell", for: indexPath) as! VariantsCollectionViewCell
                if let product = product {
                    cell.updatCell(with: product, for: indexPath.item - 3)
                }
                return cell
            }
        }
    }
}

//MARK: - Page Control
extension DetailPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: DetailPageCollectionView.contentOffset, size: DetailPageCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let indexPath = DetailPageCollectionView.indexPathForItem(at: visiblePoint), indexPath.section == 0 {
            pageControl.currentPage = indexPath.item
        }
        updatePageControlPosition()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControlPosition()
    }
    
    private func updatePageControlPosition() {
        guard let layoutAttributes = DetailPageCollectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) else { return }
        
        let footerFrame = layoutAttributes.frame
        let collectionViewFrame = DetailPageCollectionView.frame
        let yOffset = DetailPageCollectionView.contentOffset.y + collectionViewFrame.size.height - footerFrame.origin.y
        
        pageControl.transform = CGAffineTransform(translationX: 0, y: -yOffset)
    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //            let visibleRect = CGRect(origin: DetailPageCollectionView.contentOffset, size: DetailPageCollectionView.bounds.size)
//            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//            if let indexPath = DetailPageCollectionView.indexPathForItem(at: visiblePoint) {
//                if indexPath.section == 0 {
//                    pageControl.currentPage = indexPath.item
//                }
//            }
//        }
}

