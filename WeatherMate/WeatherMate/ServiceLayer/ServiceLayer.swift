//
//  ServiceLayer.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import Foundation

class ServiceLayer {
    // 1.
    class func request<T: Codable>(router: Router, completion: @escaping (Result<[String: [T]], Error>) -> ()) {
        // 2.
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.path = router.path
        components.queryItems = router.parameters
        // 3.
        guard let url = components.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method
        // 4.
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            // 5.
           
            guard let error = error else {
              // without an image or an error, we'll just ignore this for now
              // you could add your own special error cases for this scenario
              return
            }
            //6.
            if let response = response as? HTTPURLResponse, response.isResponseSuccess {
                                    //  its successful
                let responseObject = try! JSONDecoder().decode([String: [T]].self, from: data!)
                // 7.
                DispatchQueue.main.async {
                    // 8.
                    completion(.success(responseObject))
                }
                                } else {
                                    completion(.failure(error.localizedDescription as! Error))

                                }
            
            

        }
        dataTask.resume()
    }
}
