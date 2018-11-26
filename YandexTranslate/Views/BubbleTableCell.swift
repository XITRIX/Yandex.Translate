//
//  BubbleTableCell.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 26/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class BubbleTableCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var bubble: UIView! {
        didSet {
            bubble.layer.cornerRadius = 16
        }
    }
    
    var viewModel: MessageViewModel?
    
    func update(viewModel: MessageViewModel) {
        self.viewModel = viewModel
        
        title.text = viewModel.title
        message.text = viewModel.message
        bubble.backgroundColor = viewModel.language.color
        
        if (viewModel.isLeft) {
            bubble.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            bubble.layoutMargins.right = -100
            bubble.layoutMargins.left = 0
            
            title.textAlignment = .left
            message.textAlignment = .left
        } else {
            bubble.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            bubble.layoutMargins.right = 0
            bubble.layoutMargins.left = -100
            
            title.textAlignment = .right
            message.textAlignment = .right
        }
    }
}
