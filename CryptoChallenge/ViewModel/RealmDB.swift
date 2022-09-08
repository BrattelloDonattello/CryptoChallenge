//
//  RealmDB.swift
//  CryptoChallenge
//
//  Created by Cristian Ciupac on 07.09.2022.
//

import Foundation
import RealmSwift

protocol DataDB {
    func getHistory(code: String) -> Result<[StoredCrypto], RealmDBError>
    func getLastValue(code: String) -> Result<StoredCrypto, RealmDBError>
    func getUpdates(code: String, seconds: Int) -> Result<[StoredCrypto], RealmDBError>
    func save(crypto: StoredCrypto) -> RealmDBError?
}

class StoredCrypto: Object {
    @Persisted var name: String = ""
    @Persisted var code: String = ""
    @Persisted var price: Double = 0.0
    @Persisted var imageUrl: String?
    @Persisted var createdAt: Date? = Date()
}

enum RealmDBError: Error {
    case noData
    case instantionError
    case sourceInitializationError(error: Error)
    case writeError(error: Error)
}

class RealmPersistance: DataDB {
    
    var realm: Realm?
    
    init() {
        do { realm = try Realm() }
        catch(let error) { print("Realm error: \(error)") }
    }
    
    func getHistory(code: String) -> Result<[StoredCrypto], RealmDBError> {
        guard let realm = realm else {
            return .failure(.instantionError)
        }
        
        let cryptos = realm.objects(StoredCrypto.self)
        let cryptosWithCode = cryptos.where {
            $0.code == code
        }
        
        return .success(Array(cryptosWithCode))
    }
    
    func getLastValue(code: String) -> Result<StoredCrypto, RealmDBError> {
        let result = self.getHistory(code: code)
        switch result {
        case .success(let storedCrypto):
            guard let lastUpdate = storedCrypto.last else { return .failure(.noData) }
            return .success(lastUpdate)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getUpdates(code: String, seconds: Int) -> Result<[StoredCrypto], RealmDBError> {
        let result = self.getHistory(code: code)
        guard case .success(let lastUpdate) = result else { return result }
        
        let updateForLast = lastUpdate.filter { crypto in
            guard let createdAt = crypto.createdAt else { return false }
            return createdAt.timeIntervalSince1970 > Date().timeIntervalSince1970 - Double(seconds)
        }
        
        return .success(updateForLast)
    }
    
    func save(crypto: StoredCrypto) -> RealmDBError? {
        guard let realm = realm else { return .instantionError }
        
        do {
            try realm.write {
                realm.add(crypto)
            }
            return nil
        }
        catch(let error) {
            return .writeError(error: error)
        }
    }
}
