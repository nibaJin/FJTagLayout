//
//  FJTagCollectionLayout.swift
//  FJTagLayout
//
//  Created by fujin on 2017/6/7.
//  Copyright © 2017年 fujin. All rights reserved.
//

import UIKit
let elementKindSectionHeader = "UICollectionElementKindSectionHeader"
let elementKindSectionFooter = "UICollectionElementKindSectionFooter"

enum FJTagLayoutAligned:Int {
    case FJTagLayoutAlignedLeft = 0
    case FJTagLayoutAlignedMiddle
    case FJTagLayoutAlignedRight
}

@objc protocol FJTagCollectionLayoutDataSource {
    func layoutItemWidth(at indexPath: IndexPath) -> CGFloat
    @objc optional func layoutSectionHeader(at indexPath: IndexPath) -> CGSize
    @objc optional func layoutSectionFooter(at indexPath: IndexPath) -> CGSize
}

class FJTagCollectionLayout: UICollectionViewLayout {
    weak var datasouce: FJTagCollectionLayoutDataSource?
    var sectionInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    var lineSpacing: CGFloat = 10.0
    var itemSpacing: CGFloat = 10.0
    var itemHeight: CGFloat = 30.0
    var layoutAligned: FJTagLayoutAligned = .FJTagLayoutAlignedLeft
    
    private var endPoint = CGPoint.init(x: 0, y: 0)
    private var attriCacheDic = [String: AnyObject]()
    private var itemColums = Set<CGFloat>()

    override func prepare() {
        super.prepare()
        self.cacheAttributes() // 缓存布局
    }
    
    override var collectionViewContentSize: CGSize {
        var width: CGFloat = 0
        if let realWidth = self.collectionView?.frame.width {
            width = realWidth
        }
        return CGSize.init(width: width, height: self.endPoint.y)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var width: CGFloat = 0.0
        if let realWidth = self.datasouce?.layoutItemWidth(at: indexPath) {
            width = realWidth
        }
        let height = self.itemHeight
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        let judge = self.endPoint.x + width + self.itemSpacing + self.sectionInset.right
        if judge > (self.collectionView?.frame.size.width)! {
            x = self.sectionInset.left
            y = self.endPoint.y + self.lineSpacing
        } else {
            if indexPath.item == 0 {
                x = self.sectionInset.left
                y = self.endPoint.y + self.sectionInset.top
            } else {
                x = self.endPoint.x + self.itemSpacing
                y = self.endPoint.y - height
            }
        }
        
        self.endPoint = CGPoint.init(x: x+width, y: y+height)
        
        let attr = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)

        let frame: CGRect  = CGRect.init(x: x, y: y, width: width, height: height)
        attr.frame = frame
        
        self.itemColums.insert(frame.origin.y)
        
        return attr
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == elementKindSectionHeader {
            var size = CGSize.init(width: 0, height: 0)
            if let realSize = self.datasouce?.layoutSectionHeader?(at: indexPath) {
                size = realSize
            }
            let x: CGFloat = 0
            let y: CGFloat = self.endPoint.y
            let headerAttri = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: elementKindSectionHeader, with: indexPath)
            headerAttri.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
            self.endPoint = CGPoint.init(x: 0, y: y + size.height)
            return headerAttri
        } else if elementKind == elementKindSectionFooter {
            var size = CGSize.init(width: 0, height: 0)
            if let realSize = self.datasouce?.layoutSectionFooter?(at: indexPath) {
                size = realSize
            }
            let x: CGFloat = 0
            let y: CGFloat = self.endPoint.y + self.sectionInset.bottom
            let footerAttri = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: elementKindSectionFooter, with: indexPath)
            footerAttri.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
            self.endPoint = CGPoint.init(x: 0, y: y + size.height)
            return footerAttri
        }
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let sectionNum = self.collectionView?.numberOfSections {
            var attrsArray = [UICollectionViewLayoutAttributes]()
            
            for i in 0...sectionNum-1 {
                if let headerAttr: UICollectionViewLayoutAttributes = self.attriCacheDic["\(i)_header"] as? UICollectionViewLayoutAttributes {
                    if rect.contains(headerAttr.frame) {
                        attrsArray.append(headerAttr)
                    }
                }
                
                if let itemsAttr: [UICollectionViewLayoutAttributes] = self.attriCacheDic["\(i)"] as? [UICollectionViewLayoutAttributes] {
                    for attri in itemsAttr {
                        if rect.contains(attri.frame) {
                            attrsArray.append(attri)
                        }
                    }
                }
                
                if let footerAttr: UICollectionViewLayoutAttributes = self.attriCacheDic["\(i)_footer"] as? UICollectionViewLayoutAttributes {
                    if rect.contains(footerAttr.frame) {
                        attrsArray.append(footerAttr)
                    }
                }
            }
            return attrsArray
        }
        return nil
    }

    func cacheAttributes(){
        if let sectionNum = self.collectionView?.numberOfSections {
            for i in 0...sectionNum-1 {
                // header
                if let headerAttr = self.layoutAttributesForSupplementaryView(ofKind: elementKindSectionHeader, at: NSIndexPath.init(item: 0, section: i) as IndexPath) {
                    self.attriCacheDic["\(i)_header"] = headerAttr
                }
                
                // items
                if let count = self.collectionView?.numberOfItems(inSection: i) {
                    var itemsAttri = [UICollectionViewLayoutAttributes]()
                    
                    for j in 0...count-1 {
                        if let itemAttri = self.layoutAttributesForItem(at: NSIndexPath.init(item: j, section: i) as IndexPath) {
                            itemsAttri.append(itemAttri)
                        }
                    }
                    
                    switch self.layoutAligned {
                    case .FJTagLayoutAlignedMiddle:
                        self.updateItemsLayout(itemsAttri: itemsAttri)
                    case .FJTagLayoutAlignedRight:
                        self.updateItemsLayout(itemsAttri: itemsAttri)
                        break
                    default:
                        break
                    }
                    self.attriCacheDic["\(i)"] = itemsAttri as AnyObject
                }
                
                // footer
                if let footerAttr = self.layoutAttributesForSupplementaryView(ofKind: elementKindSectionFooter, at: NSIndexPath.init(item: 0, section: i) as IndexPath) {
                    self.attriCacheDic["\(i)_footer"] = footerAttr
                }
            }
        }
    }
    
    func updateItemsLayout(itemsAttri:[UICollectionViewLayoutAttributes]) {
        for columsY in self.itemColums {
            var columArray = [UICollectionViewLayoutAttributes]()
            for itemAtt in itemsAttri {
                if itemAtt.frame.origin.y == columsY {
                    columArray.append(itemAtt)
                }
            }
            let starX = self.sectionInset.left
            
            let endX = columArray.last!.frame.origin.x + columArray.last!.frame.size.width
            let offsetX = self.layoutAligned == .FJTagLayoutAlignedMiddle ? (self.collectionView!.frame.width - self.sectionInset.left - self.sectionInset.right - endX + starX) * 0.5 : self.collectionView!.frame.width - self.sectionInset.left - self.sectionInset.right - endX + starX
            columArray = columArray.map({ (itemAttr: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes in
                itemAttr.frame.origin.x = itemAttr.frame.origin.x + offsetX
                return itemAttr
            })
        }
    }
}
