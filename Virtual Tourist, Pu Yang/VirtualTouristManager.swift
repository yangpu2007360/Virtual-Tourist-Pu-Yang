

import UIKit
import MapKit
import CoreData

class VirtualTouristManager: NSObject {

    static let sharedInstance = VirtualTouristManager()
    
    let stack = CoreDataStack(modelName: "VirtualTouristModel")!
    
    var mapPins = [Pin]()
    
    override init()
    {
        super.init()
//        getAllPins()
//        resumePhotoDownload()
    }
    
    //MARK: appdelegate functions
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        
        return true;
        
    }
    
    func getMapPinAtIndex(index: Int) -> Pin?
    {
        guard index >= 0 && index < mapPins.count else {
            return nil
        }
        return mapPins[index]
    }
    
    
    func addMapPin(coord: CLLocationCoordinate2D) -> Bool
    {
         let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: VirtualTouristManager.sharedInstance.stack.context)
        
        mapPins.append(pin)
        saveModel()
        
        loadFlickrPhotosForPin(pin)
        
        return true
    }
    
    private func loadFlickrPhotosForPin(pin: Pin)
    {
//        FlickrClientManager.sharedInstance.getListFlickrPhotosForPin(pin) { (result, error) in
//            if error == nil {
//                self.addFlickrPhotos(result, forPin: pin)
//                self.downloadFlickrPhotosForPin(pin)
//            }
//        }
    }
    
    private func saveModel()
    {
        do{
            try stack.saveContext()
        }catch let error as NSError{
            print("couldn't save model \(error.userInfo)")
        }
    }
   
}
