//
//  MessageViewModel.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 17/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

struct MessageViewModel {
	var isLeft: Bool
	var title: String
	var message: String
    
    private enum cellConstants {
        static let bubbleSideOffset: CGFloat = 109
        static let textConstraintsHorizontalOffset: CGFloat = 24
        static let textConstraintsVerticalOffset: CGFloat = 20
        static let cellOffsets: CGFloat = 36 //collectionView cell offset
        static let stackLinearOffset : CGFloat = 2
    }
	
	func calculateCellSize(collectionViewWidth: CGFloat) -> CGSize {
        let size = calculateStackRect(collectionViewWidth)
		let height: CGFloat = size.height + cellConstants.textConstraintsVerticalOffset
        return CGSize(width: collectionViewWidth - cellConstants.cellOffsets, height: height)
	}
    
    func calculateBubbleSize(collectionViewWidth: CGFloat) -> CGSize {
        let size = calculateStackRect(collectionViewWidth)
        let height: CGFloat = size.height + cellConstants.textConstraintsVerticalOffset
        return CGSize(width: size.width + cellConstants.textConstraintsHorizontalOffset + 1, height: height)
    }
    
    private func calculateStackRect(_ collectionViewWidth: CGFloat) -> CGSize {
        let size = CGSize(width: collectionViewWidth - cellConstants.textConstraintsHorizontalOffset - cellConstants.cellOffsets - cellConstants.bubbleSideOffset, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let titleSize = NSString(string: title).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)], context: nil)
        let messageSize = NSString(string: message).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)], context: nil)
        let height: CGFloat = titleSize.height + cellConstants.stackLinearOffset + messageSize.height
        return CGSize(width: max(titleSize.width, messageSize.width), height: height)
    }
}
