//
//  TodoRouter.swift
//  StarWarsAlamofireAPI
//
//  Created by Craig Holliday on 8/16/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum TodoRouter: URLRequestConvertible {
    static let baseURLString = "https://swapi.co/api/"
    
    case get(Int)
    case create([String: Any])
    case delete(Int)
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            case .create:
                return .post
            case .delete:
                return .delete
            }
        }
        
        let params: ([String: Any]?) = {
            switch self {
            case .get, .delete:
                return nil
            case .create(let newTodo):
                return (newTodo)
            }
        }()
        
        let url: URL = {
            // build up and return the URL for each endpoint
            let relativePath: String?
            switch self {
            case .get(let number):
                relativePath = "people/\(number)"
            case .create:
                relativePath = "todos"
            case .delete(let number):
                relativePath = "todos/\(number)"
            }
            
            var url = URL(string: TodoRouter.baseURLString)!
            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            return url
        }()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()
        
        return try encoding.encode(urlRequest, with: params)
    }
}

public class API {
    typealias StarWarsPersonCallback = (StarWars_PersonEntity) -> Void
    typealias ErrorCallback = (Error) -> Void
    
    func printPeople() -> Void {
        let route = getPeopleRoute(search: "r2")
        let router = Router(route)
        Alamofire.request(router)
            .responseString { response in
                if let receivedString = response.result.value {
                    print(receivedString)
                }
        }
    }
    
    func alamofireGet(number: Int, onSuccess: StarWarsPersonCallback? = nil,
                      onError: ErrorCallback? = nil) {
        Alamofire.request(TodoRouter.get(number))
            .responseJSON { response in
                switch response.result {
                case .success:
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    onError?(response.result.error!)
                    return
                }
                
                // Check if object is found
                
                let object = StarWars_PersonEntity(JSON: json)
                onSuccess?(object!)

                case .failure(let error):
                    // check for errors
                    print(error, "HERE")
                    onError?(error)
                }
        }
    }
    
    func alamofirePost() {
        let newTodo: [String: Any] = ["title": "My First Post", "completed": 0, "userId": 1]
        Alamofire.request(TodoRouter.create(newTodo))
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling POST on /todos/1")
                    print(response.result.error!)
                    return
                }
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get todo object as JSON from API")
                    print("Error: \(response.result.error)")
                    return
                }
                // get and print the title
                guard let todoTitle = json["title"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                print("The title is: " + todoTitle)
        }
    }
    
    func alamofireDelete() {
        Alamofire.request(TodoRouter.delete(1))
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling DELETE on /todos/1")
                    print(response.result.error!)
                    return
                }
                print("DELETE ok")
        }
    }
    
//    func getEvents(createdAtBefore beforeDate: String = "") {
//        
//        let urlString = rootURL + Endpoints.eventsPoint
//        
//        var params = [String: String]()
//        params[Params.createdAtBefore] = beforeDate
//        
//        if FilterModel.allActiveCount() != 0 {
//            params[Params.startDate] = Date().startOfDay.iso8601String
//            //            params[Params.endDate] = Date().endOfDay.iso8601String
//            
//            for filter in FilterModel.getActiveFilterModelsOf(category: "Events") {
//                
//                if filter.attributeName == "startTimeDate" {
//                    params[Params.startDate] = filter.filterValue
//                    continue
//                }
//                if filter.attributeName == "endTimeDate" {
//                    params[Params.endDate] = filter.filterValue
//                    continue
//                }
//                
//                if filter.attributeName == "locationState" {
//                    let stateModel = StateModel.all().filter("abbreviation = %@", filter.filterValue!).first!
//                    params[Params.location] = stateModel.name
//                    continue
//                }
//                
//                params[filter.attributeName!] = filter.filterValue
//            }
//        }
//        
//        typealias model = EventModel
//        
//        Alamofire.request(urlString, method: .get, parameters: params).responseArray(keyPath: KeyPaths.data) { (response: DataResponse<[model]>) in
//            
//            switch response.result {
//            case .success:
//                let modelsArray = response.result.value
//                
//                guard let array = modelsArray else { return }
//                
//                for item in array {
//                    
//                    // Check if Achievement Model already exists
//                    let realm = try! Realm()
//                    let existingItem = realm.object(ofType: model.self, forPrimaryKey: item.key)
//                    
//                    if item.key != existingItem?.key {
//                        item.save()
//                    }
//                    else {
//                        // Nothing needs be done.
//                    }
//                }
//            case .failure(let error):
//                log.error(error)
//                Tracker.logGeneralError(error: error)
//            }
//        }
//    }
}

import ObjectMapper

class StarWars_PersonEntity: Mappable {
    //Impl. of Mappable protocol
    required convenience public init?(map: Map) {
        self.init()
    }

    var name: String! = nil
    var height: String! = nil
    var mass: String! = nil
    var hair_color: String! = nil
    var skin_color: String! = nil
    var eye_color: String! = nil
    var birth_year: String! = nil
    var gender: String! = nil
    var homeworld: String! = nil
    var films: [Any]? = nil
    var species: [Any]? = nil
    var vehicles: [Any]? = nil
    var starships: [Any]? = nil
    
    // Arrays
    var created: String! = nil
    var edited: String! = nil
    var url: String! = nil
    
    // Mappable
    public func mapping(map: Map) {
        name <- map["name"]
        height <- map["height"]
        mass <- map["mass"]
        hair_color <- map["hair_color"]
        skin_color <- map["skin_color"]
        eye_color <- map["eye_color"]
        birth_year <- map["birth_year"]
        gender <- map["gender"]
        homeworld <- map["homeworld"]
        films <- map["films"]
        species <- map["species"]
        vehicles <- map["vehicles"]
        starships <- map["starships"]
        created <- map["created"]
        edited <- map["edited"]
        url <- map["url"]
    }
}
