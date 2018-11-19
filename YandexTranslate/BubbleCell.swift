//
//  BubbleCell.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 17/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class BubbleCell: UICollectionViewCell {
    @IBOutlet weak var cellContentView: UIView! {
        didSet {
            cellContentView.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var title: UILabel!
	@IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
	var viewModel: MessageViewModel?
	
    func update(viewModel: MessageViewModel, collectionViewWidth: CGFloat) {
        self.viewModel = viewModel
        
		title.text = viewModel.title
		message.text = viewModel.message
        
        if (viewModel.isLeft) {
            cellContentView.backgroundColor = UIColor(red: 0, green: 0.49, blue: 0.91, alpha: 1)
            cellContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
            title.textAlignment = .left
            message.textAlignment = .left
        } else {
            cellContentView.backgroundColor = UIColor(red: 0.93, green: 0.3, blue: 0.36, alpha: 1)
            cellContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            
            title.textAlignment = .right
            message.textAlignment = .right
        }
        
        setupConstraints(collectionViewWidth: collectionViewWidth)
	}
    
    func setupConstraints(collectionViewWidth: CGFloat) {
        if let viewModel = viewModel {
            if (viewModel.isLeft) {
                if let leftConstraint = leftConstraint,
                    let rightConstraint = rightConstraint {
                    leftConstraint.priority = .defaultHigh
                    rightConstraint.priority = .defaultLow
                }
            } else {
                if let leftConstraint = leftConstraint,
                    let rightConstraint = rightConstraint {
                    leftConstraint.priority = .defaultLow
                    rightConstraint.priority = .defaultHigh
                }
            }
            
            let size = viewModel.calculateBubbleSize(collectionViewWidth: collectionViewWidth)
            widthConstraint.constant = size.width
        }
    }
}
