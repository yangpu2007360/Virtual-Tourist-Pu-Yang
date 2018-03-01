//
//  ViewController.swift
//  Virtual Tourist, Pu Yang
//
//  Created by pu yang on 2/27/18.
//  Copyright © 2018 pu yang. All rights reserved.
//

import UIKit
import MapKit

class FlickrMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var flickrMapView: MKMapView!
    var isEditingPins = false
    var annotations = [MKPointAnnotation]()
    let stack = CoreDataStack(modelName: "VirtualTouristModel")!
    var mapPins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrMapView.delegate = self
        reloadPins()
    }
    
    //MARK: - Loading Pins
    func reloadPins()
    {
        flickrMapView.removeAnnotations(annotations)
        annotations.removeAll()
        guard VirtualTouristManager.sharedInstance.mapPins.count != 0 else {
            return
        }
        for index in 0...VirtualTouristManager.sharedInstance.mapPins.count-1 {
            let lat = CLLocationDegrees(VirtualTouristManager.sharedInstance.getMapPinAtIndex(index: index)!.latitude)
            let long = CLLocationDegrees(VirtualTouristManager.sharedInstance.getMapPinAtIndex(index: index)!.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        self.flickrMapView.addAnnotations(self.annotations)
    }
    
    @IBAction func hangleLongPress(getstureRecognizer: UILongPressGestureRecognizer) {
        
        if !isEditingPins {
            if getstureRecognizer.state != .began { return }
            
            let touchPoint = getstureRecognizer.location(in: flickrMapView)
            let touchMapCoordinate = flickrMapView.convert(touchPoint, toCoordinateFrom: flickrMapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            
            flickrMapView.addAnnotation(annotation)
            VirtualTouristManager.sharedInstance.addMapPin(coord: touchMapCoordinate)
            annotations.append(annotation)
        }
    }

 
    


}

