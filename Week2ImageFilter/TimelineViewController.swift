//
//  TimelineViewController.swift
//  Week2ImageFilter
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit


class TimelineViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  @IBOutlet weak var collectionView: UICollectionView!

  var photoFileObjects = [PFObject]()
  var mainImageSize: CGSize?
  var flowLayout: UICollectionViewFlowLayout!
  let minimumCellDimension: CGFloat = 25
  let maximumCellDimension: CGFloat = 600
  var sizeScaler: SizeScaler!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    let pinch = UIPinchGestureRecognizer(target: self, action: "pinchRecognized:")
    self.collectionView.addGestureRecognizer(pinch)
    self.sizeScaler = SizeScaler(min: self.minimumCellDimension, max: self.maximumCellDimension, size: self.flowLayout.itemSize)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    ParseService.fetchImageFiles({ (data, error) -> Void in
      if let pfObjects = data  {
        self.photoFileObjects = pfObjects
        self.collectionView.reloadData()
      } else {
        println(error)
      }
    })
  }

  
  //MARK: UICollectionViewDelegation
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.photoFileObjects.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timelineCell", forIndexPath: indexPath) as! GalleryCollectionViewCell
    cell.tag++
    let tag = cell.tag
    ParseService.fetchImageFromPFObject(self.photoFileObjects[indexPath.row], completionHandler: { (image, error) -> Void in
      if let cellImage = image where cell.tag == tag {
        cell.imageView.image = image
      }
    })
    return cell
  }
  
  //MARK: Gesture Recognizers
  func pinchRecognized(gesture: UIPinchGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.Changed {
      self.flowLayout.itemSize = self.sizeScaler.sizeSquareToScale(gesture.scale)
      self.flowLayout.invalidateLayout()
    }
    if gesture.state == UIGestureRecognizerState.Ended  {
      self.sizeScaler.originalSize = self.flowLayout.itemSize
    }
  }

}
