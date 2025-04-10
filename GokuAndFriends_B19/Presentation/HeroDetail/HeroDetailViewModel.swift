//
//  HeroDetailState.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 3/4/25.
//

import Foundation

enum HeroDetailState {
    case locationsUpdated
    case errorLoadingLocation(error: GAFError)
<<<<<<< HEAD
    //Caso para transformacion
    case errorLoadingTransformations(error: GAFError)
    case transformationsUpdated
=======
    
>>>>>>> dev
}

class HeroDetailViewModel {
    private var heroes: [Hero] = []
    
    private var useCase: HeroDetailUseCaseProtocol
    
    private var locations: [HeroLocation] = []
<<<<<<< HEAD
    var hero: Hero
    // Transformaciones añadido
    private var transformations: [HeroTransformations] = [] // Almacenara las transformaciones
=======
    
    private var hero: Hero

    
    
>>>>>>> dev
    var stateChanged: ((HeroDetailState) -> Void)?
     
    
    
    init(hero: Hero, useCase: HeroDetailUseCaseProtocol = HeroDEtailUseCase()) {
        self.hero = hero
        self.useCase = useCase
    }
    
    // MARK: - Variables para mostrar nobmre y descripcion de héroe
    
    var heroName: String {
        return hero.name ?? ""
    }
    
    var heroDescription: String {
        return hero.description ?? ""
    }
    
    var heroInstance: Hero {
        return hero
    }
    
    
    // Para cargar ubicaciones
    func loadLocations() {
        useCase.fetchLocationsForHeroWith(id: hero.id) { [weak self]  result in
            switch result {
            case .success(let locations):
                self?.locations = locations
                self?.stateChanged?(.locationsUpdated)
            case .failure(let error):
                self?.stateChanged?(.errorLoadingLocation(error: error))
            }
        }
        
        
    }
    
    // Cargar transformaciones
    func loadTransformations() {
        // Cargar las transformaciones
        useCase.fetchTransformationsForHeroWith(id: hero.id) { [weak self] result in
            switch result {
            case .success(let transformations):
                self?.transformations = transformations
                self?.stateChanged?(.transformationsUpdated)
                print("Transformations loaded: \(transformations)")
            case .failure(let error):
                // Maneja el error si es necesario
                print("Error loading transformations: \(error.localizedDescription)")
                self?.stateChanged?(.errorLoadingLocation(error: error))
            }
        }
    }
    
    
    // Numero de transformaciones
    
//    func getTransformations() -> [MOHeroTransformations] {
////        let predicate = NSPredicate(format: "hero.identifier == %@", hero.id)
////        return StoreDataProvider.shared.fetchHeroTransformations(filter: predicate)
//        let predicate = NSPredicate(format: "hero.identifier == %@", hero.id)
//            let transformations = StoreDataProvider.shared.fetchHeroTransformations(filter: predicate)
//            print("Fetched Transformations: \(transformations)")  // Depuración: imprime las transformaciones obtenidas
//            return transformations
//    }
    func getTransformations() -> [HeroTransformations] {
        return transformations  // Devuelve las transformaciones almacenadas
    }
    
    // Para cargar transformaciones
    
    
    func getHeroLocations() -> [HeroAnnotation] {
        var annotations: [HeroAnnotation] = []
        for location in locations {
            if let coordinate = location.coordinate {
                annotations.append(HeroAnnotation(coordinate: coordinate, title: hero.name))
            }
        }
        return annotations
    }
}
