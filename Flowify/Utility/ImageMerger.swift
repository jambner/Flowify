//
//  ImageMerger.swift
//  Flowify
//
//  Created by jambo on 9/25/24.
//

import UIKit

class ImageMerger {
    func mergeImages(images: [UIImage]) -> UIImage? {
        guard !images.isEmpty else { return nil }

        // Determine the total width and height for the final image
        let totalWidth = images.reduce(0) { $0 + $1.size.width }
        let maxHeight = images.map { $0.size.height }.max() ?? 0

        // Create a graphics context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: maxHeight), false, 0.0)

        // Draw each image in the context
        var xOffset: CGFloat = 0
        for image in images {
            image.draw(in: CGRect(x: xOffset, y: 0, width: image.size.width, height: maxHeight))
            xOffset += image.size.width
        }

        // Get the merged image
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return mergedImage
    }
}
