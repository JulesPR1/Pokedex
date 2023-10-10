import SwiftUI
import Kingfisher

struct PokemonListView: View {
    @State private var pokemons: [Pokemon] = []
    @State var generation: Int
    @State private var pokemons_loading = true
    @State private var searchText = ""
    @State private var filteredPokemons: [Pokemon] = []

    let pokemon_types = Pokemon.get_types()
    @State private var selectedPokemonTypeIndex = 0
    @State private var selectedPokemonType: String = ""
    
    @Environment(\.colorScheme) var colorScheme
        
    var gridItems: [GridItem]{
        var gridItems: [GridItem] = []
        for _ in 0..<(UIDevice.current.orientation.isPortrait ? 2 : 4) {
            gridItems.append(GridItem(.flexible(minimum: 0, maximum: .infinity)))
        }
        
        return gridItems
    }
    
    var body: some View {
        VStack {
            TextField("Recherche par nom ou PokedexID", text: $searchText)
                .padding(.horizontal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) { newValue in
                    filteredPokemons = pokemons.filter {
                        $0.name.fr.lowercased().contains(newValue.lowercased()) ||
                        "\($0.pokedexId)".contains(newValue)
                    }
                }
        
        

            Picker("Trier par type", selection: $selectedPokemonTypeIndex) {
                ForEach(0..<pokemon_types.count, id: \.self) {
                    Text(pokemon_types[$0]).tag($0)
                }
            }
            .frame(width: 200)
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.black)
            .onChange(of: selectedPokemonTypeIndex) { newValue in
                let selectedType = pokemon_types[newValue]
                if newValue == 0 {
                    filteredPokemons = pokemons
                }else{
                    filteredPokemons = pokemons.filter { pokemon in
                        pokemon.types.contains { type in
                            type.name.lowercased().contains(selectedType.lowercased())
                        }
                    }
                }
            }
            
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 16) {
                    ForEach(filteredPokemons.isEmpty ? pokemons : filteredPokemons, id: \.pokedexId) { pokemon in
                        PokemonCardView(pokemon: pokemon, pokemons: pokemons)
                    }
                }
                .padding()
                .navigationTitle("Génération \(generation)")
            }.overlay {
                if pokemons_loading {
                    ProgressView().frame(width: 200, height: 200)
                }
            }
            }.onAppear {
                loadPokemons(generation: generation)
                pokemons_loading = false
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
                        .loadImmediately()
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
                .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(pokemon.get_gradient(), lineWidth: 4)
                    )
            }
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.33), radius: 2, x: 0, y: 1.5)
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
