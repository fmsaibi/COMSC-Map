//
//  CountryList.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 26/07/2023.
//

import Foundation

struct Country {
    let name: String
    let flag: String
}

class CountryList {
    static func fetchCountries(completion: @escaping (Result<[Country], Error>) -> Void) {
        let url = URL(string: "https://restcountries.com/v3.1/all")!

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let error = NSError(domain: "com.example.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received."])
                completion(.failure(error))
                return
            }

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var countries: [Country] = []
                    for jsonObject in jsonArray {
                        if let nameObject = jsonObject["name"] as? [String: Any],
                           let commonName = nameObject["common"] as? String,
                           let flagEmoji = jsonObject["flag"] as? String {
                            let country = Country(name: commonName, flag: flagEmoji)
                            countries.append(country)
                        }
                    }
                    
                    // Sort the countries alphabetically by name
                    countries.sort { $0.name < $1.name }
                    
                    completion(.success(countries))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
