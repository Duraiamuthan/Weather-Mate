//
//  ServiceLayer.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import Foundation

class ServiceLayer {
    // 1.
    class func request<T: Codable>(router: Router,ciyIDParameters: [String: String] = [:], completion: @escaping (Result<T, Error>) -> ()) {
        // 2.
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.path = router.path
        
        var queryItems: [URLQueryItem] = router.parameters
        
        let optionalURLQueryItems = ciyIDParameters.map {
            return URLQueryItem(name: $0, value: $1)
        }
        queryItems.append(contentsOf: optionalURLQueryItems)
        components.queryItems = queryItems
        // 3.
        guard let url = components.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method
        // 4.
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            
            //6.
            if let response = response as? HTTPURLResponse, response.isResponseSuccess {
                //  its successful
                do{
                print(response)
                let responseObject = try JSONDecoder().decode(T.self, from: data!)
                // 7.
                DispatchQueue.main.async {
                    // 8.
                    completion(.success(responseObject))
                }
                }
                catch {
                    completion(.failure(error))
                }
            } else {
                if let getError = error{
                    completion(.failure(getError))
                }
            }
        }
        dataTask.resume()
    }
}
