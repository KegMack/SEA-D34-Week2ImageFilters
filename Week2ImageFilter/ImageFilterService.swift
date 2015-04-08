//
//  ImageFilterService.swift
//  Week2ImageFilter
//
//  Created by User on 4/7/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

import UIKit
import CoreImage

class ImageFilterService {
  
  class func exposureAdjust(input: UIImage) -> UIImage {
    
    let ciImage = CIImage(image: input)
    let filter = CIFilter(name: "CIExposureAdjust")
    filter.setDefaults()
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(1.0, forKey: "inputEV")
    
    let resultImage = filter.valueForKey(kCIOutputImageKey) as CIImage
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    let context = CIContext(EAGLContext: eaglContext, options: options)
    
    let resultRef = context.createCGImage(resultImage, fromRect: resultImage.extent())
    return UIImage(CGImage: resultRef)!
  }
  
  class func colorInvert(input: UIImage) -> UIImage {
    
    let ciImage = CIImage(image: input)
    let filter = CIFilter(name: "CIColorInvert")
    filter.setDefaults()
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    
    let resultImage = filter.valueForKey(kCIOutputImageKey) as CIImage
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    let context = CIContext(EAGLContext: eaglContext, options: options)
    let resultRef = context.createCGImage(resultImage, fromRect: resultImage.extent())
    return UIImage(CGImage: resultRef)!
  }
  
  class func bumpDistortion(input: UIImageView) -> UIImage {
    
    let ciImage = CIImage(image: input.image)
    let filter = CIFilter(name: "CIBumpDistortion")
    let inputCenter = CIVector(x: input.center.x, y: input.center.y)
    filter.setDefaults()
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(2.0, forKey: "inputScale")
    filter.setValue(inputCenter, forKey: "inputCenter")

    let resultImage = filter.valueForKey(kCIOutputImageKey) as CIImage
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    let context = CIContext(EAGLContext: eaglContext, options: options)
    let resultRef = context.createCGImage(resultImage, fromRect: resultImage.extent())
    if resultRef != nil {
      return UIImage(CGImage: resultRef)!
    } else {
      println("Could not add Bump Distortion")
      return input.image!
    }
  }
}
