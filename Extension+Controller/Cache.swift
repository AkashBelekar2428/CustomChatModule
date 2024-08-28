//
//  Cache.swift
//  Peeks
//
//  Created by Matheus Ruschel on 2017-01-16.
//  Copyright © 2017 Riavera. All rights reserved.
//

import UIKit
import CoreData

protocol CacheDescriptor {
    init(_ data: Data)
    func dataForCache() -> Data
}

extension Data: CacheDescriptor {
    
    func dataForCache() -> Data {
        return self
    }
    
}

class PeeksCache <T: CacheDescriptor> {
    
    subscript(key: String) -> T? {
        get {
            return loadObjectForKey(key)
        }
        set(newValue) {
            addObject(newValue!, forKey: key)
        }
    }
    
    var managedContext: NSManagedObjectContext!
    
    init() {
        
        DispatchQueue.main.async {
            let appDelegate =
                UIApplication.shared.delegate as? AppDelegate
//            self.managedContext = appDelegate?.managedObjectContext
        }
    }
    
    class func sharedInstance() -> PeeksCache<T> {
        return PeeksCache<T>()
    }
    
    func addObject(_ object: T, forKey key: String) {
        
        let date = Date()
        
        if let managedObject = self.fetchObject(key) {
            
            if object.dataForCache().count == 0 {
                managedObject.setValue(nil, forKey: "data")
            } else {
                managedObject.setValue(object.dataForCache(), forKey: "data")
            }
            managedObject.setValue(date, forKey: "timestamp")
            
        } else {
            
            let entity =  NSEntityDescription.entity(forEntityName: "CacheObject",
                                                     in:managedContext)
            
            let cacheObject = NSManagedObject(entity: entity!,
                                              insertInto: managedContext)
            
            if object.dataForCache().count == 0 {
                cacheObject.setValue(nil, forKey: "data")
            } else {
                cacheObject.setValue(object.dataForCache(), forKey: "data")
            }
            cacheObject.setValue(date, forKey: "timestamp")
            cacheObject.setValue(key, forKey: "keyValue")
            
            do {
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
        }
        
    }
    
    func clearCacheObjectsThatSurpassedTTL(_ allowedTTL: TimeInterval = 3600) {
        
        if let objects = self.fetchObjectsInCache() {
            
            for object in objects {
                
                let timestamp = object.value(forKey: "timestamp") as? Date
                let endDate = timestamp?.addingTimeInterval(allowedTTL)
                let currDate = Date()
                
                if currDate.compare(endDate!) == .orderedDescending {
                    managedContext.delete(object)
                }
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
        }
        
    }
    
    func cacheSize() -> Int? {
        return self.fetchObjectsInCache()?.count
    }
    
    func clearCache() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Could not delete objects \(error), \(error.userInfo)")
            
        }
    }
    
    fileprivate func fetchObject(_ key: String) -> NSManagedObject? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
        fetchRequest.predicate = NSPredicate(format: "keyValue == %@", key)
        fetchRequest.fetchLimit = 1
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            
            if results.count != 0 {
                return results[0] as? NSManagedObject
            } else {
                return nil
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func fetchAllKeys() -> [String] {
        
        let objects = fetchObjectsInCache()
        
        var keyList = [String]()
        
        for object in objects ?? [] {
            if let keyValue = object.value(forKey: "keyValue") as? String {
                keyList.append(keyValue)
            }
        }
        
        return keyList
        
    }
    
    func fetchAllObjects() -> [T] {
        var objectsList = [T]()
        
        let cachedDataList = fetchObjectsInCache()
        
        for cachedObject in cachedDataList ?? [] {
            
            if let resultObject = cachedObject.value(forKey: "data") as? Data {
                objectsList.append(T(resultObject))
            }
            
        }
        
        return objectsList
    }
    
    fileprivate func loadObjectForKey(_ key: String) -> T? {
        if let result = self.fetchObject(key) {
            if let resultData = result.value(forKey: "data") as? Data {
                return T(resultData)
            }
        }
        return nil
        
    }
    
    fileprivate func fetchObjectsInCache() -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            
            return results as? [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
        
    }
    
}
