//
//  Stat.swift
//  Pokedex
//
//  Created by Jules PASCUAL-RAMON on 21/09/2023.
//

import Foundation

struct Stat: Identifiable {
    let id = UUID()
    let tk: Int
    let def: Int
    let hp: Int
    let spe_atk: Int
    let spe_def: Int
    let vit: Int
}
