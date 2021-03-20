//
//  CVImageBuffer+Helper.swift
//  Japanese-Translator
//
//  Created by Mar Cabrera on 27/02/2021.
//

import Foundation
import UIKit


/// Converts CVImageBuffer to UIImage
extension CVImageBuffer {
    var uiImage: UIImage? {
        let ciImage = CIImage(cvImageBuffer: self)
        let temporaryContext = CIContext(options: nil)
        guard let videoImage = temporaryContext.createCGImage(ciImage,
                                                              from: CGRect(x: 0,
                                                                           y: 0,
                                                                           width: CVPixelBufferGetWidth(self),
                                                                           height: CVPixelBufferGetHeight(self))) else {
            return nil
        }

        let image = UIImage(cgImage: videoImage)
        return image
    }
}
