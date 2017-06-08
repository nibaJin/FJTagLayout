//
//  ViewController.swift
//  FJTagLayout
//
//  Created by fujin on 2017/6/7.
//  Copyright © 2017年 fujin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, FJTagCollectionLayoutDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    var dataArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 模拟数据
        self.dataArray = ["头条","热点新闻","体育杂志","本地","财经","暴雪游戏帖","图片","轻松一刻","LOL","段子手","军事","房产","English","家居","原创大型喜剧","游戏英雄联盟","招行","农行基金","挖财","支付宝理财","银行理财","现金巴士","招行","农行基金","挖财","支付宝理财","银行理财","现金巴士","体育杂志","本地","财经","暴雪游戏帖","图片","轻松一刻","LOL","段子手","军事","房产"]
        let tagLayout = FJTagCollectionLayout.init()
        tagLayout.datasouce = self
        tagLayout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        tagLayout.itemHeight = 30
//        tagLayout.layoutAligned = .FJTagLayoutAlignedRight
        
        self.collectionView.collectionViewLayout = tagLayout
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // str width tool
    func size(_ str:NSString, fontSize:CGFloat) -> CGSize {
        let maxSize = CGSize.init(width: CGFloat(MAXFLOAT), height: fontSize + 4)
        
        let atttri = [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        
        let rusultRect = str.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: atttri, context: nil)
        
        return rusultRect.size
    }
    
    // FJTagCollectionLayoutDataSource
    func layoutItemWidth(at indexPath: IndexPath) -> CGFloat {
        let strSize = self.size(self.dataArray[indexPath.row] as NSString, fontSize: 14)
        let itemWidth = strSize.width + 16 + 1
        return itemWidth
    }
    
    // UICollectionViewDatasouce
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FJCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FJCollectionViewCell", for: indexPath) as! FJCollectionViewCell
        cell.tagLabel.text = self.dataArray[indexPath.row]
        return cell
    }

}

