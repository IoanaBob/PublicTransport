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
    var savedLocations = Locations()
    
    private var startTime: Date?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(rgb: 0x2c3e50)]
        navBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(rgb: 0x2c3e50)]
        navBarAppearance.barTintColor = UIColor(rgb: 0xFBF6DF)
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = UIColor(rgb: 0xFBF6DF)
        tabBarAppearance.tintColor = UIColor(rgb: 0x16a085)
        tabBarAppearance.unselectedItemTintColor = UIColor.gray
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
        locationManager.distanceFilter = 5
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
        let currentLocation = Location.init(lat: Float(lastloc.coordinate.latitude), long: Float(lastloc.coordinate.longitude), currentSpeed: Float((manager.location?.speed)!))
        savedLocations.addLocationIfSignificant(loc: currentLocation)
        if savedLocations.locations.count > 100 {
            savedLocations.addToDB()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
