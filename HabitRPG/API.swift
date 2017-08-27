//
//  HRPGAPI.swift
//  Habitica
//
//  Created by Craig Holliday on 8/18/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainSwift

enum KeychainKeys {
    static let userid = "id"
    static let apiToken = "apiToken"
}

enum JSONKeys {
    static let data = "data"
    static let id = "id"
    static let apiToken = "apiToken"
}

enum APIErrors: Error {
    case jsonConversionError
    case errorWithNoErrorResponse
}

public class HRPGAPI {
    typealias StarWarsPersonCallback = (JSON) -> Void
    typealias SuccessCallback = (Bool) -> Void
    typealias ErrorCallback = (Error) -> Void
    
    func userLogin(username: String,
                   password: String,
                   onSuccess: SuccessCallback? = nil,
                   onError: ErrorCallback? = nil) {
        let route = UserLoginRoute(username: username, password: password)
        let router = Router(route)
        Alamofire.request(router)
            .responseJSON { response in
                switch response.result {
                case .success:
                // make sure we got some JSON since that's what we expect
                guard let jsonData = response.result.value as? [String: Any] else {
                    guard let errorResponse = response.result.error else {
                        onError?(APIErrors.errorWithNoErrorResponse)
                        return }
                    onError?(errorResponse)
                    return
                }
                
                let json = JSON(jsonData)
                guard let id = json[JSONKeys.data][JSONKeys.id].string
                    else {
                        onError?(APIErrors.jsonConversionError)
                        return }
                guard let apiToken = json[JSONKeys.data][JSONKeys.apiToken].string
                    else {
                        onError?(APIErrors.jsonConversionError)
                        return }
                let keychain = KeychainSwift()
                keychain.set(id, forKey: KeychainKeys.userid)
                keychain.set(apiToken, forKey: KeychainKeys.apiToken)

                NotificationCenter.default.post(name: .userChanged, object: nil)
                onSuccess?(true)

                case .failure(let error):
                    // check for errors
                    onError?(error)
                }
        }
    }
    
    func userRegister(username: String,
                      password: String,
                      confirmPassword: String,
                      email: String,
                      onSuccess: SuccessCallback? = nil,
                      onError: ErrorCallback? = nil) {
        let route = UserRegisterRoute(username: username, password: password, confirmPassword: password, email: email)
        let router = Router(route)
        Alamofire.request(router)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // make sure we got some JSON since that's what we expect
                    guard let jsonData = response.result.value as? [String: Any] else {
                        guard let errorResponse = response.result.error else {
                            onError?(APIErrors.errorWithNoErrorResponse)
                            return }
                        onError?(errorResponse)
                        return
                    }
                    
                    let json = JSON(jsonData)
                    guard let id = json[JSONKeys.data][JSONKeys.id].string
                        else {
                            onError?(APIErrors.jsonConversionError)
                            return }
                    guard let apiToken = json[JSONKeys.data][JSONKeys.apiToken].string
                        else {
                            onError?(APIErrors.jsonConversionError)
                            return }
                    let keychain = KeychainSwift()
                    keychain.set(id, forKey: KeychainKeys.userid)
                    keychain.set(apiToken, forKey: KeychainKeys.apiToken)
                    
                    NotificationCenter.default.post(name: .userChanged, object: nil)
                    onSuccess?(true)
                    
                case .failure(let error):
                    // check for errors
                    onError?(error)
                }
        }
    }
//
//    func alamofirePost() {
//        let newTodo: [String: Any] = ["title": "My First Post", "completed": 0, "userId": 1]
//        Alamofire.request(TodoRouter.create(newTodo))
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    // got an error in getting the data, need to handle it
//                    print("error calling POST on /todos/1")
//                    print(response.result.error!)
//                    return
//                }
//                // make sure we got some JSON since that's what we expect
//                guard let json = response.result.value as? [String: Any] else {
//                    print("didn't get todo object as JSON from API")
//                    print("Error: \(response.result.error)")
//                    return
//                }
//                // get and print the title
//                guard let todoTitle = json["title"] as? String else {
//                    print("Could not get todo title from JSON")
//                    return
//                }
//                print("The title is: " + todoTitle)
//        }
//    }
//    
//    func alamofireDelete() {
//        Alamofire.request(TodoRouter.delete(1))
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    // got an error in getting the data, need to handle it
//                    print("error calling DELETE on /todos/1")
//                    print(response.result.error!)
//                    return
//                }
//                print("DELETE ok")
//        }
//    }
    
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

class StarWarsPersonEntity: Mappable {
    //Impl. of Mappable protocol
    required convenience public init?(map: Map) {
        self.init()
    }

    var name: String! = nil
    var height: String! = nil
    var mass: String! = nil
    var hairColor: String! = nil
    var skinColor: String! = nil
    var eyeColor: String! = nil
    var birthYear: String! = nil
    var gender: String! = nil
    var homeworld: String! = nil
    var films: [Any]! = nil
    var species: [Any]! = nil
    var vehicles: [Any]! = nil
    var starships: [Any]! = nil
    
    // Arrays
    var created: String! = nil
    var edited: String! = nil
    var url: String! = nil
    
    // Mappable
    public func mapping(map: Map) {
        name <- map["name"]
        height <- map["height"]
        mass <- map["mass"]
        hairColor <- map["hair_color"]
        skinColor <- map["skin_color"]
        eyeColor <- map["eye_color"]
        birthYear <- map["birth_year"]
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
