//
//  PokemonDetails.swift
//  Pokedex
//
//  Created by Jules PASCUAL-RAMON on 24/09/2023.
//

import SwiftUI
import Kingfisher
import Charts

struct PokemonDetails: View {
    @State var pokemon: Pokemon
    
    @State private var shiny = false
    
    @State var image: [String]
    
    @State private var isLoading = true
    
    @State var pre_evolutions: [Pokemon]?
    @State var next_evolutions: [Pokemon]?
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var barSelection: String?
    
    var pokemons: [Pokemon] {
        return (pre_evolutions ?? []) + [pokemon] + (next_evolutions ?? [])
    }
    
    var evolution_columns: [GridItem] {
        var columns: [GridItem] = []
        
        for i in 0..<pokemons.count {
            if i < 4 {
                columns.append(GridItem(.flexible(minimum: 0, maximum: .infinity)))
            }
        }
        
        return columns
    }
    var last_pokemon: Pokemon {
        if let pokemon = pokemons.last {
            return pokemon
        }else{
            return self.pokemon
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                pokemon_image(sprite_regular: pokemon.sprites.regular, sprite_shiny: pokemon.sprites.shiny ?? "", gradient: pokemon.get_gradient())
                
                Spacer().frame(height: 50)
                
                Divider()
                
                HStack(alignment: .bottom){
                    Text(pokemon.name.fr).font(.headline)
                    Text("N° \(pokemon.pokedexId)").font(.caption).foregroundColor(Color.gray)
                }
                
                Spacer()
                
                Text(pokemon.category)

                Divider()

                stats_list
                
                Divider()
                
                HStack(alignment: .center) {
                    types_list
                    Spacer().frame(width: 20)
                    resistances_list
                }.padding(.vertical)

                Divider()
                
                talents_list
                
                Divider()
                
                if let sexe = pokemon.sexe {
                    sexe_charts(sexe: sexe)
                    
                    Divider()
                }
                
                if pokemon.has_evolutions(){
                    pokemon_evolutions.padding(.top)
                }
                
                VStack{
                    mega_evolution_card
                }.padding(.vertical)
                
                VStack{
                    gigamax_card
                }.padding(.vertical)
                
            }.navigationTitle(pokemon.name.fr)
        }
    }
    
    struct sexe_charts: View {
        @State private var graphType: GraphType = .donut
        let sexe: Sex
        
        var body: some View {
            VStack {
                Picker("", selection: $graphType) {
                    ForEach(GraphType.allCases, id: \.rawValue) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
            }
            
            VStack(alignment: .center) {
                Text("Sexe :").padding(.bottom).bold().font(.system(size: 20)).underline()

                Chart {
                    if graphType == .donut || graphType == .pie {
                        SectorMark(angle: .value("%", sexe.male), innerRadius: .ratio(graphType == .donut ? 0.5 : 0.0), angularInset: graphType == .donut ? 4 : 1)
                            .foregroundStyle(by: .value("Sexe", "Mâle"))
                            .cornerRadius(3)
                            .annotation(position: .overlay){
                                Text("\(String(format: "%.1f", sexe.male))%").bold().font(.system(size: 10))
                            }
                        
                        SectorMark(angle: .value("%", sexe.female), innerRadius: .ratio(graphType == .donut ? 0.5 : 0.0), angularInset: graphType == .donut ? 4 : 1)
                            .foregroundStyle(by: .value("Sexe", "Femelle"))
                            .cornerRadius(3)
                            .annotation(position: .overlay){
                                Text("\(String(format: "%.1f", sexe.female))%").bold().font(.system(size: 10))
                            }
                    }
                    else if graphType == .bar {
                        BarMark(x: .value("Sexe", "Mâle"), y: .value("%", sexe.male))
                            .foregroundStyle(by: .value("Sexe", "Mâle"))
                            .cornerRadius(3)
                        BarMark(x: .value("Sexe", "Femelle"), y: .value("%", sexe.female))
                            .foregroundStyle(by: .value("Sexe", "Femelle"))
                            .cornerRadius(3)
                    }
                }
                .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                .frame(height: 150)
                .animation(graphType == .bar ? .none : .snappy, value: graphType)
            }.padding()
        }
    }
        
    struct pokemon_image: View {
        let sprite_regular: String
        let sprite_shiny: String?
        let gradient: Gradient
        @State var shiny = false
        @State var isLoading = true
        
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .top) {
                    VStack {
                        KFImage(URL(string: shiny ? sprite_shiny ?? "" : sprite_regular))
                            .onSuccess { _ in
                                isLoading = false
                            }
                            .onFailure { _ in
                                isLoading = false
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 300)
                            .overlay {
                                if isLoading {
                                    ProgressView().frame(width: 12, height: 12)
                                }
                            }
                    }.background{
                        Ellipse()
                            .fill(gradient)
                            .strokeBorder(Color.black, lineWidth: 1)
                            .frame(width: 350, height: 100)
                            .offset(y: 120)
                    }
                }
                if (sprite_shiny != nil) {
                    Button(shiny ? "⮐" : "✨") {
                        shiny.toggle()
                        isLoading = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.clear)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .border(colorScheme == .dark ? .white : .black)
                    .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                    .padding()
                    .offset(x: -8, y: 8)
                }
            }
        }
    }
    
    var resistances_list: some View {
        VStack {
            Text("Résistances :").padding(.bottom).bold().font(.system(size: 20)).underline()
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(pokemon.resistances.filter { $0.multiplier != 1 }, id: \.name) { resistance in
                        HStack {
                            Text(resistance.name)
                                .font(.system(size: 14))
                            Spacer()
                            Text("× \(String(format: "%.1f", resistance.multiplier))")
                                .foregroundColor(resistance.multiplier < 1 ? Color.green : Color.red).font(.system(size: 14))
                        }
                    }
                }.frame(width: 150)
            }
        }
        .background(Color.clear)
    }
    
    var pokemon_evolutions: some View{
        VStack{
            Text("Évolutions :").padding(.bottom).bold().font(.system(size: 20)).underline()
            
            LazyVGrid(columns: evolution_columns, alignment: .center, spacing: 10) {
                if let pre_evolutions = pre_evolutions {
                    ForEach(pre_evolutions, id: \.pokedexId) { pre_evolution in
                        evolution_card(size: 100, url: pre_evolution.sprites.regular, pokemon: pre_evolution, pre_evolutions: pre_evolutions, next_evolutions: next_evolutions)
                    }
                }
                
                evolution_card(size: 100, url: pokemon.sprites.regular, pokemon: pokemon, pre_evolutions: nil, next_evolutions: nil)
                
                if let next_evolutions = next_evolutions {
                    ForEach(next_evolutions, id: \.pokedexId) { next_evolution in
                        evolution_card(size: 100, url: next_evolution.sprites.regular, pokemon: next_evolution, pre_evolutions: pre_evolutions, next_evolutions: next_evolutions)
                    }
                }
            }.onAppear {
                pokemon.loadPreEvolutions() { pokemons in
                    self.pre_evolutions = pokemons
                }
                pokemon.loadNextEvolutions() { pokemons in
                    self.next_evolutions = pokemons
                }
            }
        }.frame(width: 300)
    }
    
    var types_list: some View {
        VStack {
            Text("Types :").padding(.bottom).bold().font(.system(size: 20)).underline()
            ScrollView {
                LazyVStack {
                    ForEach(pokemon.types, id: \.name) { type in
                        HStack {
                            Text(type.name)
                            Spacer()
                            KFImage(URL(string: type.image))
                                .resizable()
                                .loadImmediately()
                                .frame(width: 30, height: 30)
                                .scaledToFit()
                                .frame(height: 30)
                        }.padding(.horizontal)
                    }
                }.frame(width: 150)
            }
        }
        .background(Color.clear)
    }
    
    var stats_list: some View{
        VStack{
            Text("Statistiques :").padding(.bottom).bold().font(.system(size: 20)).underline()
            
            ScrollView {
                HStack{
                    LazyVStack(alignment: .center) {
                        HStack{
                            Text("Hp : ").fontWeight(.light)
                            Spacer()
                            Text(String(pokemon.stats.hp)).bold()
                        }
                        HStack{
                            Text("Atk : ").fontWeight(.light)
                            Spacer()
                            Text(String(pokemon.stats.atk)).bold()
                        }
                        HStack{
                            Text("Def : ").fontWeight(.light)
                            Spacer()
                            Text(String(pokemon.stats.def)).bold()
                        }
                    }
                    
                    Divider()
                    
                    LazyVStack(alignment: .center) {
                        HStack{
                            Text("Spe. Atk : ").fontWeight(.light)
                            Spacer()
                            Text(String(pokemon.stats.spe_atk)).bold()
                        }
                        HStack{
                            Text("Spe. Def : ").fontWeight(.light)
                            Spacer()
                            Text(String(pokemon.stats.spe_def)).bold()
                        }
                        HStack{
                            Text("Vit : ").fontWeight(.light)
                            Spacer()
                            Text(String(pokemon.stats.vit)).bold()
                        }
                    }
                }
                .frame(width: 250)
                .padding(.vertical)
                
                VStack {
                    DisclosureGroup {
                        Chart {
                            BarMark(x: .value("Stat", "Hp"), y: .value("", pokemon.stats.hp))
                                .foregroundStyle(Color.green)
                                .cornerRadius(3)
                            
                            
                            BarMark(x: .value("Stat", "Atk"), y: .value("", pokemon.stats.atk))
                                .foregroundStyle(Color.red)
                                .cornerRadius(3)
                            
                            BarMark(x: .value("Stat", "Def"), y: .value("", pokemon.stats.def))
                                .foregroundStyle(Color.orange)
                                .cornerRadius(3)
                            
                            BarMark(x: .value("Stat", "Spe. Atk"), y: .value("", pokemon.stats.spe_atk))
                                .foregroundStyle(Color.pink)
                                .cornerRadius(3)
                            
                            BarMark(x: .value("Stat", "Spe. Def"), y: .value("", pokemon.stats.spe_def))
                                .foregroundStyle(Color.yellow)
                                .cornerRadius(3)
                            
                            BarMark(x: .value("Stat", "Vit"), y: .value("", pokemon.stats.vit))
                                .foregroundStyle(Color.cyan)
                                .cornerRadius(3)
                            
                            if let barSelection {
                                RuleMark(x: .value("Stat", barSelection))
                                    .foregroundStyle(.gray.opacity(0.35))
                                    .zIndex(-10)
                                    .annotation(
                                        position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit, y: .disabled)){
                                            Text("\(get_selected_value(selection: barSelection)) \(barSelection)")
                                        }
                                
                            }
                        }
                        .chartXSelection(value: $barSelection)
                        .frame(height: 200)
                        .padding()
                    } label: {
                        HStack(alignment: .center) {
                            Text("Voir le graphique des statistiques")
                        }
                    }
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                }
                .accentColor(colorScheme == .dark ? .white : .black)
            }
        }.padding(.vertical)
    }
    
    var talents_list: some View {
        ScrollView {
            Text("Talents :").padding(.bottom).bold().font(.system(size: 20)).underline()
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 0, maximum: .infinity)),
                GridItem(.flexible(minimum: 0, maximum: .infinity))
            ], spacing: 10) {
                if let talents = pokemon.talents {
                    ForEach(talents, id: \.id) { talent in
                        HStack(alignment: .center) {
                            Text(talent.name).padding(10).frame(width: 150)
                        }.border(colorScheme == .dark ? Color.white : Color.black, width: 1).frame(width: 200)
                    }
                }
            }
        }.padding(.vertical)
    }
    
    struct evolution_card: View {
        let size: CGFloat
        let url: String
        let pokemon: Pokemon?
        let pre_evolutions: [Pokemon]?
        let next_evolutions: [Pokemon]?
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            if let pokemon = pokemon {
                return AnyView(
                    NavigationLink(destination: PokemonDetails(pokemon: pokemon, image: [pokemon.sprites.regular, pokemon.sprites.shiny ?? ""], pre_evolutions: pre_evolutions, next_evolutions: next_evolutions)
                    ) {
                        VStack{
                            Text(pokemon.name.fr).foregroundStyle(colorScheme == .dark ? Color.white : Color.black).bold()
                            KFImage(URL(string: url))
                                .resizable()
                                .frame(width: size, height: size)
                                .scaledToFit()
                        }
                    }
                )
            } else {
                return AnyView(
                    VStack{
                        if let pokemon = pokemon {
                            Text(pokemon.name.fr).foregroundStyle(colorScheme == .dark ? Color.white : Color.black).bold()
                            KFImage(URL(string: url))
                                .resizable()
                                .frame(width: size, height: size)
                                .scaledToFit()
                        }
                    }
                )
            }
        }
    }
    
    var mega_evolution_card: some View{
        VStack{
            if let evolutions = last_pokemon.evolution {
                if let mega = evolutions.mega {
                    if let c_mega = mega.first {
                        HStack{
                            Text("Méga-\(last_pokemon.name.fr)").foregroundStyle(colorScheme == .dark ? Color.white : Color.black).bold()
                            Divider()
                            Text("Orbe : \(c_mega.orbe)").foregroundStyle(colorScheme == .dark ? Color.white : Color.black).font(.system(size: 14))
                        }
                        
                        pokemon_image(sprite_regular: c_mega.sprites.regular, sprite_shiny: c_mega.sprites.shiny, gradient: Gradient(colors: [Color.red, Color.purple]))
                        
                    }
                }
            }
        }
           
    }
    
    var gigamax_card: some View{
        VStack{
            if let dynamax_sprites = last_pokemon.sprites.gmax {
                HStack{
                    Text("\(last_pokemon.name.fr) GigaMax").foregroundStyle(colorScheme == .dark ? Color.white : Color.black).bold()
                }
                
                pokemon_image(sprite_regular: dynamax_sprites.regular, sprite_shiny: dynamax_sprites.shiny ?? "", gradient: Gradient(colors: [Color.red, Color.purple]))
            }
        }
    }
    
    struct loader: View {
        let pokemon: Pokemon
        
        var body: some View {
            KFImage(URL(string: pokemon.sprites.regular))
                .resizable()
                .frame(width: 0)
                .scaledToFit()
                .frame(height: 12)
        }
    }
    
    func get_selected_value(selection: String) -> Int {
        let selectedStatValue: Int
        switch barSelection {
            case "Hp":
                selectedStatValue = pokemon.stats.hp
            case "Atk":
                selectedStatValue = pokemon.stats.atk
            case "Def":
                selectedStatValue = pokemon.stats.def
            case "Spe. Atk":
                selectedStatValue = pokemon.stats.spe_atk
            case "Spe. Def":
                selectedStatValue = pokemon.stats.spe_def
            case "Vit":
                selectedStatValue = pokemon.stats.vit
            default:
                selectedStatValue = 0
        }
        return selectedStatValue
    }
}
