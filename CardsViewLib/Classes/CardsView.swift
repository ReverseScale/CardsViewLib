//
//  CardsView.swift
//  CardViewDemo
//
//  Created by WhatsXie on 2018/5/14.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

import UIKit

@objc public protocol CardsViewDelegate{
    /// 卡片点击事件
    @objc optional func cardClick(index: Int)
    /// 卡片初始化
    func cellForItem(cell: UICollectionViewCell, index: Int) -> UICollectionViewCell
}

open class CardsView: UIView {
    /// cell 标识符字符串
    let cellIdentifier = "cardCell"
    
    /// 图片数组
    var imagesArray = [Any]()
    /// item 宽度值
    var itemWidth:CGFloat!
    /// item 高度值
    var itemHeight:CGFloat!
    /// 距离左侧距离值
    var leftPadding:CGFloat = 0
    /// 间距值
    var LineSpacing: CGFloat!
    /// 是否循环
    var isCycles = false
    /// 当前卡片的序列值
    var centerIndex = 0
    /// 数据数组的数量值
    var imagesArrayCount = 0
    /// 自动轮播时间值
    var timeCount = 0
    /// 自动轮播 默认时间为2秒
    public var scrollTime = 2
    
    var collect:UICollectionView!
    var timer:Timer?
    /// 触控视图
    var touchView = UIView()
    
    /// 是否开启自动轮播
    public var isAutoScroll = false {
        didSet{
            if isAutoScroll {
                timeCount = 0
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(scrollCard), userInfo: nil, repeats: true)
            } else {
                timer?.invalidate()
            }
        }
    }
    /// CardsView 代理
    weak var delegate: CardsViewDelegate?
    
    public init(imagesArray: [Any], itemWidth: CGFloat, itemHeight: CGFloat, LineSpacing: CGFloat, cellClass: AnyClass?, delegate: CardsViewDelegate, iscycles: Bool, istransform: Bool){
        
        self.delegate = delegate
        self.itemHeight = itemHeight
        self.itemWidth = itemWidth
        self.LineSpacing = LineSpacing
        self.isCycles = iscycles
        
        super.init(frame: CGRect.zero)
        
        collect = UICollectionView(frame: self.frame, collectionViewLayout: CardFlowLayout(itemWidth: itemWidth, itemHeight: itemHeight, LineSpacing: LineSpacing, istransform: istransform, iscycles:iscycles))
        collect.backgroundColor = UIColor.clear
        collect.register(cellClass, forCellWithReuseIdentifier: cellIdentifier)
        collect.dataSource = self
        collect.delegate = self
        collect.showsHorizontalScrollIndicator = false
        collect.showsVerticalScrollIndicator = false
        collect.decelerationRate = 0.1
        self.addSubview(collect)
        
        setDatas(datas: imagesArray)
        
        touchGestureView()
    }
    /// 手势触控
    func touchGestureView() {
        touchView.frame = self.frame
        self.addSubview(touchView)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe(_:)))
        rightSwipeGesture.direction = .right
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe(_:)))
        leftSwipeGesture.direction = .left
        let clickTapGesture = UITapGestureRecognizer(target: self, action: #selector(clickAction(_:)))
        
        touchView.isUserInteractionEnabled = isCycles
        touchView.addGestureRecognizer(leftSwipeGesture)
        touchView.addGestureRecognizer(rightSwipeGesture)
        touchView.addGestureRecognizer(clickTapGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardsView {
    @objc func scrollCard(){
        timeCount += 1
        if timeCount == scrollTime {
            leftSwipe(UISwipeGestureRecognizer())
        }
    }
    
    override open func layoutSubviews() {
        collect.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        if isCycles {
            collect.setContentOffset(CGPoint(x: (itemWidth + LineSpacing) * CGFloat(centerIndex),y: 0), animated: false)
        } else {
            leftPadding = (collect.frame.size.width - itemWidth) / 2 - LineSpacing
        }
        touchView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    public func setDatas(datas:[Any]) {
        if isCycles {
            for _ in 0..<3 {
                self.imagesArray += datas
            }
            centerIndex = datas.count
        } else {
            self.imagesArray = datas
            centerIndex = 0
        }
        imagesArrayCount = datas.count
        collect.reloadData()
    }
    
    @objc func clickAction(_ rec:UITapGestureRecognizer) {
        print(rec.location(in: self))
        let offx = rec.location(in: self).x
        if isCycles {
            if offx < self.frame.size.width / 2 - itemWidth / 2 {
                rightSwipe(UISwipeGestureRecognizer())
            } else if offx > self.frame.size.width / 2 + itemWidth / 2 {
                leftSwipe(UISwipeGestureRecognizer())
            } else {
                delegate?.cardClick!(index: getCurrentIndex(index: centerIndex))
            }
        }
        
    }
    
    @objc func rightSwipe(_ rec:UISwipeGestureRecognizer){
        timeCount = 0
        if isCycles {
            if centerIndex == imagesArrayCount {
                centerIndex = imagesArrayCount * 2
                collect.setContentOffset(CGPoint(x: (itemWidth + LineSpacing) * CGFloat(centerIndex),y: collect.contentOffset.y), animated: false)
            }
            centerIndex -= 1
            collect.setContentOffset(CGPoint(x: (itemWidth + LineSpacing) * CGFloat(centerIndex),y: collect.contentOffset.y), animated: true)
        } else {
            if centerIndex == 0 {
                return
            } else if centerIndex == 1 {
                centerIndex -= 1
                collect.setContentOffset(CGPoint(x: 0, y: collect.contentOffset.y), animated: true)
            } else{
                centerIndex -= 1
                collect.setContentOffset(CGPoint(x: ((itemWidth + LineSpacing) * CGFloat(centerIndex)) - leftPadding ,y: collect.contentOffset.y), animated: true)
            }
        }
    }
    
    @objc func leftSwipe(_ rec:UISwipeGestureRecognizer){
        timeCount = 0
        if isCycles {
            if centerIndex == imagesArrayCount * 2 {
                centerIndex = imagesArrayCount
                collect.setContentOffset(CGPoint(x: (itemWidth + LineSpacing) * CGFloat(centerIndex),y: collect.contentOffset.y), animated: false)
            }
            centerIndex += 1
            collect.setContentOffset(CGPoint(x: (itemWidth + LineSpacing) * CGFloat(centerIndex),y: collect.contentOffset.y), animated: true)
        } else {
            if centerIndex == imagesArrayCount - 1 {
                return
            } else if centerIndex == imagesArrayCount - 2 {
                centerIndex += 1
                collect.setContentOffset(CGPoint(x: ((itemWidth + LineSpacing) * CGFloat(imagesArrayCount)) - collect.frame.size.width, y: collect.contentOffset.y), animated: true)
            } else {
                centerIndex += 1
                collect.setContentOffset(CGPoint(x: ((itemWidth + LineSpacing) * CGFloat(centerIndex)) - leftPadding ,y: collect.contentOffset.y), animated: true)
            }
        }
    }
    
    func getCurrentIndex(index: Int) -> Int {
        if imagesArrayCount == 0 {
            return 0
        }
        return index % imagesArrayCount
    }
    
}

extension CardsView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if delegate != nil {
            let cell = delegate!.cellForItem(cell: collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath), index: getCurrentIndex(index: indexPath.row))
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cardClick!(index: indexPath.row)
    }
}
