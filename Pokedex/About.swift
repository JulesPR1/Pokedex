//
//  FooterView.swift
//  Pokedex
//
//  Created by Jules PASCUAL-RAMON on 25/09/2023.
//

import SwiftUI

struct About: View {
    var body: some View {
        VStack {            
            Text("© 2023 | Mit License | PokéAPI par Yarkis & Ashzuu")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Text("© Pokémon et tous les noms respectifs sont des marques déposées de The Pokémon Company International, Game Freak et Nintendo.")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
    }
}
