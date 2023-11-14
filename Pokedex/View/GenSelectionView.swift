import SwiftUI

struct GenSelectionView: View {
    @State private var isShowingCopyrightModal = false
    @State private var selectedGeneration = 1
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            GeometryReader { geometry in
                Form {
                    Picker("Generations", selection: $selectedGeneration) {
                        ForEach(1..<10) { generation in
                            Text("Generation \(generation)")
                                .tag(generation)
                        }
                    }.pickerStyle(.inline)
                    
                    NavigationLink(destination: PokemonListView(generation: selectedGeneration)) {
                        Text("Voir la liste de pokemons")
                    }
                }.frame(height: geometry.size.height)
            }
            
            Button(action: {
                self.isShowingCopyrightModal.toggle()
            }) {
                Text("Droits d'auteur et Licence")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $isShowingCopyrightModal) {
                CopyrightModalView()
            }
        }.navigationTitle("Générations")
    }
}

struct CopyrightModalView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {

                ScrollView {
                    Text("""
                    © 2023 [PokéAPI](https://tyradex.vercel.app/) créée par Yarkis & Ashzuu (Données provenant de Poképédia & Serebii)

                    © Pokémon et tous les noms respectifs sont des marques déposées de The Pokémon Company International, Game Freak et Nintendo.
                    """)
                    .font(.body)
                    .padding()
                    
                    Divider()
                    
                    Text("""
                    Licence MIT de l'api utilisée

                    Copyright (c) 2022 Yarkis

                    Permission is hereby granted, free of charge, to any person obtaining a copy
                    of this software and associated documentation files (the "Software"), to deal
                    in the Software without restriction, including without limitation the rights
                    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                    copies of the Software, and to permit persons to whom the Software is
                    furnished to do so, subject to the following conditions:

                    The above copyright notice and this permission notice shall be included in all
                    copies or substantial portions of the Software.

                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                    SOFTWARE.
                    """)
                    .font(.body)
                    .padding()
                }

                Spacer()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Fermer")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .navigationBarTitle("Droits d'auteur et Licence", displayMode: .inline)
            
        }.edgesIgnoringSafeArea(.bottom)
    }
}
