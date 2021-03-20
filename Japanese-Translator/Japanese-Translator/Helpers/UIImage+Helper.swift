//
//  UIImage+Helper.swift
//  Japanese-Translator
//
//  Created by Mar Cabrera on 27/02/2021.
//

import Foundation
import UIKit

extension UIImage {
    /**
     It rotates an image an specified number of degrees
     - parameters:
     - degrees: Number of degrees to rotate the image
     - returns: an image

     */
    func rotated(byDegrees degrees: Double) -> UIImage {
        let radians = CGFloat(degrees * .pi) / 180.0 as CGFloat
        let rotatedSize = self.size
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap?.rotate(by: radians)
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw(
            self.cgImage!,
            in: CGRect.init(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() // this is needed
        return newImage!
    }


    /**
     Function that scalates an image
     - Parameters:
     - maxDimension: maximum dimension that the image should scalate
     */
    func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)

        if size.width > size.height {
            scaledSize.height = size.height / size.width * scaledSize.width
        } else {
            scaledSize.width = size.width / size.height * scaledSize.height
        }

        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
