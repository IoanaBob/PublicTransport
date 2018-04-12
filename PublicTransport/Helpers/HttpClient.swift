//
//  HttpClient.swift
//  PublicTransport
//
//  Created by Ioana on 3/31/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

enum HttpMethod : String {
    case  GET
    case  POST
    case  DELETE
    case  PUT
}

struct ID:Codable {
    let id: Int
}

class HttpClientApi: NSObject{

    var request : URLRequest?
    var session : URLSession?
    
    static func instance() ->  HttpClientApi{
        return HttpClientApi()
    }
    
//    func makeAPICall(url: String,params: Dictionary<String, Any>?, method: HttpMethod, success: @escaping ( Data?, HTTPURLResponse?,  NSError? ) -> Void, failure: @escaping ( Data?, HTTPURLResponse?, NSError? )-> Void) {
//
//        request = URLRequest(url: URL(string: urlFor(url))!)
//
//        print("URL = \(url)")
//
//        if let params = params {
//            let  jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
//
//            request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request?.httpBody = jsonData
//        }
//        request?.httpMethod = method.rawValue
//
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 30
//        configuration.timeoutIntervalForResource = 30
//
//        session = URLSession(configuration: configuration)
//
//        session?.dataTask(with: request! as URLRequest) { (data, response, error) -> Void in
//            if let data = data {
//                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
//                    success(data , response , error as NSError?)
//                }
//                else {
//                    failure(data , response as? HTTPURLResponse, error as NSError?)
//                }
//            }
//            else {
//                failure(data , response as? HTTPURLResponse, error as NSError?)
//            }
//        }.resume()
//    }
    
    func postElement(url: String, params: Dictionary<String, Any>?, success: @escaping ( ID?, HTTPURLResponse?,  NSError? ) -> Void, failure: @escaping ( Data?, HTTPURLResponse?, NSError? )-> Void) {
        
        request = URLRequest(url: URL(string: urlFor(url))!)
        
        print("URL = \(url)")
        
        if let params = params {
            let  jsonData = try? JSONSerialization.data(withJSONObject: params)
            
            request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.httpBody = jsonData
        }
        request?.httpMethod = HttpMethod.POST.rawValue
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        session = URLSession(configuration: configuration)
        
        session?.dataTask(with: request! as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    //success(data , response , error as NSError?)
                    
                    let decoder = JSONDecoder()
                    do {
                        let stations = try decoder.decode(ID.self, from: data)
                        success(stations, response , nil)
                    } catch {
                        print(error)
                        success(nil, response, error as NSError?)
                    }
                }
                else {
                    failure(data , response as? HTTPURLResponse, error as NSError?)
                }
            }
            else {
                failure(data , response as? HTTPURLResponse, error as NSError?)
            }
        }.resume()
    }
    
    func getTimetable(atco: String, date: String, time: String, completionHandler: @escaping (Timetable?, Error?) -> Void) {
        let endpoint = urlFor("/timetable/" + atco + "/" + date + "/" + time)
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
                let items = try decoder.decode(Timetable.self, from: responseData)
                print("decoded JSON data")
                completionHandler(items, nil)
            } catch {
                print("error trying to convert data to JSON")
                print(error)
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
    
    func getPostcode(postcode: String, completionHandler: @escaping (Postcode?, Error?) -> Void) {
        let endpoint = "http://api.postcodes.io/postcodes/" + postcode
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
                let decodedData = try decoder.decode(Postcode.self, from: responseData)
                print("decoded JSON data")
                completionHandler(decodedData, nil)
            } catch {
                print("error trying to convert data to JSON")
                print(error)
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
    
    private func urlFor(_ path: String) -> String {
        return "https://gentle-falls-45144.herokuapp.com" + path
    }
}
