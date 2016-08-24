//
//  ViewController.swift
//  Tags
//
//  Created by peer on 16/8/15.
//  Copyright © 2016年 peer. All rights reserved.
//

import UIKit

class DragFlowLayout: UICollectionViewFlowLayout {

    var toItem: Int?
    
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        
        updateItems.forEach { (updateItem) in
            
            if updateItem.updateAction == .Move {
                toItem = updateItem.indexPathAfterUpdate?.item
            }
        }
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layout = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
        
        if (itemIndexPath.item == toItem) {
            //修复toItem 跳变的bug
            layout?.transform = CGAffineTransformMakeScale(1.1, 1.1)
        }
        
        return layout
    }
}

class TagCell: UICollectionViewCell{
    static let fontSize: CGFloat = 16
    static let waggleKey = "WaggleSwingAnimationkey"
    
    var tagLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        //self.layer.opaque = true
        
        tagLabel = UILabel()
        tagLabel.textAlignment = .Center
        tagLabel.backgroundColor = UIColor.clearColor()
        tagLabel.textColor = UIColor.grayColor()
        tagLabel.font = UIFont.systemFontOfSize(TagCell.fontSize)
        
        self.addSubview(tagLabel)
        
        tagLabel.textColor = UIColor.colorWithRGB(101, g: 101, b: 101)
        tagLabel.layer.cornerRadius = CGRectGetHeight(self.contentView.bounds) * 0.5
        tagLabel.layer.borderColor = UIColor.colorWithRGB(211, g: 211, b: 211).CGColor;
        tagLabel.layer.borderWidth = 0.45
        
