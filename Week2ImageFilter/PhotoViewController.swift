//
//  PhotoViewController.swift
//  Week2ImageFilter
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ImageSelectedFromGalleryVC
{

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
    self.filters = [ImageFilterService.exposureAdjust, ImageFilterService.colorInvert, ImageFilterService.bumpDistortion, ImageFilterService.hatchedScreen, ImageFilterService.sharpenLuminance, ImageFilterService.pixellate, ImageFilterService.lightTunnel, ImageFilterService.circleSplash]
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
    
    let filterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
      if self != nil {
        self!.enterFilterMode()
      }
    }
    let uploadAction = UIAlertAction(title: "Upload Image", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.currentImage {
        let resizedImage = ImageResizer.resizeImage(image, size: self.imageUploadSize)
        ParseService.uploadImage(resizedImage, completionHandler: { (completionString) -> Void in
          println(completionString)
        })
      }
    }
    let galleryAction = UIAlertAction(title: "My Photos", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.performSegueWithIdentifier("gallerySegue", sender: self)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

    self.alertController.addAction(galleryAction)
    self.alertController.addAction(uploadAction)
    self.alertController.addAction(filterAction)
    self.alertController.addAction(cancelAction)
    
  }
  
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    
    if let popoverController = self.alertController.popoverPresentationController {
      if let button = sender as? UIButton {
        popoverController.sourceView = button
        popoverController.sourceRect = button.bounds
      }
    }
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  
  //MARK: Filter Mode Functions
  
  func enterFilterMode() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
    self.editButton.enabled = false
    self.collectionViewBottomConstraint.constant = 0
    UIView.animateWithDuration(self.filterModeAnimationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func exitFilterMode() {
    self.navigationItem.rightBarButtonItem = nil
    self.editButton.enabled = true
    self.collectionViewBottomConstraint.constant = -(self.view.frame.height-self.editButton.frame.height) - self.collectionView.frame.height
    UIView.animateWithDuration(self.filterModeAnimationDuration, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  
  //MARK: UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
      self.currentImage = editedImage
    }
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  

  //MARK: UICollectionViewDelegation
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.filters.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCell
    let filter = self.filters[indexPath.row]
    cell.imageView.image = filter(self.originalThumbnail, self.context)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let filter = self.filters[indexPath.row]
    self.currentImage = filter(self.currentImage, self.context)
  }
  
  
  //MARK: ImageSelectedFromGalleryVC Protocol
  
  func didSelectImage(image: UIImage) {
    self.currentImage = image
  }
  
  
  //MARK: Prepare For Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "gallerySegue" {
      if let galleryVC = segue.destinationViewController as? GalleryViewController {
        galleryVC.delegate = self
        galleryVC.mainImageSize = self.mainImageView.frame.size
      }
    }
  }
  
}
