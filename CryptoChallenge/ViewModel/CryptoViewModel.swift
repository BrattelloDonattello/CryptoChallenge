//
//  CryptoViewModel.swift
//  CryptoChallenge
//
//  Created by Cristian Ciupac on 06.09.2022.
//

import Foundation
import CryptoAPI

class CryptoViewModel: ObservableObject {

    private var cryptoFetcher: CryptoFetchable
    
    private var storage: DataDB?
    @Published var cryptoModel: [CryptoEntityViewModel]?
    
    init() {
        cryptoFetcher = CryptoFetcher()
        storage = RealmPersistance()
        getAllCoin()
        cryptoFetcher.startFeching { coin in
            self.save(crypto: coin)
            self.updateViewModel(crypto: coin)
        }
    }
    
    private func getAllCoin() {
        let coin = self.cryptoFetcher.getAllCoins()
        let cryptoEntity = coin.map { coin in
            return CryptoEntityViewModel(crypto: coin)
        }
        self.cryptoModel = cryptoEntity
    }
    
    private func save(crypto: Coin) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let storage = self.storage else { return }
            
            let storedCrypto = StoredCrypto()
            storedCrypto.name = crypto.name
            storedCrypto.imageUrl = crypto.imageUrl
            storedCrypto.price = crypto.price
            storedCrypto.code = crypto.code
            _ = storage.save(crypto: storedCrypto)
        }
    }
    
    private func updateViewModel(crypto: Coin) {
        if let mainModel = self.cryptoModel?.first(where: { model in
            model.code == crypto.code
        }) {
            mainModel.updateCrypto(crypto: crypto)
        }
    }
}