        makeConstraints()
    }
    
    func makeConstraints(){
        tagLabel.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.layoutIfNeeded()
        
        self.layer.cornerRadius = self.bounds.height/2
    }
    
    func startWaggleAnimation(){
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = NSNumber(float: Float(M_PI_4) / 10)
        animation.toValue = NSNumber(float: -Float(M_PI_4) / 10)
        animation.duration = 0.15
        animation.autoreverses = true
        animation.repeatCount = MAXFLOAT
        
        self.layer.addAnimation(animation, forKey: TagCell.waggleKey)
    }
    
    func endWaggleAnimation(){
        self.layer.removeAnimationForKey(TagCell.waggleKey)
    }
}

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var tags : [String] = ["推荐", "本地", "热点", "奥运", "视频", "头条", "社会", "娱乐", "科技",
    "汽车", "图片", "体育", "财经", "军事", "国际", "段子", "趣图", "健康"];
    
    var tagCV: UICollectionView!
    
    var curIndexPath : NSIndexPath!
    var toIndexPath : NSIndexPath?
    var curCell: UICollectionViewCell?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let flowLayout = DragFlowLayout()
        flowLayout.minimumInteritemSpacing = 15
        flowLayout.minimumLineSpacing = 15
        flowLayout.sectionInset = UIEdgeInsets(top: 60, left: 20, bottom: 10, right: 20)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        tagCV = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        tagCV.backgroundColor = UIColor.whiteColor()
        
        tagCV.alwaysBounceVertical = true
        
        tagCV.delegate = self
        tagCV.dataSource = self
        
        tagCV.registerClass(TagCell.self, forCellWithReuseIdentifier: String(TagCell))
        
        self.view.addSubview(tagCV)
        
        tagCV.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        tagCV.addGestureRecognizer(longTapGesture)
 
        
        //slow animation
        //UIApplication.sharedApplication().windows[0].layer.speed = 0.1
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(TagCell), forIndexPath: indexPath) as! TagCell
        
        cell.tagLabel.text = tags[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let tag = tags[indexPath.item] as NSString
        
        let padding: CGFloat = 12
        
        let attri = [NSFontAttributeName:UIFont.systemFontOfSize(TagCell.fontSize)]
        let size = tag.sizeWithAttributes(attri)
        
        return CGSize(width: size.width + padding*3.0, height: size.height + padding)
    }
    
    func locationForLayoutBorderTurple(point: CGPoint) -> (layout:UICollectionViewLayoutAttributes?, upperLeft:CGPoint, bottomRight:CGPoint) {
        
        let layoutList = self.tagCV.visibleCells().flatMap { (cell) -> UICollectionViewLayoutAttributes? in
            let indexPath = self.tagCV.indexPathForCell(cell)!
            return self.tagCV.layoutAttributesForItemAtIndexPath(indexPath)
        }
        
        let layout = layoutList.filter { (layout) -> Bool in
            return layout.frame.contains(point)
        }.first
        
        let upperLeft = layoutList.first!.frame.origin
        let bottomRight = layoutList.reduce(CGPointZero) { (point, layout) -> CGPoint in
            let maxY = CGRectGetMaxY(layout.frame)
            if maxY > point.y {
                return CGPoint(x: CGRectGetMaxX(layout.frame), y: maxY)
            }
            return point
        }
        
        return (layout, upperLeft, bottomRight)
    }
    
    func longPress(pressGesture: UILongPressGestureRecognizer){
    
        let location = pressGesture.locationInView(self.tagCV)
        let state = pressGesture.state
        
        switch state {
        case .Began:
            
            let indexPath = self.tagCV.indexPathForItemAtPoint(location)
            guard let ip = indexPath else { return }
            
            self.animatingVisibleCells(state)
            self.curIndexPath = ip
            
            curCell = self.tagCV.cellForItemAtIndexPath(ip)
            curCell?.transform = CGAffineTransformMakeScale(1.2, 1.2)
            
        case .Changed:
            
            guard let cell = self.curCell else { return }
            cell.center = location
            
            let moveTag = { (to: NSIndexPath) in
                
                self.toIndexPath = to
                
                let val = self.tags.removeAtIndex(self.curIndexPath.item)
                self.tags.insert(val, atIndex: to.item)
                
                self.tagCV.moveItemAtIndexPath(self.curIndexPath, toIndexPath: to)
                
                self.curIndexPath = to
            }
            
            let layoutBorder = locationForLayoutBorderTurple(location)
            
            //location 没有对应的layout，判断边界
            guard let toLayout = layoutBorder.layout else {
    
                //简单处理
                if location.y < layoutBorder.upperLeft.y {
                    self.toIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                }
                else if location.y > layoutBorder.bottomRight.y {
                    self.toIndexPath = NSIndexPath(forRow: self.tags.count-1, inSection: 0)
                }
                
                if let to = toIndexPath where to.item != self.curIndexPath.item{
                    moveTag(to)
                }
                
                return
            }
            
            if toLayout.indexPath.item != self.curIndexPath.item {
                moveTag(toLayout.indexPath)
            }
            
        case .Ended:
            /*
            目标indexPath，如果有moveItem发生 toIP = self.toIndexPath
             如果没有moveItem发生，toIP为当前的indexPath
            */
            let toIP = self.toIndexPath ?? self.curIndexPath
            guard let to = toIP else { return }
    
            let layout = self.tagCV.layoutAttributesForItemAtIndexPath(to)
            
            if let layout = layout {
                UIView.animateWithDuration(0.3, animations: {
                    self.curCell?.center = layout.center
                })
            }
            
            self.curCell?.transform = CGAffineTransformIdentity
            
            //恢复原状
            self.toIndexPath = nil
            self.curCell = nil
            
            self.animatingVisibleCells(state)
            
        default:
            break
        }
    }
    
    func animatingVisibleCells(phase: UIGestureRecognizerState){
        
        let cells = self.tagCV.visibleCells() as! [TagCell]
        
        for cell in cells {
        
            if phase == .Began {
                cell.startWaggleAnimation()
            }
            else if phase == .Ended {
                cell.endWaggleAnimation()
            }
        }
    }
}
