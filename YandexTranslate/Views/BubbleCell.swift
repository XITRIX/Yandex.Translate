//
//  BubbleCell.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 26/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class BubbleCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var bubble: UIView! {
        didSet {
            bubble.layer.cornerRadius = 16
        }
    }
    
    var viewModel: MessageViewModel?
    
    func update(viewModel: MessageViewModel, tableViewWidth: CGFloat) {
        self.viewModel = viewModel
        
        title.text = viewModel.title
        message.text = viewModel.message
        bubble.backgroundColor = viewModel.language.color
    
        if (viewModel.isLeft) {
            bubble.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
            title.textAlignment = .left
            message.textAlignment = .left
        } else {
            bubble.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            
            title.textAlignment = .right
            message.textAlignment = .right
        }
        
        updateInsets(tableViewWidth: tableViewWidth)
    }
    
    func updateInsets(tableViewWidth: CGFloat) {
        if let viewModel = viewModel {
            let offset = tableViewWidth - viewModel.calculateBubbleSize(collectionViewWidth: tableViewWidth).width
            
            if (viewModel.isLeft) {
                bubble.layoutMargins.right = -offset
                bubble.layoutMargins.left = 0
            } else {
                bubble.layoutMargins.right = 0
                bubble.layoutMargins.left = -offset
            }
        }
    }
}
