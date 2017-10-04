//
//  BLocationManager.swift
//  TouristHelper
//
//  Created by Simon Smiley-Andrews on 27/09/2017.
//  Copyright © 2017 Simon Smiley-Andrews. All rights reserved.
//

import UIKit
import CoreLocation

protocol newLocationsDelegate {
    
    // We want to return locations which have been found
    func returnNewLocations(locations: NSArray);
}

class BNearbyMapsManager: NSObject {
    
    var delegate: newLocationsDelegate? = nil
    
    var locations = NSMutableArray()
    
    // We want to have access to the root search URL so we can add new pages onto it
    var rootSearchURL = String()
    
    class var sharedInstance: BNearbyMapsManager {
        struct singleton {
            static let instance = BNearbyMapsManager()
        }
        return singleton.instance
    }
    
    func sendNewLocations(locations: NSArray) {
        if delegate != nil && locations.count > 0 {
            delegate?.returnNewLocations(locations: locations)
        }
    }
    
    public func getNearbyLocationsWithLocation(location: CLLocation) -> NSArray {
        
        //let urlString : String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDcsfSjTpEFHt_tUSHoqnVzPocXsP8qB00&location=49.26,-123.11&radius=1000"

        let urlString : String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDcsfSjTpEFHt_tUSHoqnVzPocXsP8qB00&location="
        
        let latitude:String = "\(location.coordinate.latitude)"
        let longitude:String = "\(location.coordinate.longitude)"
        
        let newString = urlString + latitude + "," + longitude + "&radius=1000"
        
        rootSearchURL = newString
        
        let url = URL(string: newString)

        self.getAllNearbyLocations(url: url!)
        
        return []
    }
    
    // This function loops over the returned JSON until we have recevied all the info
    //func getAllNearbyLocations(url: URL, completion: ((NSArray) -> ())?) {
        
    func getAllNearbyLocations(url: URL) {
        
        self.getJsonFromURL(url: url) { (dictionary) in
            
            print("Added")
            
            let newLocations: NSArray = dictionary.value(forKey: "results") as! NSArray
            self.locations.addObjects(from: newLocations as! [Any])
            
            print("Set")
            
            // TODO Remove this check
            if self.locations.count >= 60 {
                //self.sendNewLocations(locations: self.locations)
            }
            else {
                
                // We want to now update the URL we are using and search again
                if let newPageToken = dictionary["next_page_token"] {
                    
                    let newURL = self.rootSearchURL + "&pagetoken=" + (newPageToken as! String)
                    let url = URL(string: newURL)
                    
                    // We want to get our current URL and remove the last characters from it
                    self.getAllNearbyLocations(url: url!)
                }
                else {
                    
                    // If we have no more pages then we return what we have
                    //self.sendNewLocations(locations: self.locations)
                }
            }
        }
    }
    
    // This function returns the JSON from a specific URL
    func getJsonFromURL(url: URL, completionHandler: @escaping (NSDictionary) -> ()) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("error")
            }
            else {
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        let newLocations: NSArray = myJson.value(forKey: "results") as! NSArray
                        self.sendNewLocations(locations: newLocations)
                        
                        
                        completionHandler(myJson)
                    }
                    catch {
                        print("error")
                    }
                }
            }
        }
        
        
        
        task.resume()
    }
}
