//
//  PhotoViewController.swift
//  Week2ImageFilter
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource {

  //MARK: View Outlets
  
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!

  @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var mainImageTopConstraint: NSLayoutConstraint!
  
  
  //MARK: Properties
  
  let alertController = UIAlertController(title: "Options", message: "Choose One", preferredStyle: UIAlertControllerStyle.ActionSheet)
  var context: CIContext!
  let imageUploadSize = CGSizeMake(600, 600)
  var originalMainImageViewTopConstraintConstant: CGFloat!
  let filterModeAnimationDuration = 0.3
  var filters : [(UIImage, CIContext)->(UIImage)]!
  
  let thumbnailDimension: CGFloat = 75
  var originalThumbnail : UIImage!
  var currentImage : UIImage! {
    didSet {
      self.mainImageView.image = self.currentImage
      self.originalThumbnail = ImageResizer.resizeImage(self.currentImage, size: CGSizeMake(self.thumbnailDimension, self.thumbnailDimension))
      self.collectionView.reloadData()
    }
  }
  
  
  //MARK: Initialization
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeTabBarTitles()
    initializeConstraints()
    initializeContext()
    initializeAlertActions()
    self.filters = [ImageFilterService.exposureAdjust, ImageFilterService.colorInvert, ImageFilterService.bumpDistortion]
    self.currentImage = UIImage(named: "IMG_0209.jpg")

  }
  
  func initializeConstraints() {
    self.originalMainImageViewTopConstraintConstant = self.mainImageTopConstraint.constant
    self.collectionViewBottomConstraint.constant = -(self.view.frame.height-self.editButton.frame.height) - self.collectionView.frame.height
  }
  
  func initializeContext() {
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.context = CIContext(EAGLContext: eaglContext, options: options)
  }

  func initializeTabBarTitles() {
    self.title = "Photo Editor"
    if let viewControllers = self.tabBarController?.viewControllers {
      for vc in viewControllers {
        if let timeLineVC = vc as? TimelineViewController {
          timeLineVC.title = "Timeline"
        }
      }
    }
  }
  
  func initializeAlertActions() {
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
      let photoAction = UIAlertAction(title: "New Photo", style: UIAlertActionStyle.Default) { (action) -> Void in
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        imagePickerController.delegate = self
      }
      self.alertController.addAction(photoAction)
    }
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        //add camera stuff
      })
      self.alertController.addAction(cameraAction)
    }
   /* let exposureAdjustAction = UIAlertAction(title: "Exposure Adjust", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.mainImageView.image {
        let exposureAdjustedImage = ImageFilterService.exposureAdjust(image, context: self.context)
        self.mainImageView.image = exposureAdjustedImage
      }
    }
    let colorInvertAction = UIAlertAction(title: "Invert Color", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.mainImageView.image {
        let adjustedImage = ImageFilterService.colorInvert(image, context: self.context)
        self.mainImageView.image = adjustedImage
      }
    }
    let bumpDistortionAction = UIAlertAction(title: "Bump Distortion", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.mainImageView.image {
        let adjustedImage = ImageFilterService.bumpDistortion(image, context: self.context)
        self.mainImageView.image = adjustedImage
      }
    }*/
    let filterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
      if self != nil {
        self!.enterFilterMode()
      }
    }
    let uploadAction = UIAlertAction(title: "Upload Image", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.mainImageView.image {
        let resizedImage = ImageResizer.resizeImage(image, size: self.imageUploadSize)
        ParseService.uploadImage(resizedImage, completionHandler: { (completionString) -> Void in
          println(completionString)
        })
      }
    }
    
    self.alertController.addAction(uploadAction)
    self.alertController.addAction(filterAction)
//    self.alertController.addAction(exposureAdjustAction)
//    self.alertController.addAction(colorInvertAction)
//    self.alertController.addAction(bumpDistortionAction)
  }
  
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    
    if let popoverController = self.alertController.popoverPresentationController {
      if let button = sender as? UIButton {
        popoverController.sourceView = button
        popoverController.sourceRect = button.bounds
      }
    }
    self.presentViewController(alertController, animated: true) { () -> Void in
    }
  }
  
  //MARK: Filter Mode Functions
  
  func enterFilterMode() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
    self.editButton.enabled = false
    // self.mainImageTopConstraint.constant += self.view.frame.height
    self.collectionViewBottomConstraint.constant = 0
    UIView.animateWithDuration(self.filterModeAnimationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func exitFilterMode() {
    self.navigationItem.rightBarButtonItem = nil
    self.editButton.enabled = true
    // self.mainImageTopConstraint.constant = self.originalMainImageViewTopConstraintConstant
    self.collectionViewBottomConstraint.constant = -(self.view.frame.height-self.editButton.frame.height) - self.collectionView.frame.height
    UIView.animateWithDuration(self.filterModeAnimationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  //MARK: UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
      self.mainImageView.image = editedImage
    }
    
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
   self.mainImageView.image = image 
  }
  

  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.filters.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as ImageCell
    let filter = self.filters[indexPath.row]
    cell.imageView.image = filter(self.originalThumbnail, self.context)
    return cell
  }
  
  
  
  
}
