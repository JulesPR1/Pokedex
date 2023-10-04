import SwiftUI

struct Pokemon: Codable {
    let pokedexId: Int
    let generation: Int
    let category: String
    let name: Name
    let sprites: Sprites
    let types: [Type]
    let talents: [Talent]?
    let stats: Stats
    let resistances: [Resistance]
    let evolution: Evolution?
    let height: String
    let weight: String
    let catch_rate: Int?
    let sex: Sex?
}

struct Name: Codable {
    let fr: String
    let en: String
    let jp: String
}

struct Sprites: Codable {
    let regular: String
    let shiny: String?
    let gmax: GmaxSprites?
    
    struct GmaxSprites: Codable {
        let regular: String
        let shiny: String?
    }
}

struct Type: Codable {
    let name: String
    let image: String
}

struct Talent: Codable {
    let id = UUID()
    let name: String
    //let tc: Bool
}

struct Stats: Codable {
    let hp: Int
    let atk: Int
    let def: Int
    let spe_atk: Int
    let spe_def: Int
    let vit: Int
}

struct Resistance: Codable, Identifiable {
    let id = UUID()
    let name: String
    let multiplier: Double
}

struct Evolution: Codable {
    let pre: [PreviousEvolution]?
    let next: [NextEvolution]?
    let mega: [MegaEvolution]?
    
    struct PreviousEvolution: Codable {
        let pokedexId: Int
        let name: String
        let condition: String?
    }
    
    struct NextEvolution: Codable {
        let pokedexId: Int
        let name: String
        let condition: String?
    }
    
    struct MegaEvolution: Codable {
        let orbe: String
        let sprites: MegaSprites
        
        struct MegaSprites: Codable {
            let regular: String
            let shiny: String?
        }
    }
}

struct Sex: Codable {
   let male: Double
   let female: Double
}

enum CodingKeys: String, CodingKey {
     case sex = "sexe"
 }

extension Pokemon {
    var types_colors_hash: [String: Color] {
        return [
            "Normal": Color(hex: 0xE0E0E0),
            "Plante": Color(hex: 0x7ED68E),
            "Feu": Color(hex: 0xFF6B6B),
            "Eau": Color(hex: 0x6D8EAD),
            "Électrik": Color(hex: 0xFFF689),
            "Glace": Color(hex: 0x9EF4FF),
            "Combat": Color(hex: 0xCF7667),
            "Poison": Color(hex: 0xC48DFF),
            "Sol": Color(hex: 0xD98767),
            "Vol": Color(hex: 0xFAFAFA),
            "Psy": Color(hex: 0xFFBFD3),
            "Insecte": Color(hex: 0x9EDB8E),
            "Roche": Color(hex: 0xc2b793),
            "Spectre": Color(hex: 0xA05B9F),
            "Dragon": Color(hex: 0xFF9800),
            "Ténèbres": Color(hex: 0x333333),
            "Acier": Color(hex: 0x808080),
            "Fée": Color(hex: 0xFFBFD3)
        ]
    }
    
    static func fetchPokemons(generation: Int, completion: @escaping ([Pokemon]?) -> Void) {
        guard let url = URL(string: "https://api-pokemon-fr.vercel.app/api/v1/gen/\(generation)") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let pokemons = try JSONDecoder().decode([Pokemon].self, from: data)
                    DispatchQueue.main.async {
                        completion(pokemons)
                    }
                } catch {
                    print(error)
                    completion(nil)
                }
            } else if let error = error {
                print(error)
                completion(nil)
            }
        }.resume()
    }
    
    static func fetchPokemonById(id: Int, completion: @escaping (Result<Pokemon, Error>) -> Void) {
        guard let url = URL(string: "https://api-pokemon-fr.vercel.app/api/v1/pokemon/\(id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                completion(.success(pokemon))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func has_evolutions() -> Bool {
        guard let evolution = self.evolution else {
            return false
        }
        
        let emptyCount = (evolution.pre?.isEmpty == true ? 1 : 0) + (evolution.next?.isEmpty == true ? 1 : 0)
        
        return emptyCount < 2
    }
    
    
    func get_evolutions_ids() -> [Int] {
        if has_evolutions(){
            var evolutionIds: [Int] = []
            
            if let previousEvolutions = self.evolution!.pre {
                for previousEvolution in previousEvolutions {
                    evolutionIds.append(previousEvolution.pokedexId)
                }
            }
            
            if let nextEvolutions = self.evolution!.next {
                for nextEvolution in nextEvolutions {
                    evolutionIds.append(nextEvolution.pokedexId)
                }
            }
            
            // Collect IDs from MegaEvolution
            /* if let megaEvolutions = mega {
             for megaEvolution in megaEvolutions {
             // You can optionally collect IDs from MegaSprites here if needed
             evolutionIds.append(megaEvolution.orbe)
             }
             } */
            
            return evolutionIds
        } else {
            return []
        }
    }
    
    func loadPreEvolutions(completion: @escaping ([Pokemon]) -> Void) {
        var pokemons_array: [Pokemon] = []
        var pokedexIds: [Int]
        
        if let preEvolutionsData = self.evolution?.pre {
            pokedexIds = preEvolutionsData.map { $0.pokedexId }
            
            let dispatchGroup = DispatchGroup()
            
            for pokedex_id in pokedexIds {
                dispatchGroup.enter()
                Pokemon.fetchPokemonById(id: pokedex_id) { result in
                    switch result {
                    case .success(let pokemon):
                        pokemons_array.append(pokemon)
                    case .failure(let error):
                        print(error)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                pokemons_array.sort { $0.pokedexId < $1.pokedexId }
                completion(pokemons_array)
            }
        } else {
            completion([])
        }
    }
    
    func loadNextEvolutions(completion: @escaping ([Pokemon]) -> Void) {
        if let nextEvolutionsData = self.evolution?.next {
            let nextEvolutionsPokedexIds = nextEvolutionsData.map { $0.pokedexId }
            
            let dispatchGroup = DispatchGroup()
            var nextEvolutionsArray: [Pokemon] = []
            
            for pokedex_id in nextEvolutionsPokedexIds {
                dispatchGroup.enter()
                Pokemon.fetchPokemonById(id: pokedex_id) { result in
                    switch result {
                    case .success(let pokemon):
                        nextEvolutionsArray.append(pokemon)
                    case .failure(let error):
                        print(error)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                nextEvolutionsArray.sort { $0.pokedexId < $1.pokedexId }
                completion(nextEvolutionsArray)
            }
        } else {
            completion([])
        }
    }
    
    func get_gradient() -> Gradient{
        var colors: [Color] = []
        
        for type in self.types {
            colors.append(types_colors_hash[type.name] ?? Color.white)
        }
        
        return Gradient(colors: colors)
    }
    
    static func get_types() -> [String] {
        ["Tous", "Normal", "Plante", "Feu", "Eau", "Électrik", "Glace", "Combat", "Poison", "Sol", "Vol", "Psy", "Insecte", "Roche", "Spectre", "Dragon", "Ténèbres", "Acier", "Fée"]
    }
    
}
