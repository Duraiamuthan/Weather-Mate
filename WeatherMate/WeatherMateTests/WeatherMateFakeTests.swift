//
//  WeatherMateFakeTests.swift
//  WeatherMateTests
//
//  Created by Duraiamuthan Harikrishnan on 22/12/20.
//

import XCTest
@testable import WeatherMate

class WeatherMateFakeTests: XCTestCase {
    var sut: SearchCityViewController!
    
    func testDecoding() throws {
            /// When the Data initializer is throwing an error, the test will fail.
            let testBundle = Bundle(for: type(of: self))
            if let filename = testBundle.path(forResource: "Citylist", ofType: "json") {
                do {
                    let jsonData = try Data(contentsOf: URL(fileURLWithPath: filename), options: .alwaysMapped)
                    /// The `XCTAssertNoThrow` can be used to get extra context about the throw
                    XCTAssertNoThrow(try JSONDecoder().decode([CountryList].self, from: jsonData))
                } catch {
                    print("The file could not be loaded")
                }
            }
           
        }
    
    
    func testAllCityLoaded() {
        let playData = CountryList.getAllCity()
        XCTAssertNotEqual(playData.count, 0, "Data is not loaded")
    }
    
    override func tearDown() {
      sut = nil
      super.tearDown()
    }
    /*
    func test_UpdateSearchResults_ParsesData() {
      // given
      let promise = expectation(description: "Status code: 200")
      
      // when
      XCTAssertEqual(sut.cityList.count, 0, "searchResults should be empty before the data executed")
         
    let url = URL(string: " ")
      let dataTask = sut.defaultSession.dataTask(with: url!) {
        data, response, error in
        // if HTTP request is successful, call updateSearchResults(_:) which parses the response data into Tracks
        if let error = error {
          print(error.localizedDescription)
        } else if let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 {
          self.sut.updateSearchResults(data)
        }
        promise.fulfill()
      }
      dataTask.resume()
      wait(for: [promise], timeout: 5)
      
      // then
      XCTAssertEqual(sut.cityList.count, 3, "Didn't parse 3 items from fake response")
    }
*/
     

}

