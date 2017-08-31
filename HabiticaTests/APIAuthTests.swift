//
//  APIAuthTests.swift
//  Habitica
//
//  Created by Craig Holliday on 8/18/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Alamofire
import Mockingjay
import Quick
import Nimble
import KeychainAccess
import NotificationCenter
@testable import Habitica

enum Stubs {
    static let loginStub = "LoginStub"
    static let registerStub = "RegisterStub"
}

class APIAuthTests: QuickSpec {
    
    var httpClient: HRPGAPI!
    
    override func spec() {
        super.spec()
        httpClient = HRPGAPI.shared
        describe("Login test") {
            context("success") {
                it("should log in successfully") {
//                    let path = Bundle(for: type(of: self)).path(forResource: Stubs.loginStub, ofType: "json")!
//                    
//                    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//                    
//                    self.stub(uri(Router.baseURLString + Endpoints.login), jsonData(data))

                    waitUntil(timeout: 2.5) { done in
                        let username = "fake73"
                        let password = "fakepassword"
                        self.httpClient.userLogin(username: username, password: password, onSuccess: { response in
                            // Test response does not equal nil
                            expect(response).toNot(beNil())
                            
                            // Test Notification to post
                            let testNotification = Notification(name: .userChanged, object: nil)
                            expect {
                                NotificationCenter.default.post(testNotification)
                                }.to(postNotifications(equal([testNotification])))
                            done()
                        }, onError: { error in
                            expect(error).to(beNil())
                            done()
                        })
                    }
                }
            }
            context("failure") {
                it("returns error") {
                    var returnedError: Error?
                    
                    let error = NSError(domain: "This is a test error", code: 404, userInfo: nil)

                    self.stub(uri(Router.baseURLString + Endpoints.login), failure(error))

                    let username = "fake73"
                    let password = "fakepassword"
                    self.httpClient.userLogin(username: username, password: password, onSuccess: { response in
                        expect(response).toEventuallyNot(beNil())
                    }, onError: { error in
                        returnedError = error
                    })
                    expect(returnedError).toEventuallyNot(beNil())
                    expect(returnedError as NSError?).toEventually(equal(error))
                }
            }
        }
        describe("Register User test") {
            context("success") {
                it("should register user successfully") {
                    let path = Bundle(for: type(of: self)).path(forResource: Stubs.registerStub, ofType: "json")!
                    
                    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                    
                    self.stub(uri(Router.baseURLString + Endpoints.register), jsonData(data))
                    
                    waitUntil(timeout: 2.5) { done in
                        let username = "fake73"
                        let password = "fakepassword"
                        let confirmpassword = "fakepassword"
                        let email = "fake73@fake.com"
                        self.httpClient.userRegister(username: username, password: password, confirmPassword: confirmpassword, email: email, onSuccess: { response in
                            // Test response does not equal nil
                            expect(response).toNot(beNil())
                            
                            done()
                        }, onError: { error in
                            print(error.localizedDescription,"ERROR")
                            expect(error).to(beNil())
                            done()
                        })
                    }
                }
            }
            context("failure") {
                it("returns error") {
                    var returnedError: Error?
                    
                    let error = NSError(domain: "This is a test error", code: 404, userInfo: nil)
                    
                    self.stub(uri(Router.baseURLString + Endpoints.register), failure(error))
                    
                    let username = "fake73"
                    let password = "fakepassword"
                    let confirmpassword = "fakepassword"
                    let email = "fake73@fake.com"
                    self.httpClient.userRegister(username: username, password: password, confirmPassword: confirmpassword, email: email, onSuccess: { response in
                        expect(response).toEventuallyNot(beNil())
                    }, onError: { error in
                        returnedError = error
                    })
                    expect(returnedError).toEventuallyNot(beNil())
                    expect(returnedError as NSError?).toEventually(equal(error))
                }
            }
        }
    }
}
