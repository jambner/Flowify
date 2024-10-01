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

        // Determine the total height and width for the final image
        let totalWidth = images.map { $0.size.width }.max() ?? 0
        let totalHeight = images.reduce(0) { $0 + $1.size.height }

        // Create a graphics context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: totalHeight), false, 0.0)

        // Draw each image in the context
        var yOffset: CGFloat = 0
        for image in images {
            image.draw(in: CGRect(x: 0, y: yOffset, width: totalWidth, height: image.size.height))
            yOffset += image.size.height
        }

        // Get the merged image
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return mergedImage
    }
}
