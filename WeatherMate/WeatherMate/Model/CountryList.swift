//
//  CountryList.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import Foundation

struct CList: Codable {
    let cName, icon: String
    let cID: Int
    let temp: Double
}

// MARK: - City list
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
    //   let type, id: Int
    let country: String
    //    let sunrise, sunset: Int
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

// MARK: - Temperature
struct TempInfo: Codable {
    let message, cod: String
    let count: Int
    let list: [List]
}

struct List: Codable {
    let id: Int
    let name: String
    let coord: Coord
    let main: Main
    let dt: Int
    let wind: Wind
    let sys: Sys
    let rain: Rain?
    let snow: JSONNull?
    let clouds: Clouds
    let weather: [Weather]
}

// MARK: - Rain
struct Rain: Codable {
    let the1H: Double
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

// To fetch all city list from Json
extension CountryList {
  static func getAllCity(returnCompletion: @escaping ([CountryList]) -> ())  {
    DispatchQueue.global(qos: .background).async {
    guard
      let url = Bundle.main.url(forResource: "Citylist", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        returnCompletion([])
        return
    }
    
    do {
        returnCompletion (try JSONDecoder().decode([CountryList].self, from: data))
    } catch {
        returnCompletion([])
    }
  }
  }
}
