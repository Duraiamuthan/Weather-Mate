//
//  PropertyListner.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 24/12/20.
//

import Foundation

public extension UserDefaults {
    
    private struct UserDefaultsError: Error {
        private let savedCityList: [CList]
        init(_ savedCityList: [CList]) {
            self.savedCityList = savedCityList
        }
         
    }
    
    func setCustomObject<T: Encodable>(_ object: T?, forKey key: String) throws {
        guard let object = object else {
        removeObject(forKey: key)
            return
        }
        do {
            let encoded = try PropertyListEncoder().encode(object)
            set(encoded , forKey:key)
        } catch {
            throw error
        }

    }

    func getCustomObject<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = data(forKey: key) else {
            return nil
        }
        return try PropertyListDecoder().decode(T.self, from: data)
    }
    
}
