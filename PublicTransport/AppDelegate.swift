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
    
    //private var startTime: Date?

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
        let currentLocation = Location.init(theLocation: lastloc, nearestBusStation: nil, time: NSDate(), currentSpeed: (manager.location?.speed)!, note: .none, delay: 0)
        significantLocations.addLocationIfSignificant(loc: currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func addBusDelays(_ locs: [Location]) -> [Location] {
        // should I cache?
        return locs
    }
    
    func saveToDefaults(_ locs: [Location]) {
        let updatedLocations = addBusDelays(locs)
        for location in updatedLocations {
            // add to persistent memory
            //defaults.set(<#T##value: Float##Float#>, forKey: <#T##String#>)
        }
    }
    
    func clearMemory() {
        
    }
}

