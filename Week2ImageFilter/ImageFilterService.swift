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
  
  class func exposureAdjust(input: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIExposureAdjust")
    filter.setDefaults()
    filter.setValue(1.0, forKey: "inputEV")
    return self.filterImage(input, filter: filter, context: context)
  }
  
  class func colorInvert(input: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIColorInvert")
    filter.setDefaults()
    return self.filterImage(input, filter: filter, context: context)
  }
  
  class func bumpDistortion(input: UIImage, context: CIContext) -> UIImage {
    let filter = CIFilter(name: "CIBumpDistortion")
    let inputCenter = CIVector(x: input.size.width/2, y: input.size.height/2)
    filter.setDefaults()
    filter.setValue(2.0, forKey: "inputScale")
    filter.setValue(inputCenter, forKey: "inputCenter")
    return self.filterImage(input, filter: filter, context: context)
  }
    
  private class func filterImage(originalImage : UIImage, filter : CIFilter, context : CIContext) -> UIImage {
    
    let image = CIImage(image: originalImage)
    filter.setValue(image, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let resultRef = context.createCGImage(result, fromRect: result.extent())
    return UIImage(CGImage: resultRef)!
  }
  
  
}
