//
//  GridView.swift
//  GridviewDemo
//
//  Created by shuai on 2018/10/17.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit
import Kingfisher

protocol UIImageViewDataSource {
    func setImageOf(_ imageView: UIImageView)
}

extension UIImage: UIImageViewDataSource {
    func setImageOf(_ imageView: UIImageView) {
        imageView.image = self
    }
}

extension String: UIImageViewDataSource {
    func setImageOf(_ imageView: UIImageView) {
        if let url = URL(string: self) {
            imageView.kf.setImage(with: url)
        }
    }
}

protocol GridViewDelegate {
    func gridView(_ gridView: GridView, didSelectImageAt Index: Int)
    func gridView(_ gridView: GridView, didMoveImageAt sourceIndex: Int, to destinationIndex: Int)
}

extension GridViewDelegate {
    func gridView(_ gridView: GridView, didSelectImageAt Index: Int){}
    func gridView(_ gridView: GridView, didMoveImageAt sourceIndex: Int, to destinationIndex: Int){}
}

class GridView: UIView {
    
    var delegate: GridViewDelegate?
    @IBInspectable var isEditEnable = false
    @IBInspectable var space: CGFloat = 8 {
        didSet {
           self.collectionView.reloadData()
        }
    }
    
    var imageSource = [UIImageViewDataSource]() {
        didSet {
            didResetImageSource()
        }
    }
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1.0,
                                                  constant: 100)
        heightConstraint.priority = UILayoutPriority.fittingSizeLevel
        return heightConstraint
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLeftAlignedLayout()
        let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: "GridViewCell")
        collectionView.backgroundColor = self.backgroundColor
        return collectionView
    }()

    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(heightConstraint)
        config()
    }
    
    //MARK: - layout
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds;
        collectionView.reloadData()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        let width = floor((targetSize.width - space * 2) / 3)
        let rowCount = ceil(CGFloat(imageSource.count) / 3)
        var height = rowCount * (width + space) - space
        height = height < 0 ? 0 : height
        return CGSize(width: targetSize.width, height: height)
    }
}

//MARK: - custom function
extension GridView {
    private func config() {
        addSubview(collectionView)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(moveCollectionViewItem))
        collectionView.addGestureRecognizer(longPress)
    }
    
    private func didResetImageSource() {
        let width = floor((frame.size.width - space * 2) / 3)
        let rowCount = ceil(CGFloat(imageSource.count) / 3)
        var height = rowCount * (width + space) - space
        height = height < 0 ? 0 : height
        heightConstraint.constant = height
        collectionView.reloadData()
    }
    
    @objc private func moveCollectionViewItem(by gestureRecognizer: UILongPressGestureRecognizer) {
        if isEditEnable == false {
            return
        }
        let point = gestureRecognizer.location(in: collectionView)
        switch gestureRecognizer.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: point) {
                collectionView.beginInteractiveMovementForItem(at: indexPath)
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(point)
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    
    private func deleteCollectionItem(at index: Int) {
        
    }
}

extension GridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath) as! GridViewCell
        imageSource[indexPath.row].setImageOf(cell.imageView)
        return cell
    }

}

extension GridView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.gridView(self, didSelectImageAt: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let image = imageSource[sourceIndexPath.row]
        imageSource.remove(at: sourceIndexPath.row)
        imageSource.insert(image, at: destinationIndexPath.row)
        delegate?.gridView(self, didMoveImageAt: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

extension GridView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.frame.size.width - space * 2) / 3)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
}


class GridViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    private final func config() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
}





