#  Pokdedex iOS app

## iOS application using [PokéAPI](https://api-pokemon-fr.vercel.app/)

This Application is a Pokédex, it allows you to display all pokemons of each 9 generations. You can also see the details of each Pokémon including : 
- Sprites
- Types 
- Abilities
- Stats
- Resistances
- Weaknesses
- Evolution chain

This application was made with Swift 5.9 and Xcode 15.0, it uses cacaoPods to install the following libraries :
- Kingfisher 6.0 : to display images from URL and cache them

## Installation

To install this application, you need to have Xcode 15.0 installed on your computer.
  
Then, you need to clone this repository on your computer and open the project with Xcode.

Finally, you need to install the pods by running the following command in the terminal : 
```bash
pod install
```

## Usage

To use this application, you need to run it on a simulator or on a real device with iOS 16.4 or higher.

## Screenshots

### Pokemon Generation's Choice screen

This screen displays all the 9 generations of pokemons, you can click on one of them to display all the pokemons of this generation.

There is also a button at the bottom of the screen to display all the credits and rights of the application.

<img src="/README screenshots/gen_choice.jpg" alt="gen_choice" style="width:250px;"/>

### Pokemon List screen

This screen displays all the pokemons of the choosen generation. You can click on a pokemon to display its details.

<img src="/README screenshots/pokemons_list_view.jpg" alt="pokemons_list" style="width:250px;"/>

### Pokemon details screen

This screen displays all pokemon details, you can click the ✨ buttons to display shiny (alternatives colors of the pokemon) sprites. You also can click on every evolutions to display their details.

<img src="/README screenshots/p_1.jpg" alt="details_1" style="width:250px;"/>
<img src="/README screenshots/p_2.jpg" alt="details_2" style="width:250px;"/>
<img src="/README screenshots/p_2.jpg" alt="details_3" style="width:250px;"/>


## Incoming features

- Add a search bar to search a specific Pokémon
- Add a filter to display only Pokémon of a specific type
- Add english and japanese translations