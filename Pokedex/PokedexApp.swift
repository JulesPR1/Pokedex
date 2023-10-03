//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Jules PASCUAL-RAMON on 21/09/2023.
//

import SwiftUI

@main
struct PokedexApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                GenSelectionView()
            }
        }
    }
}
