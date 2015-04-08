//
//  PhotoViewController.swift
//  Week2ImageFilter
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  @IBOutlet weak var mainImageView: UIImageView!
  
  let alertController = UIAlertController(title: "Options", message: "Choose One", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let imageUploadSize = CGSizeMake(600, 600)

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeTabBarTitles()
    self.view.backgroundColor = UIColor.blackColor()
    initializeAlertActions()
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
    let exposureAdjustAction = UIAlertAction(title: "Exposure Adjust", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.mainImageView.image {
        let exposureAdjustedImage = ImageFilterService.exposureAdjust(image)
        self.mainImageView.image = exposureAdjustedImage
      }
    }
    let colorInvertAction = UIAlertAction(title: "Invert Color", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.mainImageView.image {
        let adjustedImage = ImageFilterService.colorInvert(image)
        self.mainImageView.image = adjustedImage
      }
    }
    let bumpDistortionAction = UIAlertAction(title: "Bump Distortion", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let image = self.mainImageView.image {
        let adjustedImage = ImageFilterService.bumpDistortion(self.mainImageView)
        self.mainImageView.image = adjustedImage
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
    self.alertController.addAction(exposureAdjustAction)
    self.alertController.addAction(colorInvertAction)
    self.alertController.addAction(bumpDistortionAction)
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

  
  
}
