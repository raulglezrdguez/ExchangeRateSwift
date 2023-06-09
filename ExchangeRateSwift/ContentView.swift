//
//  ContentView.swift
//  ExchangeRateSwift
//
//  Created by Raul Glez Rdguez on 9/6/23.
//

import SwiftUI

struct Coin {
    let key: String
    let value: String
}

struct ContentView: View {
    private let MAX_TIMESTAMP_UPDATE_SYMBOLS = 86400.00
    private let MAX_TIMESTAMP_UPDATE_RATES = 600.00
    
    @AppStorage("@symbols") var appStorageSymbols = ""
    @AppStorage("@rates") var appStorageRates = ""
    
    @State private var amount = "0"
    @State private var from: String = "EUR"
    @State private var to: String = "USD"
    @State private var result: String = ""
    
    private var viewModel: ViewModel = ViewModel()
    
    @State private var coins: [Coin] = []
    @State private var rates: [String:Double] = [:]
    
    func refreshSymbols() {
        if appStorageSymbols != "" {
            if let s = try? JSONDecoder().decode(Symbols.self, from: Data(appStorageSymbols.utf8)) {
                verifySymbols(s)
            } else {
                loadSymbols()
            }
        } else {
            loadSymbols()
        }
    }
    
    func refreshRates(base: String, symbols: String) {
        if appStorageRates != "" {
            if let s = try? JSONDecoder().decode(Rates.self, from: Data(appStorageRates.utf8)) {
                verifyRates(base: base, symbols: symbols, s)
            } else {
                loadRates(base: base, symbols: symbols)
            }
        } else {
            loadRates(base: base, symbols: symbols)
        }
    }
    
    func jsonSymbolsToString(_ s: Symbols) -> String {
        do {
            let jsonData = try JSONEncoder().encode(s)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("error in jsonSymbolsToString")
        }
        return ""
    }
    
    func jsonRatesToString(_ s: Rates) -> String {
        do {
            let jsonData = try JSONEncoder().encode(s)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("error in jsonRatesToString")
        }
        return ""
    }
    
    func verifySymbols(_ s: Symbols) {
        if (Date().timeIntervalSince1970 - s.timestamp > MAX_TIMESTAMP_UPDATE_SYMBOLS) {
            loadSymbols()
        } else {
            appStorageSymbols = jsonSymbolsToString(s)
            coins = []
            s.symbols?.sorted(by: { $0.0 < $1.0 }).forEach({ (key: String, value: String) in
                coins.append(Coin(key: key, value: value))
            })
        }
    }
    
    func verifyRates(base: String, symbols: String, _ s: Rates) {
        if (Date().timeIntervalSince1970 - s.timestamp > MAX_TIMESTAMP_UPDATE_RATES ||
            s.base != base) {
            loadRates(base: base, symbols: symbols)
        } else {
            appStorageRates = jsonRatesToString(s)
            rates = [:]
            s.rates?.forEach({ (key: String, value: Double) in
                rates[key] = value
            })
            calculateResult()
        }
    }
    
    func calculateResult() {
        if let rate = rates[to] {
            let res = round(rate * (Double(amount) ?? 0.0) * 100) / 100
            result = "\(amount) \(from) is equivalent to \(res) \(to)"
        }
    }
    
    func loadSymbols() {
        viewModel.loadSymbols { success, symbols, timestamp in
            if (success) {
                verifySymbols(Symbols(symbols: symbols, timestamp: timestamp))
            } else {
                result = "Error loading symbols"
            }
        }
    }
    
    func loadRates(base: String, symbols: String) {
        viewModel.loadRates(base: base, symbols: symbols) { success, rates, timestamp in
            if (success) {
                verifyRates(base: base, symbols: symbols, Rates(base: base, rates: rates, timestamp: timestamp))
            } else {
                result = "Error loading rates"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Exchange")
                    .font(.largeTitle).bold()
                Image("currency")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.blue)
                
                HStack{
                    Text("Amount").frame(width: 140)
                    Spacer()
                    TextField("amount to exchange", text: $amount)
                        .keyboardType( .decimalPad)
                        .disableAutocorrection(true)
                        .padding(8)
                        .font(.headline)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(5.0)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .frame(width: UIScreen.main.bounds.width - 150)
                }.padding(10)
                
                HStack {
                    Text("From").frame(width: 140)
                    Spacer()
                    Picker("From", selection: $from) {
                        ForEach(coins, id: \.key) {coin in
                            Text(coin.value)
                        }
                    }
                    .pickerStyle(.automatic)
                    .frame(width: UIScreen.main.bounds.width - 150)
                }.padding(10)
                
                HStack {
                    Text("To").frame(width: 140)
                    Spacer()
                    Picker("To", selection: $to) {
                        ForEach(coins, id: \.key) {coin in
                            Text(coin.value)
                        }
                    }
                    .pickerStyle(.automatic)
                    .frame(width: UIScreen.main.bounds.width - 150)
                }.padding(10)
                
                HStack {
                    Spacer()
                    Button(action: {
                        refreshSymbols()
                        var symbols = ""
                        coins.forEach { coin in
                            if from != coin.key {
                                symbols += "\(coin.key),"
                            }
                        }
                        symbols.removeLast()
                        refreshRates(base: from, symbols: symbols)
                    }){
                        Text("Exchange")
                            .bold()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .foregroundColor(Color.black)
                            .background(Color.green)
                            .cornerRadius(6)
                            .shadow(radius: 10)
                    }.disabled(from == "" || to == "" || from == to)
                    Spacer()
                }
                
                if (result != "") {
                    Text(result)
                        .padding(8)
                        .font(.headline)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(5.0)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                
            }
            .padding()
            .onAppear {
                refreshSymbols()
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
