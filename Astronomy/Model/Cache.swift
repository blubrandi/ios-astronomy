//
//  Cache.swift
//  Astronomy
//
//  Created by Brandi on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

// create a code snippet for this later...

// We want this to be generic so it's modular
// Creating a dictionary with key/value pairs

// Create a class called Cache. It should be generic with respect to the type it stores, and its keys. e.g. Cache<Key, Value>.
// The generic Key type will need to be constrained to conform to Hashable.
class Cache<Key: Hashable, Value> {
    
    //Create a private property that is a dictionary to be used to actually store the cached items. The type of the dictionary should be [Key : Value]. Make sure you initialize it with an empty dictionary.
    // (This is where we'll store our keys and their values.
    private var cache = [Key : Value]()
    
    // Make cache thread-safe, this is a serial queue (We're making the label the same as the state queue in ConcurrentOperation.swift).  Creating this makes it so everything can use shared resources without NSLock().
    private var queue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")
    
    // A function that adds items to the cache
    func cache(value: Value, key: Key) {
        //Add items to serial queue:
        queue.async {
            // This is saying, for every item there needs to have a key and a value.  And if it has _this_ key, it should have _this_ value.  This is creating a dictionary with a key and a value.
            self.cache[key] = value
        }
    }
    
    // A function that returns items that are cached
    func value(key: Key) -> Value? {
        
        // This is .sync, because it needs to run after an item has been cached, or there is no value to return
        return queue.sync {
            cache[key] // The value we want returned is the value associated with the cache item's key.  We're calling it by the key in this line.
        }
    }
}
