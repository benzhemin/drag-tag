//
//  ViewController.swift
//  Tags
//
//  Created by peer on 16/8/15.
//  Copyright © 2016年 peer. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell{
    static let fontSize: CGFloat = 16
    static let swingKey = "SwingAnimationkey"
    
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
    
    func startSwingAnimation(){
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = NSNumber(float: Float(M_PI_2) / 30)
        animation.toValue = NSNumber(float: -Float(M_PI_2) / 30)
        animation.duration = 0.15
        animation.autoreverses = true
        animation.repeatCount = MAXFLOAT
        
        self.layer.addAnimation(animation, forKey: TagCell.swingKey)
    }
    
    func endSwingAnimation(){
        self.layer.removeAnimationForKey(TagCell.swingKey)
    }
}

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var tags : [String] = ["推荐", "本地", "热点", "奥运", "视频", "头条", "社会", "娱乐", "科技",
    "汽车", "图片", "体育", "财经", "军事", "国际", "段子", "趣图", "健康"];
    
    var tagCV: UICollectionView!
    
    var curIndexPath : NSIndexPath!
    var toIndexPath : NSIndexPath?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 15
        flowLayout.minimumLineSpacing = 15
        flowLayout.sectionInset = UIEdgeInsets(top: 60, left: 20, bottom: 10, right: 20)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        tagCV = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        tagCV.backgroundColor = UIColor.whiteColor()
        
        tagCV.alwaysBounceVertical = true
        
        tagCV.delegate = self
        tagCV.dataSource = self
        
        tagCV.registerClass(TagCell.self, forCellWithReuseIdentifier: String(TagCell))
        
        self.view.addSubview(tagCV)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        tagCV.addGestureRecognizer(longTapGesture)
 
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
        
        let padding: CGFloat = 13
        
        let attri = [NSFontAttributeName:UIFont.systemFontOfSize(TagCell.fontSize)]
        let size = tag.sizeWithAttributes(attri)
        
        return CGSize(width: size.width + padding*3.0, height: size.height + padding)
    }
    
    func longPress(pressGesture: UILongPressGestureRecognizer){
        
        let indexFactory = {(item: Int) -> NSIndexPath in
            return NSIndexPath(forRow: item, inSection: 0)
        }
    
        let state = pressGesture.state
        
        switch state {
        case .Began:
            self.animatingVisibleCells(state)
            
            let location = pressGesture.locationInView(self.tagCV)
            
            let indexPath = self.tagCV.indexPathForItemAtPoint(location)
            guard let ip = indexPath else { return }
            
            self.curIndexPath = ip
            
            print("began press indexpath \(ip.item)")
            
            let cell = self.tagCV.cellForItemAtIndexPath(ip)!
            cell.transform = CGAffineTransformMakeScale(1.1, 1.02)
            
        case .Changed:
            
            let location = pressGesture.locationInView(self.tagCV)
            let toIP = self.tagCV.indexPathForItemAtPoint(location)
            
            let cell = self.tagCV.cellForItemAtIndexPath(self.curIndexPath)
            cell?.center = location
            
            
            if let toIP = toIP where toIP.item != self.curIndexPath.item  {
                guard self.toIndexPath != toIP else { return }
                
                print("perform move from \(self.curIndexPath.item) to \(toIP.item)")
                
                self.toIndexPath = toIP
                
                let val = self.tags.removeAtIndex(self.curIndexPath.item)
                self.tags.insert(val, atIndex: toIP.item)
                
                print("move from \(self.curIndexPath.item) to \(toIP.item)")
                
                self.tagCV.moveItemAtIndexPath(self.curIndexPath, toIndexPath: toIP)
                
                /*
                self.tagCV.performBatchUpdates({
                    
                    
                    
                    /*
                    if toItem < curItem {
                        
                        for i in curItem-1...toItem {
                        
                        //for i in (curItem-1).stride(to: toItem, by: -1) {
                            self.tagCV.moveItemAtIndexPath(indexFactory(i), toIndexPath: indexFactory(i+1))
                        }
                        
                    }
                    */
                    
                }, completion: { (finish) in
                    
                    /*
                    let fromValue = self.tags[self.curIndexPath.item]
                    self.tags[self.curIndexPath.item] = self.tags[toIP.item]
                    self.tags[toIP.item] = fromValue
                      */
                })
 
                */
                
            }
            
            
            
        case .Ended:
            print("long press end")
            self.toIndexPath = nil
            
            let cell = self.tagCV.cellForItemAtIndexPath(self.curIndexPath)!
            
            let layout = self.tagCV.layoutAttributesForItemAtIndexPath(self.curIndexPath)!
            
            UIView.animateWithDuration(0.3, animations: { 
                cell.center = layout.center
            })
            
            cell.transform = CGAffineTransformIdentity
            
            self.animatingVisibleCells(state)
            
        default:
            break
        }
        
    }
    
    func animatingVisibleCells(phase: UIGestureRecognizerState){
        
        let cells = self.tagCV.visibleCells() as! [TagCell]
        
        for cell in cells {
        
            if phase == .Began {
                cell.startSwingAnimation()
            }
            else if phase == .Ended {
                cell.endSwingAnimation()
            }
        }
    }
}







