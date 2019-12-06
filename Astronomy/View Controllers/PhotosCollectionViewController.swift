//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.fetchMarsRover(named: "curiosity") { (rover, error) in
            if let error = error {
                NSLog("Error fetching info for curiosity: \(error)")
                return
            }
            
            self.roverInfo = rover
        }
    }
    
    // UICollectionViewDataSource/Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoReferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell ?? ImageCollectionViewCell()
        
        loadImage(forCell: cell, forItemAt: indexPath)
        
        return cell
    }
    
    // Make collection view cells fill as much available width as possible
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        var totalUsableWidth = collectionView.frame.width
        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        totalUsableWidth -= inset.left + inset.right
        
        let minWidth: CGFloat = 150.0
        let numberOfItemsInOneRow = Int(totalUsableWidth / minWidth)
        totalUsableWidth -= CGFloat(numberOfItemsInOneRow - 1) * flowLayout.minimumInteritemSpacing
        let width = totalUsableWidth / CGFloat(numberOfItemsInOneRow)
        return CGSize(width: width, height: width)
    }
    
    // Add margins to the left and right side
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
         let photoReference = photoReferences[indexPath.item]
        
//        Create three operations:
//        One should be a PhotoFetchOperation to fetch the image data from the network.
//        One should be used to store received data in the cache.
//        The last should check if the cell has been reused, and if not, set its image view's image.
//        The last two of these can be instances of BlockOperation.
        
        // Check if there is cached data. If there is cached data, then we can load the image from cache, then if there isn't cached data, perform the network request.
        
        if let cachedData = cache.value(key: photoReference.id),
            // turn data into UIImage
            let image = UIImage(data: cachedData) {
            cell.imageView.image = image
            return
        }
        
        // Fetch data operations performed if there is no cached data -->  Block operations here
        // Don't need to pass in a URLSession, because we already added it to the operation
        
        // We have a background thread and a concurrent operation, let's have them work in tandem
        let fetchOp = FetchPhotoOperation(photoReference: photoReference)  // declared a classwise instance to fetchOp and passed in the photoReference we have
        

        // we need to cache image
        let cacheOp = BlockOperation {
            if let data = fetchOp.imageData {
                //how we cache data
                self.cache.cache(value: data, key: photoReference.id)
            }
        }
        
        // Set the image that we received from the fetchOp to show in the collection view
        
        let completionOP = BlockOperation {
            
            // Get into the cache dictionary.  We only care about the data.  It will rely on the fetchOp
            // Define indexPath.  We want to make sure that each indexPath is the same as the one on the operationQueue, then execute the code.  Used for error handling
            
            if let currentIndexPath = self.collectionView.indexPath(for: cell),
                currentIndexPath != indexPath {
                print("Got image for reused cell")
                return
            }
            
            // Convert data from the fetchOp into an image
            if let data = fetchOp.imageData {
                cell.imageView.image = UIImage(data: data)
            }
        }
        
        
        // Make sure fetchOp is finished before cacheOp begins
        cacheOp.addDependency(fetchOp)
        // added dependency for completionOp
        completionOP.addDependency(fetchOp)
        photoFetchQueue.addOperation(fetchOp)
        
        // TODO: Implement image loading here
    }
    
    // MARK: Properties
    
    private let client = MarsRoverClient()
    
    // Add the properties we need access to
    
    // Cache is a generic type with key and a value.  The Int references the id of each photo (reference MarsPhotoReference, for the properties of the images we receive)
    private let cache = Cache<Int, Data>()
    
    // Add a private property called photoFetchQueue, which is an instance (and type) of OperationQueue.  Not a serial queue.  A serialQueue is main thread.  This will be on a background thread, and then switch it to the main thread once task is complete.
    private let photoFetchQueue = OperationQueue()
    
    // Creating a dictionary of operations Int = photo ID and operation = NSOperation.
    // Add a dictionary property that you'll use to store fetch operations by the associated photo reference id.
    private var operations = [Int : Operation]()
    
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[3]
        }
    }
    private var solDescription: SolDescription? {
        didSet {
            if let rover = roverInfo,
                let sol = solDescription?.sol {
                client.fetchPhotos(from: rover, onSol: sol) { (photoRefs, error) in
                    if let e = error { NSLog("Error fetching photos for \(rover.name) on sol \(sol): \(e)"); return }
                    self.photoReferences = photoRefs ?? []
                }
            }
        }
    }
    private var photoReferences = [MarsPhotoReference]() {
        didSet {
            DispatchQueue.main.async { self.collectionView?.reloadData() }
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
}
