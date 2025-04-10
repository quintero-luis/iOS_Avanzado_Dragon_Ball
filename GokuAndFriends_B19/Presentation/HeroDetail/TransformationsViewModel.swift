//
//  TransformationsViewModel.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 08/04/25.
//

enum TransformationsState {
    case transformation_Data_Updated
    case errorLoadingTransformations(error: GAFError)
}

class TransformationsViewModel {
    
    private var useCase: TransformationsUseCaseProtocol
    
    private var transformations: [HeroTransformations] = []
    private var hero: Hero
    
    
    var stateTransformationChanged: ((TransformationsState) -> Void)?
    
    init(hero: Hero, useCase: TransformationsUseCaseProtocol) {
        self.useCase = useCase
        self.hero = hero
    }
    
    func loadTransformationsData() {
        useCase.fetchTransformationsForHeroWith(id: hero.id) { [weak self] result in
            switch result {
            case .success(let transformations):
                self?.transformations = transformations
                
                self?.stateTransformationChanged?(.transformation_Data_Updated)
            case .failure(let error):
                self?.stateTransformationChanged?(.errorLoadingTransformations(error: error))
            }
        }
    }
    
    func getTransformations() -> [HeroTransformations] {
        return transformations
    }
    
    func numberOfRows() -> Int {
        return transformations.count
    }
 
}




