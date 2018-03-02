//
//  FlickrClientManager.swift
//  Virtual Tourist
//
//  Created by Yan Zverev on 8/18/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation

class FlickrClientManager
{
    //MARK: - Initilization
    static let sharedInstance = FlickrClientManager()
 
    var session = URLSession.shared
    
    private init()
    {
        //super.init()
    }
    
    
    func getListFlickrPhotosForPin(pin: Pin!, completionHandlerForGetListFlickrPhotosForLocation: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        var parameters: [String : AnyObject] = [FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod as AnyObject, FlickrParameterKeys.Latitude : pin.latitude as AnyObject, FlickrParameterKeys.Longitude : pin.longitude as AnyObject, FlickrParameterKeys.Accuracy : FlickrParameterValues.Accuracy as AnyObject]
        
        //Will randomize the page that is returned for flicker to get new collections
        if pin.pages != nil {
            let randomPage = Int(arc4random_uniform(UInt32((min((pin.pages.intValue)!,Int32(30)))))) + 1
            parameters[FlickrParameterKeys.Page] = randomPage
        }
                
        taskForGetMethod(method: nil, parameters: parameters, completionHanderForGet: completionHandlerForGetListFlickrPhotosForLocation)
        
    }
   
    func getListFlickrPhotosForLocation(lat: Double!, long: Double!, completionHandlerForGetListFlickrPhotosForLocation: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        let parameters = [FlickrParameterKeys.Method : FlickrParameterValues.SearchMethod, FlickrParameterKeys.Latitude : lat, FlickrParameterKeys.Longitude : long] as [String : Any]
        
        taskForGetMethod(method: nil, parameters: parameters as? [String : AnyObject], completionHanderForGet: completionHandlerForGetListFlickrPhotosForLocation)
        
    }
    
    func getImageURL(flickrImageDict: [String : AnyObject]) -> String
    {
        let imageURL = "https://farm\(flickrImageDict[FlickrImageParameterKeys.FarmID]!).staticflickr.com/\(flickrImageDict[FlickrImageParameterKeys.ServerID]!)/\(flickrImageDict[FlickrImageParameterKeys.ImageID]!)_\(flickrImageDict[FlickrImageParameterKeys.Secret]!)_z.jpg"
        return imageURL
    }

}


//MARK: Network Convinience Methods

extension FlickrClientManager
{
    // MARK: Network Convinience Methods
    
    func taskForGetMethod(method: String?, parameters: [String : AnyObject]?, completionHanderForGet: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask
    {
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters: parameters, withPathExtension: method) as URL)
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHanderForGet(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                sendError(error: "Your Request returned a status code other then 2xx!")
                return
            }
            
            guard data != nil else{
                sendError(error: "No data was returned by the request")
                return
            }
            
            self.convertDataWithCompletionHander(data: data! as NSData, completionHanderForConvertData: completionHanderForGet)
            
        
        }
        
        task.resume()
        return task
    }
    
    
    
    
    private func flickrURLFromParameters(parameters: [String : AnyObject]?, withPathExtension: String? = nil) -> NSURL
    {
        let components = NSURLComponents()
        
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]() as [URLQueryItem]
        
        components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.API_KEY, value: FlickrParameterValues.API_KEY) as URLQueryItem)
        components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.NoJSONCallBack, value: FlickrParameterValues.NoJSONCallBack) as URLQueryItem)
        components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.Format, value: FlickrParameterValues.Format) as URLQueryItem)
        components.queryItems!.append(NSURLQueryItem(name: FlickrParameterKeys.LimitPerPage, value: FlickrParameterValues.LimitPerPage) as URLQueryItem)
        

        if let parameters = parameters {
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem as URLQueryItem)
            }
        }
        
        
        return components.url! as NSURL
    }
    
    func downloadFlickrImageFromURL(url: String, completionHandlerForDownloadFlickrImage:@escaping (_ data: NSData?, _ response: URLResponse?, _ error: NSError?) -> Void)
    {
        let imageURL = NSURL(string: url)
        
        URLSession.shared.dataTask(with: imageURL! as URL) { (data, response, error) in
            
            completionHandlerForDownloadFlickrImage(data as NSData?,response, error as NSError?)
        
        }.resume()
        
    }

    private func convertDataWithCompletionHander(data: NSData, completionHanderForConvertData:(_ resutl: AnyObject?, _ error: NSError?) -> Void)
    {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse data as JSON: '\(data)'"]
            completionHanderForConvertData(nil, NSError(domain: "convertDataWithCompletionHander", code: 1, userInfo: userInfo))
        }
        
        completionHanderForConvertData(parsedResult, nil)
    }
    

}
