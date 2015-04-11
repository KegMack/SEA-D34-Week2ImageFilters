//
//  GalleryViewController.swift
//  Week2ImageFilter
//
//  Created by User on 4/9/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit
import Photos

protocol ImageSelectedFromGalleryVC {
  func didSelectImage(UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  var delegate: ImageSelectedFromGalleryVC?
  var result: PHFetchResult!
  var imageManager: PHCachingImageManager!
  var mainImageSize: CGSize?
  var flowLayout: UICollectionViewFlowLayout!
  let cellDimension: CGFloat = 250
  let minimumCellDimension: CGFloat = 25
  let maximumCellDimension: CGFloat = 600
  var sizeScaler: SizeScaler!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.result = PHAsset.fetchAssetsWithOptions(nil)
    self.imageManager = PHCachingImageManager()
    self.flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    let pinch = UIPinchGestureRecognizer(target: self, action: "pinchRecognized:")
    self.collectionView.addGestureRecognizer(pinch)
    self.sizeScaler = SizeScaler(min: self.minimumCellDimension, max: self.maximumCellDimension, size: self.flowLayout.itemSize)

  }
  
  
  //MARK: UICollectionView Delegation
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return result.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("galleryCell", forIndexPath: indexPath) as! GalleryCollectionViewCell
    cell.tag++
    let tag = cell.tag
    if let asset = self.result[indexPath.row] as? PHAsset {
      self.imageManager.requestImageForAsset(asset, targetSize: CGSizeMake(self.cellDimension, self.cellDimension), contentMode: PHImageContentMode.AspectFit, options: nil, resultHandler: { (image, info) -> Void in
        if image != nil && cell.tag == tag {
          cell.imageView.image = image
        }
      })
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if self.delegate != nil && self.mainImageSize != nil {
      if let asset = self.result[indexPath.row] as? PHAsset {
        self.imageManager.requestImageForAsset(asset, targetSize: self.mainImageSize!, contentMode: PHImageContentMode.AspectFit, options: nil, resultHandler: { [weak self] (image, info) -> Void in
          if self != nil && image != nil {
            self!.delegate?.didSelectImage(image)
            self!.navigationController?.popViewControllerAnimated(true)
          }
        })
      }
    }
  }
  
  
  //MARK: Gesture Recognition
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