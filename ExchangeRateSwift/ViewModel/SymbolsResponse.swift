//
//  SymbolsResponse.swift
//  ExchangeRateSwift
//
//  Created by Raul Glez Rdguez on 9/6/23.
//

import Foundation

struct SymbolsResponse: Decodable {
    let success: Bool?
    let symbolsDict: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case symbolsDict = "symbols"
    }
}
