//
//  AppDelegate.swift
//  PublicTransport
//
//  Created by Ioana Surdu-Bob on 05/02/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    
    var locationManager = CLLocationManager()
    var significantLocations = Locations()
    let defaults = UserDefaults.standard
    let helper = LocationsHelper()
    
    private var startTime: Date?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        determineCurrentLocation()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        determineCurrentLocation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0 {
            return
        }
        guard let lastloc = locations.last else { return }
        
        print("user latitude = \(lastloc.coordinate.latitude)")
        print("user longitude = \(lastloc.coordinate.longitude)")
        print("speed = \(manager.location?.speed ?? 0)")
        print("==============================")
        
        // create two inits for cleaner initializations - nearestbus, note, delay not necessary
        let currentLocation = Location.init(lat: lastloc.coordinate.latitude, long: lastloc.coordinate.longitude, currentSpeed: (manager.location?.speed)!)
        significantLocations.addLocationIfSignificant(loc: currentLocation)
        if significantLocations.locations.count > 100 {
            saveToDefaults()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
//    func addBusDelays(_ locs: [Location]) -> [Location] {
//        // should I cache?
//        return locs
//    }
    
    func saveToDefaults() {
        // TODO: Use maxspeed from all locations after the last stop
        //let updatedLocations = addBusDelays(locs)
        var busStopTimes = helper.loadObjectArray(forKey: "busStopTimes")
        let locs = self.significantLocations.hasLeftBusAt()
        for location in locs {
            // add to persistent memory
            switch location.note {
            case .leftStation:
                // take current location
                busStopTimes.append(location)
            case .arrivedStation:
                guard let nextLocation = locs.item(after: location) else { return }
                if nextLocation.note == .leftStation {
                    // do nothing
                    break
                }
                else {
                    // take current location
                    busStopTimes.append(location)
                }
            case .none: break // do nothing
            }
        }
        // encoding complex objects so it can be saved in phone storage
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(busStopTimes){
            UserDefaults.standard.set(encoded, forKey: "busStopTimes")
        }
        // emptying locations because we don't need them anymore
        if !locs.isEmpty {
            self.significantLocations.locations = [locs.last!]
        }
    }
    

    
}
