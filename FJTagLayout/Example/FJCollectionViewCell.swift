//
//  FJCollectionViewCell.swift
//  FJTagLayout
//
//  Created by fujin on 2017/6/7.
//  Copyright © 2017年 fujin. All rights reserved.
//

import UIKit

class FJCollectionViewCell: UICollectionViewCell {
    @IBOutlet var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.darkGray.cgColor
    }
}
