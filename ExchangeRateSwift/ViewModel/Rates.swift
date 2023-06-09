//
//  Rates.swift
//  ExchangeRateSwift
//
//  Created by Raul Glez Rdguez on 9/6/23.
//

import Foundation

struct Rates: Codable {
    let base: String
    let rates: [String: Double]?
    let timestamp: TimeInterval
}
