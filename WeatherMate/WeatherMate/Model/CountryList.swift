//
//  CountryList.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import Foundation

struct CList {
  
  let cName, icon: String
  let cID: Int
  let temp: Double

}


//typealias countryList = [CountryList]

// MARK: - CountryList
struct CountryList: Codable {
    let id: Int
    let name, state, country: String
    let coord: Coord
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

extension CountryList {
  static func getAllCity() -> [CountryList] {
    guard
      let url = Bundle.main.url(forResource: "Citylist", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        return []
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([CountryList].self, from: data)
    } catch {
      return []
    }
  }
}
