//
//  BTouristMapViewViewViewController.swift
//  TouristHelper
//
//  Created by Simon Smiley-Andrews on 27/09/2017.
//  Copyright © 2017 Simon Smiley-Andrews. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class BTouristMapViewViewViewController: UIViewController, newLocationsDelegate {

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var previousLocation: CLLocation!
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    let regionRadius: CLLocationDistance = 1000
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Tourist Map"
        self.tabBarItem.image = UIImage(named: "icn_30_map.png")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self;
    
        BNearbyMapsManager.sharedInstance.delegate = self;
        
        self.edgesForExtendedLayout = [] // equivalent to rectEdgeNone
        
        self.locationLabel.text = ""
        self.updateLocationLabel()
    }
    
    func returnNewLocations(locations: NSArray) {
        
        // This is called when some new locations are found
        // We want to have a maximum of 60 locations showing on the map
        // This means if we get more locations we start replacing the old ones
        
        // First we want to place some things on the map for each location
        // We might want to create a new class so we can eaily deal with the locations
        
        // First though just add them to the map
        
        // We loop through the results in our array then plot each one on the map
        for i in 0 ... locations.count - 1 {
            
            let dict = locations[i] as! NSDictionary;
            
            let geometry = dict["geometry"] as! NSDictionary
            let coordinates = geometry["location"] as! NSDictionary
            
            let longitude = coordinates["lng"] as! CLLocationDegrees
            let latitude = coordinates["lat"] as! CLLocationDegrees
            
            let itemLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let marker = GMSMarker(position: itemLocation)
            marker.title = dict["name"] as? String
            marker.map = mapView
        }
    }
    
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//    }
    
//    func centreMapToLocation(location: CLLocation) {
//
////        let coordinates = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
////        mapView?.setRegion(coordinates, animated: true)
//    }

    
    
    // Use this to set the address at the bottom of the screen
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            
            if let address = response?.firstResult() {
                
                // We want to add the address to the top of the page
                //let lines = address.lines as! [String]
                
                var addressString = String()
                
                for String in address.lines! {
                    addressString = addressString + " " + String
                }
                
                self.locationLabel.text = addressString
                self.updateLocationLabel()
            }
        }
    }
    
    func updateNearbyLocations(currentLocation: CLLocation) {
        
        BNearbyMapsManager.sharedInstance.getNearbyLocationsWithLocation(location: currentLocation)
    }
    
    func updateLocationLabel() {
        UIView.animate(withDuration: 0.2, animations: {
            self.locationLabel.alpha = self.locationLabel.text?.count == 0 ? 0.0 : 0.7
        })
    }
}

extension BTouristMapViewViewViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // We want to refresh the nearby locations when we move a certain distance away from our update location
            // We want to call this once we are far enough away from the last search point
            
            // If either of our locations are nil then this is the first time it is being loaded up so we want to get the nearby locations
            if (previousLocation == nil || currentLocation == nil) {
                previousLocation = location
                currentLocation = location
                
                self.updateNearbyLocations(currentLocation: location)
            }
            
            if currentLocation.distance(from: previousLocation) > 100 {
             
                previousLocation = currentLocation
                currentLocation = location
                
                self.updateNearbyLocations(currentLocation: location)
            }
            
            locationManager.stopUpdatingLocation()
        }
    }
}

extension BTouristMapViewViewViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        
        // We have dragged the map
        
        print("Dragged")
        
    }
}


// Fancy map stuff I can use

// Set the camera position of the map
//        let sydney = GMSCameraPosition.camera(withLatitude: -33.8683, longitude: 151.2086, zoom: 6)
//        mapView.camera = sydney

// Change viewing angle:
//mapView.animate(toViewingAngle: 45)

//        let fancy = GMSCameraPosition.camera(withLatitude: -33,
//                                             longitude: 151,
//                                             zoom: 6,
//                                             bearing: 270,
//                                             viewingAngle: 45)
//
//        mapView.camera = fancy

//        let camera = GMSCameraPosition.camera(withLatitude: -33.8683, longitude: 151.2086, zoom: 16)
//        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)



// Animate to a specific location - we could always use a search feature to add that in?
//mapView.animate(toLocation: CLLocationCoordinate2D(latitude: -33.868, longitude: 151.208))


// Zooming in and out
//mapView.animate(toZoom: 12)

// Min and Max zoom
// mapView.setMinZoom(10, maxZoom: 15)

// This will let us know we are looking at the correct area around us in terms of radius
//        let vancouver = CLLocationCoordinate2D(latitude: 49.26, longitude: -123.11)
//        let calgary = CLLocationCoordinate2D(latitude: 51.05,longitude: -114.05)
//        let bounds = GMSCoordinateBounds(coordinate: vancouver, coordinate: calgary)
//        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
//        mapView.camera = camera



// Good info on drawing on the map etc
// https://developers.google.com/maps/documentation/ios-sdk/views


//        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
//        self.centreMapToLocation(location: initialLocation)
//
//        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.requestWhenInUseAuthorization()

//        if CLLocationManager.locationServicesEnabled() {
//
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.startUpdatingLocation()
//        }
