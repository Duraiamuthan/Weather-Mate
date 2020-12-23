//
//  Router.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import Foundation

enum Router {
  // 1.
  case getCityTempInfo, getCityInfo
    // 2.
      var scheme: String {
        switch self {
        case .getCityTempInfo, .getCityInfo:
          return "http"
        }
      }
    
    // 3.
      var host: String {
        switch self {
        case .getCityTempInfo, .getCityInfo:
          return "api.openweathermap.org"
        }
      }
     
    // 4.
     var path: String {
       switch self {
       case .getCityTempInfo:
         return "/data/2.5/weather"
       case .getCityInfo:
         return "/data/2.5/find"
       
       }
       
     }
        
        // 5.
          var parameters: [URLQueryItem] {
       let setAppID = "7bc6b14fd02b8fc2b46cab9ef1dcf748"
            switch self {
            case .getCityTempInfo:
              // 6.
              return [URLQueryItem(name: "units", value: "metric"),
                      URLQueryItem(name: "APPID", value:setAppID )]
            
            case .getCityInfo:
              // 6.
              return [
                      URLQueryItem(name: "appid", value: setAppID)]
            }
          }
    
    var method: String {
        switch self {
        case .getCityTempInfo, .getCityInfo:
            return "GET"
        }
      }
}
