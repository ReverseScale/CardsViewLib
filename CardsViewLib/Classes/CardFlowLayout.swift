//
//  CardLayout.swift
//  CardViewDemo
//
//  Created by WhatsXie on 2018/5/14.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

import UIKit

class CardFlowLayout: UICollectionViewFlowLayout {
    var itemWidth: CGFloat = UIScreen.main.bounds.size.width * 0.8
    var itemHeight: CGFloat = UIScreen.main.bounds.size.width * 0.8 * 9 / 16
    var lineSpacing: CGFloat = 10
    var isTransform = false
    var isCycles = false
    
    lazy var inset:CGFloat = {
        return (self.collectionView?.bounds.width ?? 0) * 0.5 - self.itemSize.width * 0.5
    }()
    
    init(itemWidth: CGFloat, itemHeight: CGFloat, LineSpacing: CGFloat, istransform: Bool, iscycles: Bool) {
        super.init()
        
        self.lineSpacing = LineSpacing
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.isTransform = istransform
        self.isCycles = iscycles
        
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = LineSpacing
    }
    
    override func prepare() {
        if isCycles {
            self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset)
        } else {
            self.sectionInset = UIEdgeInsetsMake(0, lineSpacing, 0, lineSpacing)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    /// 缩放
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let array = super.layoutAttributesForElements(in: rect)
        if !isTransform {
            return array
        }

        let visiableRect = CGRect(x: self.collectionView!.contentOffset.x, y: self.collectionView!.contentOffset.y, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height)

        let centerX = self.collectionView!.contentOffset.x + self.collectionView!.frame.size.width * 0.5
        for attri in array! {
            if !visiableRect.intersects(attri.frame) { continue }
            let lastValue = (abs(attri.center.x - centerX) - itemWidth * 0.5)
            var fristValue = lastValue / (itemWidth * 0.5)
            if fristValue > 1 {
                fristValue = 1
            } else if fristValue < 0 {
                fristValue = 0
            }
            let scale = 1 - fristValue * 0.1
            attri.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        return array
    }
    
    
    /// 用来设置停止滚动那一刻的位置
    ///
    /// - Parameters:
    ///   - proposedContentOffset: 原本collectionview停止滚动那一刻的位置
    ///   - velocity: 滚动速度
    /// - Returns: 最终停留的位置
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        //为了让停止滑动时，时刻有一张图片位于屏幕中央
        let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height)
        //获得view中央的x值
        let centerX = proposedContentOffset.x + self.collectionView!.frame.width * 0.5
        //这个范围内的所有属性
        let array = self.layoutAttributesForElements(in: lastRect)

        //需要移动的距离
        var adjustOffsetX = CGFloat(MAXFLOAT)
        for attri in array! {
            if abs(attri.center.x - centerX) < abs(adjustOffsetX) {
                adjustOffsetX = attri.center.x - centerX
            }
        }
        return CGPoint(x: proposedContentOffset.x + adjustOffsetX, y: proposedContentOffset.y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
