//
//  HomeView.swift
//  CryptoChallenge
//
//  Created by Cristian Ciupac on 06.09.2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: CryptoViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Market")
                .font(.title)
                .fontWeight(.semibold)
            
            if let cryptos = vm.cryptoModel {
                List(cryptos) { coin in
                        CryptoNavigationLink(vm: coin)
                }
                .listStyle(PlainListStyle())
            } else {
                Text("Error")
            }
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
