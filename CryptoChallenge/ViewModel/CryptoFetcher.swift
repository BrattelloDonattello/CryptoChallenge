//
//  CryptoFetcher.swift
//  CryptoChallenge
//
//  Created by Cristian Ciupac on 07.09.2022.
//

import Foundation
import CryptoAPI

protocol CryptoFetchable {
    typealias CryptoUpdateHandler = ((Coin) -> Void)
    
    func getAllCoins() -> [Coin]
    func startFeching(handler: CryptoUpdateHandler?)
    func stopFetching()
}


class CryptoFetcher: CryptoFetchable, CryptoDelegate {
   
    
    typealias UpdateStatusHandler = ((_ fetching: Bool) -> Void)
    
    private var handler: CryptoUpdateHandler?
    private var crypto: Crypto?
    private var statusHandler: UpdateStatusHandler?
    private var isFetching = Bool() {
        didSet {
            self.statusHandler?(self.isFetching)
        }
    }
    
    init() {
        self.crypto = Crypto(delegate: self)
        self.handler = nil
        self.statusHandler = nil
    }
    
    func getAllCoins() -> [Coin] {
        self.crypto?.getAllCoins() ?? []
    }
    
    func startFeching(handler: CryptoUpdateHandler?) {
        print("connect")
        if let handler = handler {
            self.handler = handler
        }
        self.connect(delay: .now())
    }
    
    func stopFetching() {
        self.crypto?.disconnect()
    }
    
    func cryptoAPIDidConnect() {
        self.isFetching = true
    }
    
    func cryptoAPIDidUpdateCoin(_ coin: Coin) {
        self.handler?(coin)
    }
    
    func cryptoAPIDidDisconnect() {
        self.isFetching = false
        connect(delay: .now())
    }
    
    private func connect(delay: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: delay) {
            switch self.crypto?.connect() {
            case .success(_): ()
            case .failure(let error):
                if let delayConnect = error as? CryptoError, case let .connectAfter(date: date) = delayConnect {
                    let seconds = Int(date.timeIntervalSinceNow)
                    self.connect(delay: .now() + .seconds(seconds))
                }
            default: ()
            }
        }
    }
}
