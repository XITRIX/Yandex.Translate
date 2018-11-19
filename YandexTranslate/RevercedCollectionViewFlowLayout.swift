//
//  RevercedCollectionViewFlowLayout.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 18/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import UIKit

class RevercedCollectionViewFlowLayout : UICollectionViewFlowLayout {
    var expandContentSizeToBounds: Bool!
    var minimumContentSizeHeight: NSNumber!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        expandContentSizeToBounds = true
        minimumContentSizeHeight = nil
    }
    
    override init() {
        super.init()
        
        expandContentSizeToBounds = true
        minimumContentSizeHeight = nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if (expandContentSizeToBounds && fabsf(Float(collectionView!.bounds.size.height - newBounds.size.height)) > .ulpOfOne) {
            return true
        } else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        var expandedSize = super.collectionViewContentSize

        if (expandContentSizeToBounds) {
            let navigationBarHeight: CGFloat = 44
            let bottomViewOffset: CGFloat = 76
            expandedSize.height = max(expandedSize.height + 10, collectionView!.frame.size.height - collectionView!.contentInset.top - collectionView!.contentInset.bottom - navigationBarHeight - bottomViewOffset - UIApplication.shared.statusBarFrame.height)
        }

        if (minimumContentSizeHeight != nil) {
            expandedSize.height = max(expandedSize.height, minimumContentSizeHeight as! CGFloat)
        }

        return expandedSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attribute = super.layoutAttributesForItem(at: indexPath)!.copy() as! UICollectionViewLayoutAttributes
        modifyLayoutAttribute(attribute: &attribute)
        return attribute
    }
    
    override func layoutAttributesForElements(in reversedRect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let normalRect = normalRectForReversedRect(reversedRect: reversedRect)
        let attributes = super.layoutAttributesForElements(in: normalRect)
        var result: [UICollectionViewLayoutAttributes] = []
        
        for attribute in attributes! {
            var attr = attribute.copy() as! UICollectionViewLayoutAttributes
            modifyLayoutAttribute(attribute: &attr)
            result.append(attr)
        }
        return result
    }
    
    override var scrollDirection: UICollectionView.ScrollDirection {
        didSet {
            assert(scrollDirection == UICollectionView.ScrollDirection.vertical, "horizontal scrolling is not supported")
        }
    }
    
    func modifyLayoutAttribute( attribute: inout UICollectionViewLayoutAttributes) {
        let normalCenter = attribute.center
        let reversedCenter = reversedPointForNormalPoint(normalPoint: normalCenter)
        attribute.center = reversedCenter
    }
    
    func reversedRectForNormalRect(normalRect: CGRect) -> CGRect {
        let size = normalRect.size
        let normalTopLeft = normalRect.origin
        let reversedBottomLeft = reversedPointForNormalPoint(normalPoint: normalTopLeft)
        let reversedTopLeft = CGPoint(x: reversedBottomLeft.x, y: reversedBottomLeft.y - size.height)
        let reversedRect = CGRect(x: reversedTopLeft.x, y: reversedTopLeft.y, width: size.width, height: size.height)
        return reversedRect
    }
    
    func normalRectForReversedRect(reversedRect: CGRect) -> CGRect {
        return reversedRectForNormalRect(normalRect: reversedRect)
    }
    
    func reversedPointForNormalPoint(normalPoint: CGPoint) -> CGPoint {
        return CGPoint(x: normalPoint.x, y: reversedYforNormalY(normalY: normalPoint.y))
    }
    
    func normalPointForReversedPoint(reversedPoint: CGPoint) -> CGPoint {
        return reversedPointForNormalPoint(normalPoint: reversedPoint)
    }
    
    func reversedYforNormalY(normalY: CGFloat) -> CGFloat {
        let YreversedAroundContentSizeCenter = collectionViewContentSize.height - normalY
        return YreversedAroundContentSizeCenter
    }
    
    func normalYforReversedY(reversedY: CGFloat) -> CGFloat {
        return reversedYforNormalY(normalY: reversedY)
    }
}
