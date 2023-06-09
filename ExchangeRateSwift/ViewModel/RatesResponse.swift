//
//  RatesResponse.swift
//  ExchangeRateSwift
//
//  Created by Raul Glez Rdguez on 9/6/23.
//

import Foundation

struct RatesResponse: Decodable {
    let success: Bool?
    let ratesDict: [String: Double]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case ratesDict = "rates"
    }
}
