import SwiftUI
import Kingfisher

struct PokemonListView: View {
    @State private var pokemons: [Pokemon] = []
    @State var generation: Int
    @State private var pokemons_loading = true

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 0, maximum: .infinity)),
                GridItem(.flexible(minimum: 0, maximum: .infinity))
            ], spacing: 16) {
                ForEach(pokemons, id: \.pokedexId) { pokemon in
                    PokemonCardView(pokemon: pokemon, pokemons: pokemons)
                }
            }
            .padding()
            .navigationTitle("Génération \(generation)")
        }.onAppear {
            loadPokemons(generation: generation)
            pokemons_loading = false
        }.overlay {
            if pokemons_loading {
                ProgressView().frame(width: 200, height: 200)
            }
        }

    }

    struct PokemonCardView: View {
        let pokemon: Pokemon
        let pokemons: [Pokemon]
        
        @State private var preEvolutions: [Pokemon] = []
        @State private var nextEvolutions: [Pokemon] = []

        @State private var isLoading = true
        
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            NavigationLink(destination: PokemonDetails(pokemon: pokemon, image: [pokemon.sprites.regular, pokemon.sprites.shiny ?? ""], pre_evolutions: preEvolutions, next_evolutions: nextEvolutions)){
                VStack(alignment: .center){
                    
                    KFImage(URL(string: pokemon.sprites.regular))
                        .onSuccess { _ in
                            isLoading = false
                        }
                        .onFailure { _ in
                            isLoading = false
                        }
                    //.forceRefresh(true) // for tests only
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .overlay {
                            if isLoading {
                                ProgressView().frame(width: 12, height: 12)
                            }
                        }
                
                    VStack{
                        Text("N° \(pokemon.pokedexId)").font(.caption).foregroundColor(.gray)
                        Text(pokemon.name.fr)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }.padding(.vertical)
                    
                }
                .frame(width: 160)
                .background(colorScheme == .dark ? Color(hex: 0x35363a) : Color(hex: 0xf6f6f6))
                .cornerRadius(10)
                .overlay(types_badge.alignmentGuide(.leading) { _ in -10 }.alignmentGuide(.top) { _ in -10}, alignment: .topLeading)
            }.shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.33), radius: 2, x: 0, y: 1.5)
        }
        
        var types_badge: some View {
            HStack(spacing: 1) {
                ForEach(pokemon.types, id: \.name) { type in
                    KFImage(URL(string: type.image))
                        .resizable()
                        .frame(width: 0)
                        .scaledToFit()
                        .frame(height: 12)
                }
            }
        }
    }

    private func loadPokemons(generation: Int) {
        Pokemon.fetchPokemons(generation: generation) { fetchedPokemons in
            if let fetchedPokemons = fetchedPokemons {
                self.pokemons = fetchedPokemons
            } else {
                print("Failed to load Pokémon data")
            }
        }
    }
}
