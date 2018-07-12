//
//  ViewController.swift
//  MapKitDemo
//
//  Created by DP Bhatt on 10/07/2018.
//  Copyright © 2018 Sensus ApS. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var theMap: MKMapView!
    
    var locationManager: CLLocationManager!
    var fixedLocation : CLLocation!
    var latestLocation : CLLocation!
    
    
    @IBOutlet weak var fixPositionLatitude: UILabel!
    @IBOutlet weak var fixPositionLongitude: UILabel!
    @IBOutlet weak var latestLocationLatitude: UILabel!
    @IBOutlet weak var latestLocationLongitude: UILabel!
    
    @IBOutlet weak var distanceInMeter: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // 1.
        theMap.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.last != nil && (locations.last?.horizontalAccuracy)! > 0.0) {
            latestLocation = locations.last!
        }
        
        if(fixedLocation != nil){
            
            // 2.
            //let sourceLocation = CLLocationCoordinate2D(latitude: 40.759011, longitude: -73.984472)
            //let destinationLocation = CLLocationCoordinate2D(latitude: 40.748441, longitude: -73.985564)
            let destinationLocation = CLLocationCoordinate2D(latitude: fixedLocation.coordinate.latitude, longitude: fixedLocation.coordinate.longitude)
            let sourceLocation = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
            
            // 3.
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            // 4.
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            

            
            // 5.
            let sourceAnnotation = MKPointAnnotation()
            sourceAnnotation.title = "Source"
            
            if let location = sourcePlacemark.location {
                sourceAnnotation.coordinate = location.coordinate
            }
            
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.title = "Destination"
            
            if let location = destinationPlacemark.location{
                destinationAnnotation.coordinate = location.coordinate
            }
            
            // 6
            //self.theMap.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
            self.theMap.showAnnotations([ destinationAnnotation], animated: true)
            
            // 7.
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .any
            
            // Calculate the direction
            let directions = MKDirections(request: directionRequest)
            
            // 8.
            directions.calculate(completionHandler: {(response, error) in
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                let route = response.routes[0]
                self.theMap.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.theMap.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                
                
                self.distanceInMeter.text = "\(route.distance) m"
            })
            
            
            latestLocationLatitude.text = "\(latestLocation.coordinate.latitude)"
            latestLocationLongitude.text = "\(latestLocation.coordinate.longitude)"
        }
    }
    
    @IBAction func setFixPosition(_ sender: UIButton) {
        if(locationManager.location != nil && (locationManager.location?.horizontalAccuracy)! >  0.0){
            fixedLocation = locationManager.location
            
            fixPositionLatitude.text = "\(fixedLocation.coordinate.latitude)"
            fixPositionLongitude.text = "\(fixedLocation.coordinate.longitude)"
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
}
