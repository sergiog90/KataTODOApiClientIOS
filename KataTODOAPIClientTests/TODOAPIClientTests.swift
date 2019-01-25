//
//  TODOAPIClientTests.swift
//  KataTODOAPIClient
//
//  Created by Pedro Vicente Gomez on 12/02/16.
//  Copyright © 2016 Karumi. All rights reserved.
//

import Foundation
import Nimble
import XCTest
import Result
import OHHTTPStubs
@testable import KataTODOAPIClient

class TODOAPIClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        OHHTTPStubs.onStubMissing { request in
            XCTFail("Missing stub for \(request)")
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    fileprivate let apiClient = TODOAPIClient()
    fileprivate let anyTask = TaskDTO(userId: "1", id: "2", title: "Finish this kata", completed: true)

    //    func testSendsContentTypeHeader() {
    //        stub(condition: isMethodGET() &&
    //            isHost("jsonplaceholder.typicode.com") &&
    //            isPath("/todos")) { _ in
    //                return fixture(filePath: "", status: 200, headers: ["Content-Type":"application/json"])
    //        }
    //
    //        var result: Result<[TaskDTO], TODOAPIClientError>?
    //        apiClient.getAllTasks { response in
    //            result = response
    //        }
    //
    //        expect(result).toEventuallyNot(beNil())
    //    }

    func testParsesTasksProperlyGettingAllTheTasks() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                let stubPath = OHPathForFile("getTasksResponse.json", type(of: self))
                return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type":"application/json"])
        }

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.value?.count).toEventually(equal(200))
        assertTaskContainsExpectedValues((result?.value?[0])!)
    }

    func testReturnsNetworkErrorIfThereIsNoConnectionGettingAllTasks() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
                return OHHTTPStubsResponse(error: notConnectedError)
        }

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.networkError))
    }

    fileprivate func assertTaskContainsExpectedValues(_ task: TaskDTO) {
        expect(task.id).to(equal("1"))
        expect(task.userId).to(equal("1"))
        expect(task.title).to(equal("delectus aut autem"))
        expect(task.completed).to(beFalse())
    }
}

extension TODOAPIClientTests {

    //    GET /todos

    func testSendsValidHeadersAndVerbOnTodosRequest() {
        stub(condition: isMethodGET() &&
            hasHeaderNamed("Accept", value: "application/json") &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                let stubPath = OHPathForFile("getTasksResponse.json", type(of: self))
                return fixture(filePath: stubPath!, status: 500, headers: ["Content-Type":"application/json"])
        }


        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testGetAllTodosEmptyList() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                let stubPath = OHPathForFile("getTasksEmptyResponse.json", type(of: self))
                return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type":"application/json"])
        }

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }
        
        expect(result?.value?.count).toEventually(equal(0))
    }

    func testGetAllTodosReturn403() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                return fixture(filePath: "", status: 403, headers: nil)
        }

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 403)))
    }

    func testGetAllTodosReturn500() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                return fixture(filePath: "", status: 500, headers: nil)
        }

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
    }
}


extension TODOAPIClientTests {

    //    GET /todos/1

    func testSendsValidHeadersAndVerbOnSingleTodoRequest() {
        stub(condition: isMethodGET() &&
            hasHeaderNamed("Accept", value: "application/json") &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos/1")) { _ in
                return fixture(filePath: "", status: 500, headers: ["Content-Type":"application/json"])
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { (response) in
            result = response
        }
        expect(result).toEventuallyNot(beNil())
    }

    func testGetSingleTodoReturn404() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos/2")) { _ in
                return fixture(filePath: "", status: 404, headers: nil)
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("2") { (response) in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.itemNotFound))
    }

    func testGetSingleTodoReturn500() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos/1")) { _ in
                return fixture(filePath: "", status: 500, headers: nil)
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { (response) in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
    }

    func testGetSingleTodoItem() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos/1")) { (_) -> OHHTTPStubsResponse in
                let stubPath = OHPathForFile("getTaskByIdResponse.json", type(of: self))
                return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type":"application/json"])
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { (response) in
            result = response
        }

        expect(result?.value).toEventuallyNot(beNil())
        assertTaskContainsExpectedValues((result?.value)!)
    }

    func testGetSingleTodoItemWithMalformedJSON() {
        stub(condition: isMethodGET() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos/1")) { (_) -> OHHTTPStubsResponse in
                let stubPath = OHPathForFile("getTaskByIdResponseMalformed.json", type(of: self))
                return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type":"application/json"])
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { (response) in
            result = response
        }

        expect(result).toEventually(beNil())
    }
}


extension TODOAPIClientTests {

    //    PUT /todos/1

}


extension TODOAPIClientTests {

    //    DELETE /todos/1

}

extension TODOAPIClientTests {

    //    POST /todos
    /*
     Body
     */

    func testPostTodoWithBadRequest() {
        stub(condition: isMethodPOST() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                return fixture(filePath: "", status: 400, headers: nil)
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("", title: "", completed: true) { (response) in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 400)))
    }

    func testPostTodoResponse500() {
        stub(condition: isMethodPOST() &&
            isHost("jsonplaceholder.typicode.com") &&
            isPath("/todos")) { _ in
                return fixture(filePath: "", status: 500, headers: nil)
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("", title: "", completed: true) { (response) in
            result = response
        }
        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
    }

    func testPostTodo() {
        stub(condition: isMethodPOST() &&
            isHost("jsonplaceholder.typicode.com") &&
            hasJsonBody(["userId": "1",
                         "title": "delectus aut autem",
                         "completed": false]) &&
            isPath("/todos")) { _ in
                let stubPath = OHPathForFile("addTaskToUserResponse.json", type(of: self))
                return fixture(filePath: stubPath!, status: 201, headers: ["Content-Type":"application/json"])
        }

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { (response) in
            result = response
        }

        expect(result?.value).toEventuallyNot(beNil())
        assertTaskContainsExpectedValues(result!.value!)
    }

}
