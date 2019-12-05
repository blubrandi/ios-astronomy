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
    
//    Add properties to store an instance of MarsPhotoReference for which an image should be loaded as well as imageData that has been loaded. imageData should be optional since it won't be set until after data has been loaded from the network.
    
    
//    Implement an initializer that takes a MarsPhotoReference.
    
//    Override start(). You should begin by setting state to .isExecuting. This tells the operation queue machinery that the operation has started running.
    
//    Create a data task to load the image. You should store the task itself in a private property so you can cancel it if need be.
//    In the data task's completion handler, check for an error and bail out if one occurs. Otherwise, set imageData with the received data.
    
//    Make sure you set state to .isFinished before exiting the completion closure. This is a good use case for defer.
    
//    Override cancel(), which will be called if the operation is cancelled. In your implementation, call cancel() on the dataTask.

}
