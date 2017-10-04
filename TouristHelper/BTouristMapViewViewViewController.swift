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

    var currentLocation: CLLocation! // This is our current location
    var previousLocation: CLLocation! // If we change location this is our previous location
    
    let locationManager = CLLocationManager() // Manage our location
    
    // We can store our map line - this makes it easier to move and access
    var mapRouteLine = GMSPolyline()
    
    // Store the location coordinates of the nearby locations
    var locationCoordinates = NSMutableArray()
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var mapRouteButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Tourist Map"
        self.tabBarItem.image = UIImage(named: "icn_30_map.png")
    }
    
    // TODO remove after testing
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.plotPathBetweenLocations(locations: locationCoordinates)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self;
    
        BNearbyMapsManager.sharedInstance.delegate = self;
        
        // Only show the location label if we know our current location and address
        self.updateLocationLabel(text: "")
        
        // Customise the map route toggle button
        mapRouteButton.layer.borderWidth = 0.5
        mapRouteButton.layer.borderColor = UIColor.lightGray.cgColor
        
        mapRouteButton.layer.shadowColor = UIColor.black.cgColor
        mapRouteButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        mapRouteButton.layer.shadowRadius = 2
        mapRouteButton.layer.shadowOpacity = 0.7
    }
    
    // This is a delegate method for returning new locations from the NearbyMapsManager
    func returnNewLocations(locations: NSArray) {
        
        // Clear our arrays and reset the map
        locationCoordinates.removeAllObjects()
        mapView.clear()
        
        // We loop through the results in our array then plot each one on the map
        for i in 0 ... locations.count - 1 {
            
            let dict = locations[i] as! NSDictionary;
            
            let geometry = dict["geometry"] as! NSDictionary
            let coordinates = geometry["location"] as! NSDictionary
            
            let longitude = coordinates["lng"] as! CLLocationDegrees
            let latitude = coordinates["lat"] as! CLLocationDegrees
            
            let itemLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            locationCoordinates.addObjects(from: [itemLocation])
            
            let marker = GMSMarker(position: itemLocation)
            marker.title = dict["name"] as? String
            marker.map = mapView
        }
    }
    
    func updateNearbyLocations(currentLocation: CLLocation) {
        
        BNearbyMapsManager.sharedInstance.getNearbyLocationsWithLocation(location: currentLocation)
    }
    
    func plotPathBetweenLocations(locations: NSMutableArray) {
        
        // Remove the current map 
        mapRouteLine.map = nil

        if locationCoordinates.count != 0 {
            
            locationCoordinates = self.filterLocationArray(locationCoordinates: locationCoordinates)

            let path = GMSMutablePath()

            // First we want to add a path from our current location
            path.add(currentLocation.coordinate)

            for i in 0 ... locationCoordinates.count - 1 {
                let location = locationCoordinates[i] as! CLLocationCoordinate2D
                path.add(location)
            }

            // Finally we want to finish in our current location
            path.add(currentLocation.coordinate)

            mapRouteLine = GMSPolyline(path: path)
            mapRouteLine.map = mapView
        }
    }
    
    // Try the nearest neighbour approach
    func filterLocationArray(locationCoordinates: NSMutableArray) -> NSMutableArray {
        
        // We want to loop through and see which one is closest to where we currently are
        // Then take that and loop through all the ones currently closest to that one, remove that one and continue
        
        // We start at our current location
        var nearestLocation = currentLocation
        let filteredArray = NSMutableArray()
        
        let locationsToCheck = locationCoordinates.mutableCopy() as! NSMutableArray
        
        // We loop through once so we know we will get through each point
        for _ in 0 ... locationCoordinates.count - 1 {
            
            var smallestDistance = CLLocationDistance()
            var newLocation = CLLocationCoordinate2D()
            
            // We loop through again to make sure we check each ite in the array
            for j in 0 ... locationsToCheck.count - 1 {
                
                // We want to check how far away this is from our current location
                let location = locationsToCheck[j] as! CLLocationCoordinate2D
                let locationPoint = CLLocation(latitude: location.latitude, longitude: location.longitude)
                
                // Get the distance of this point from our nearest point
                let distance = locationPoint.distance(from: nearestLocation!)
                
                // Now we update to keep track of our nearest member
                if distance < smallestDistance || smallestDistance.isZero {
                    smallestDistance = distance
                    newLocation = location
                }
            }
            
            // Now we have looped through
            filteredArray.addObjects(from: [newLocation])
            locationsToCheck.remove(newLocation)
            nearestLocation = CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
        }
        
        return filteredArray
    }
    
    func updateLocationLabel(text: String) {
        
        self.locationLabel.text = text
        
        UIView.animate(withDuration: 0.2, animations: {
            self.locationLabel.alpha = self.locationLabel.text?.count == 0 ? 0.0 : 0.7
        })
    }
    
    // Use this to set the address at the bottom of the screen
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            
            if let address = response?.firstResult() {
                
                var addressString = String()
                
                // Concatinate the lines of the address into a single string
                for String in address.lines! {
                    addressString = addressString + " " + String
                }
                
                self.updateLocationLabel(text: addressString)
            }
        }
    }
    
    @IBAction func mapRouteButtonPressed(sender: UIButton) {
        
        // We want to check if the map is being shown if not then we add it and update the background image
        if mapRouteLine.map != nil {
            // This means we currently have a map route - we remove it and change the icon
            
            mapRouteLine.map = nil
            mapRouteButton.setBackgroundImage(UIImage.init(named: "icn_52_route.png"), for: .normal)
        }
        else {
            
            if locationCoordinates.count == 0 {
                
                // This occurs if the user presses the button before our locations have been retreived
                let alert = UIAlertController(title: "Careful", message: "We can't show the map before the locatons have been retreived", preferredStyle: .alert)
            
                alert.addAction(UIAlertAction(title: "Ok, sorry", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            else {

                self.plotPathBetweenLocations(locations: locationCoordinates)
                mapRouteButton.setBackgroundImage(UIImage.init(named: "icn_52_noRoute.png"), for: .normal)
            }
        }
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
                
                mapView.animate(toLocation: location.coordinate)
                
                self.updateNearbyLocations(currentLocation: location)
            }
            
            // We want a previous location variable as we don't want to update the nearby locations regularly
            // If the user doesn't move far away enough there is no point
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
}


// Addition map functionality to potentially use

// Set the camera position of the map
// let sydney = GMSCameraPosition.camera(withLatitude: -33.8683, longitude: 151.2086, zoom: 6)
// mapView.camera = sydney

// Change viewing angle:
//mapView.animate(toViewingAngle: 45)

// let fancy = GMSCameraPosition.camera(withLatitude: -33,
//                                             longitude: 151,
//                                             zoom: 6,
//                                             bearing: 270,
//                                             viewingAngle: 45)
//
// mapView.camera = fancy

// let camera = GMSCameraPosition.camera(withLatitude: -33.8683, longitude: 151.2086, zoom: 16)
// mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)

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
