//
//  CardViewCell.swift
//  CardViewDemo
//
//  Created by WhatsXie on 2018/5/14.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

import UIKit

class CardViewCell: UICollectionViewCell {
    var cardImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(cardImageView)
        cardImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        cardImageView.layer.cornerRadius = 8
        cardImageView.clipsToBounds = true
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
