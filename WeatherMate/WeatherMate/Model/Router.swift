//
//  Router.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import Foundation

enum Router {
  // 1.
  case getCityTempInfo
    // 2.
      var scheme: String {
        switch self {
        case .getCityTempInfo:
          return "http"
        }
      }
    
    // 3.
      var host: String {
        switch self {
        case .getCityTempInfo:
          return "api.openweathermap.org"
        }
      }
    
    // 4.
     var path: String {
       switch self {
       case .getCityTempInfo:
         return "/data/2.5/weather"
       }
     }
        
        // 5.
          var parameters: [URLQueryItem] {
       
            switch self {
            case .getCityTempInfo:
              // 6.
              return [URLQueryItem(name: "units", value: "metric"),
                      URLQueryItem(name: "APPID", value: "b556b36f2f8c5a66ee1b767dda5c1642")]
            }
          }
    
    var method: String {
        switch self {
          case .getCityTempInfo:
            return "GET"
        }
      }
}
