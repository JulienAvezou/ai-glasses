//
//  PhotoLibraryService.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import Photos
import UIKit

final class PhotoLibraryService {
    func requestAuth() async -> PHAuthorizationStatus {
        await withCheckedContinuation { cont in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                cont.resume(returning: status)
            }
        }
    }

    func fetchLatestImageAsset() -> PHAsset? {
        let opts = PHFetchOptions()
        opts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        opts.fetchLimit = 1
        return PHAsset.fetchAssets(with: .image, options: opts).firstObject
    }

    func loadUIImage(from asset: PHAsset, targetSize: CGSize = CGSize(width: 2200, height: 2200)) async -> UIImage? {
        await withCheckedContinuation { cont in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                cont.resume(returning: image)
            }
        }
    }
}
