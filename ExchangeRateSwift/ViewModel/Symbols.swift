//
//  Symbols.swift
//  ExchangeRateSwift
//
//  Created by Raul Glez Rdguez on 9/6/23.
//

import Foundation

struct Symbols: Codable {
    let symbols: [String: String]?
    let timestamp: TimeInterval
}
