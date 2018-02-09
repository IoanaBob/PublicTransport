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
        let lastloc = locations.last
        if lastloc == nil {
            return
        }
        addSignificantLocation(manager: manager, location: lastloc!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    private func addSignificantLocation(manager: CLLocationManager , location: CLLocation) {
        print("user latitude = \(location.coordinate.latitude)")
        print("user longitude = \(location.coordinate.longitude)")
        print("speed = \(manager.location?.speed ?? 0)")
        let currentLocation = Location.init(coordinates: location, nearestBusStation: nil, time: NSDate(), currentSpeed: (manager.location?.speed)!)

        significantLocations.addLocationIfSignificant(loc: currentLocation)
//        BusStations.allBusStations(lat: Float(location.coordinate.latitude), long: Float(location.coordinate.longitude)) { (busStations, error) in
//            if let error = error {
//                // got an error in getting the data
//                print(error)
//                return
//            }
//            guard let busStations = busStations else {
//                print("error getting all: result is nil")
//                return
//            }
//            debugPrint(busStations.stops)
//        }
        // BusStations.getAllBusStations(lat: Float(location.coordinate.latitude), long: Float(location.coordinate.longitude))
        print("==============================")
    }
    

}

