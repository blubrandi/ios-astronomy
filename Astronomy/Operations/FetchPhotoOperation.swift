//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Brandi on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//


// *ConcurrentOperation is a nice "boilerplate" class that makes it easier to implement concurrent/asynchonous Operation subclasses in Swift. Feel free to keep it in your personal code library so you can use it in other apps you write.


import Foundation

// Create a subclass of ConcurrentOperation* (provided for you in the project start) called FetchPhotoOperation.


class FetchPhotoOperation: ConcurrentOperation {
    
    // Add properties to store an instance of MarsPhotoReference for which an image should be loaded as well as imageData that has been loaded. imageData should be optional since it won't be set until after data has been loaded from the network.
    
    // We need a photo
    let photoReference: MarsPhotoReference
    
    // We need image data
    private(set) var imageData: Data? //This data will come from the imageURL from MarsPhotoReference
    
    // Make a URL Session and a Data Task
    
    private let session: URLSession
    private var dataTask: URLSessionDataTask?
    
    // Implement an initializer that takes a MarsPhotoReference.
    // We need to get data from API and the URL from the specific photo
    // We added URLSession.shared as a default value, because we'll always need it and we won't have to add it each time.
    
    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        
        // Whatever our photoReference is, we'll set it equal to whatever we pass into the initializer
        self.photoReference = photoReference
        self.session = session
        super.init()
    }
    
    
    //    Every operation has 2 critical functions that is required.  Start and Cancel.
    //    Override start(). You should begin by setting state to .isExecuting. This tells the operation queue machinery that the operation has started running.  || From ConcurrentOperation.swift ||
    
    override func start() {
        
        state = .isExecuting
        
        // Declare image URL.  Check MarsPhotoReference for image properties we have to work with.  All URLs are safe bcause of tge URL+Secure.swift file.
        guard let imageURL = photoReference.imageURL.usingHTTPS else { return }
        
        //    Create a data task to load the image. You should store the task itself in a private property so you can cancel it if need be.
        //    In the data task's completion handler, check for an error and bail out if one occurs. Otherwise, set imageData with the received data.
        // Declare a task
        let task = session.dataTask(with: imageURL) { (data, _, error) in // session declared above()
            
            // Make sure you set state to .isFinished before exiting the completion closure. This is a good use case for defer.
            // Don't change state to isFinished until the task is run
            defer { self.state = .isFinished }
            
            // if task is canceled, return out of the function
            if self.isCancelled { return }
            
            if let error = error {
                NSLog("Error fetching data for \(self.photoReference): \(error)")
            }
            
        // We have data from dataTask.  Since it's a private set, we're going to set it.
            guard let data = data else { return }
            self.imageData = data
        }
        task.resume()
        //  set the dataTask to the tast
        dataTask = task
    }
    
    //    Override cancel(), which will be called if the operation is cancelled. In your implementation, call cancel() on the dataTask.
    
    override func cancel() {
        

    }

    

    

    
}
