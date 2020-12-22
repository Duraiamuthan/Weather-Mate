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


// MARK: - Welcome
struct CityDetailsList: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

 

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
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

func ==(lhs: Coord, rhs: Coord) -> Bool {
    return lhs.lon == rhs.lon || lhs.lat == rhs.lat
}

extension CountryList: Equatable {}
extension Coord: Equatable {}

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
