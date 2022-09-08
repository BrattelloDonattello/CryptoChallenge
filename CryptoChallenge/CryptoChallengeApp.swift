//
//  CryptoChallengeApp.swift
//  CryptoChallenge
//
//  Created by Cristian Ciupac on 06.09.2022.
//

import SwiftUI

@main
struct CryptoChallengeApp: App {
    @StateObject var vm = CryptoViewModel()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(vm)
        }
    }
}
