//
//  CryptoEntityViewModel.swift
//  CryptoChallenge
//
//  Created by Cristian Ciupac on 07.09.2022.
//

import Foundation
import CryptoAPI

class CryptoEntityViewModel: ObservableObject, Identifiable {
    
    @Published var crypto: Coin
    private var storage = RealmPersistance()
    
    enum States {
        case up, down, stable
    }
    
    var states: States
    var maxPrice: Double
    var minPrice: Double
    
    init(crypto: Coin) {
        self.crypto = crypto
        self.states = .stable
        self.maxPrice = crypto.price
        self.minPrice = crypto.price
    }
    
    var id: String { self.code }
    var name: String { crypto.name }
    var code: String { crypto.code }
    var imageURLString: String? { crypto.imageUrl }
    var price: String { String(format: "$ %.02f", crypto.price) }
    var minDisplayPrice: String { String(format: "$ %.02f", minPrice) }
    var maxDisplayPrice: String { String(format: "$ %.02f", maxPrice) }
    
    func updateCrypto(crypto: Coin) {
        DispatchQueue.main.async {
            self.states = crypto.price < self.crypto.price ? .down : crypto.price > self.crypto.price ? .up : .stable
            
            self.crypto = crypto
            
            if case .success(let cryptoUpdate) = self.storage.getHistory(code: crypto.code) {
                if let min = cryptoUpdate.min(by: { leftCrypto, rightCrypto in
                    leftCrypto.price < rightCrypto.price
                }) {
                    self.minPrice = min.price
                } else {
                    self.minPrice = crypto.price
                }
                
                if let max = cryptoUpdate.min(by: { leftCrypto, rightCrypto in
                    leftCrypto.price > rightCrypto.price
                }) {
                    self.maxPrice = max.price
                } else {
                    self.maxPrice = crypto.price
                }
            }
        }
    }
    
}
