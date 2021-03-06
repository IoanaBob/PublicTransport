//
//  BusStop.swift
//  PublicTransport
//
//  Created by Ioana on 2/7/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

struct BusStop: Codable {
    let atcocode: String
    let mode: String
    let name: String
    let stop_name: String
    let smscode: String
    let bearing: String
    let locality: String
    let indicator: String
    let longitude: Float
    let latitude: Float
    let distance: Int
    
    func within25Meters() -> Bool{
        return distance <= 25
    }
}

struct BusStops:Codable {
    //let request_time: String
    let stops: [BusStop]
    
    static func endpointForBusStops(lat: Float, long: Float) -> String {
        return "https://transportapi.com/v3/uk/bus/stops/near.json?lat=" + String(lat) + "&lon=" + String(long) +  "&app_id=f67ffe61&app_key=84ead149046c88f0189b3763639d4d15"
        // ioana's key
        // key 1: 703b3fc0bc730dacf75e46ce7b9e9402
        // id 1: c12137e2
        //key 2: 84ead149046c88f0189b3763639d4d15
        //id 2: f67ffe61
    }
    
    // TODO: add global variable that states if the completion handler already doing a task, so 3 locations don't appear.
    static func allBusStops (lat: Float, long: Float, completionHandler: @escaping (BusStops?, Error?) -> Void) {
        let endpoint = BusStops.endpointForBusStops(lat: lat, long: long)
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
            let error = BackendError.urlError(reason: "Could not construct URL")
            completionHandler(nil, error)
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let responseData = data else {
                print("Error: did not receive data")
                completionHandler(nil, error)
                return
            }
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let stations = try decoder.decode(BusStops.self, from: responseData)
                print("decoded JSON data")
                completionHandler(stations, nil)
            } catch {
                print("error trying to convert data to JSON")
                print(error)
                completionHandler(nil, error)
            }
        }
        task.resume()
        Variables.requestingNearestBusStops = false
    }
}
