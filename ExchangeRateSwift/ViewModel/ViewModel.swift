//
//  ViewModel.swift
//  ExchangeRateSwift
//
//  Created by Raul Glez Rdguez on 9/6/23.
//

import Foundation

final class ViewModel {
    let API_KEY = "db8423abf221064f5510359bb6c10120"
    //    let BASE_URL = "http://api.exchangeratesapi.io/v1"
    let BASE_URL = "http://127.0.0.1:3000"
    
    func loadSymbols(callback: @escaping (Bool, [String: String], TimeInterval) -> Void) {
        let urlSession = URLSession.shared
        let url = URL(string: "\(BASE_URL)/symbols?access_key=\(API_KEY)")
        
        urlSession.dataTask(with: url!) { data, response, error in
            if let error = error {
                print(error)
            }
            
            if let data = data,
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // let json = try? JSONSerialization.jsonObject(with: data)
                let json = try? JSONDecoder().decode(SymbolsResponse.self, from: data)
                if let s = json?.symbolsDict {
                    callback(true, s, Date().timeIntervalSince1970)
                } else {
                    callback(false, [:], 0.0)
                }
            } else {
                callback(false, [:], 0.0)
            }
        }.resume()
    }
    
    func loadRates(base: String, symbols: String, callback: @escaping (Bool, [String: Double], TimeInterval) -> Void) {
        let urlSession = URLSession.shared
        let url = URL(string: "\(BASE_URL)/latest?access_key=\(API_KEY)&base=\(base)&symbols=\(symbols)")
        
        urlSession.dataTask(with: url!) { data, response, error in
            if let error = error {
                print(error)
            }
            
            if let data = data,
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                let json = try? JSONDecoder().decode(RatesResponse.self, from: data)
                if let s = json?.ratesDict {
                    callback(true, s, Date().timeIntervalSince1970)
                } else {
                    callback(false, [:], 0.0)
                }
            } else {
                callback(false, [:], 0.0)
            }
        }.resume()
    }
}


