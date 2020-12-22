//
//  WeatherMateTests.swift
//  WeatherMateTests
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import XCTest
@testable import WeatherMate

class WeatherMateTests: XCTestCase {

    var sut: URLSession!
    
    override func setUp() {
      super.setUp()
      sut = URLSession(configuration: .default)
    }
    
    override func tearDown() {
      sut = nil
      super.tearDown()
    }
    
    // Asynchronous test: success fast, failure slow
    func testValidCallToOpenWeatheGetsHTTPStatusCode200() {
      // given
        guard let getURL = URL(string:  String(format:"%@10d@2x.png",pathURL.imagePath)) else { return }
       // 1
      let promise = expectation(description: "Status code: 200")
      
      // when
      let dataTask = sut.dataTask(with: getURL) { data, response, error in
        // then
        if let error = error {
          XCTFail("Error: \(error.localizedDescription)")
          return
        } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if case 200...300 = statusCode  {
            // 2
            promise.fulfill()
          } else {
            XCTFail("Status code: \(statusCode)")
          }
        }
      }
      dataTask.resume()
      // 3
      wait(for: [promise], timeout: 5)
    }
    

}
