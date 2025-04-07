//
//  StoreDataProvider.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//

import Foundation
import CoreData


// Enum para indicar los tipos de persistencia de nuestro BBDD de Core Data
enum TypePersistence {
    case disk        // Guarda los datos en disco
    case inMemoery   // Guarda los datos solo en memoria (ideal para pruebas)
}

class StoreDataProvider {
    // Singleton para uso general
    static let shared: StoreDataProvider = .init()
    
//    Usarmos la directiva de compilación DEBUG crear un singleton con persistencia en memoria y que
//    solo se pueda usar en Modeo debug
#if DEBUG
    static let sharedTesting: StoreDataProvider = .init(persistence: .inMemoery)
#endif
    // Contenedor principal de Core Data, administra el modelo y los contextos
    let persistentContainer: NSPersistentContainer
    
    // Contexto principal que usamos para leer/escribir en la base de datos
    lazy var context: NSManagedObjectContext = {
        let viewContext = self.persistentContainer.viewContext
        // Política de merge que da prioridad a los objetos en memoria en caso de conflicto
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }()
    // Constructor privado para que solo se use la instancia shared
    // como es un singleton el constructor es privado
    private init(persistence: TypePersistence = .disk) {
        // URL.applicationSupportDirectory
        // Nos da el path donde está añijada la BBDD en el dispositivo
        // Se puede acceder al simulador desde finder
        
        self.persistentContainer = NSPersistentContainer(name: "Model")
        
        // Si usamos persistencia en memoria (ej. en tests), redirigimos la URL del store
        if persistence == .inMemoery {
            let persistentStore = self.persistentContainer.persistentStoreDescriptions.first
            // para persistir en memoria asignamos la url al persistent Store
            persistentStore?.url = URL(filePath: "dev/null")
        }
        // Cargamos el store de Core Data y en caso de fallo, detenemos la ejecución
        self.persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Core data couldn't load BBDD from Model \(error)")
            }
        }
    }
    
    // Guarda los cambios del contexto en la base de datos
    func saveContext() {
        context.perform {  // Noaseguramos de usar el contextos en thread donde fué creado
            guard self.context.hasChanges else { return }
            do {
                try self.context.save()
            } catch {
                debugPrint("There was an error saving the context \(error)")
            }
        }
    }
}

extension StoreDataProvider {
    
    // Devuelve una lista de héroes aplicando un filtro opcional y orden por nombre
    func fetchHeroes(filter: NSPredicate?, sortAscending: Bool = true) -> [MOHero] {
        let request = MOHero.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \MOHero.name, ascending: sortAscending)
        
       // esto es lo mismo que el descriptor de arriba pero usando un string para el campo por el que queremos ordenar
      //  NSSortDescriptor(key: "name", ascending: sortAscending)
        
        request.sortDescriptors = [sortDescriptor]
        request.predicate = filter
        return (try? context.fetch(request)) ?? []
    }
    
    /// Devuelve el número total de héroes en la base de datos
    func numHeroes() -> Int {
        return (try? context.count(for: MOHero.fetchRequest())) ?? -1
    }
    
    /// Inserta una lista de héroes en la base de datos y guarda los cambios
    // Inserta heroes en contexto y persiste en BBDD con saveContext()
    func insert(heroes: [ApiHero]) {
        for hero in heroes {
            let newHero = MOHero(context: context)
            newHero.identifier = hero.id
            newHero.name = hero.name
            newHero.info = hero.description
            newHero.photo = hero.photo
            newHero.favorite = hero.favorite ?? false
        }
        saveContext()
    }
    
    // Inserta localizaciones de heroes en contexto y persiste en BBDD con saveContext()
    func insert(locations: [ApiHeroLocation]) {
        for location in locations {
            let newLocation = MOHeroLocation(context: context)
            newLocation.identifier = location.id
            newLocation.latitude = location.latitude
            newLocation.longitude = location.longitude
            newLocation.date = location.date
            
            if let identifier = location.hero?.id {
                let predicate = NSPredicate(format: "identifier == %@", identifier)
                newLocation.hero = fetchHeroes(filter: predicate).first
            }
        }
        saveContext()
    }
    
    // MARK: - Funciones de Transformaciones:
    
    // Devuelve una lista de transformaciones aplicando un filtro opcional y orden por nombre
    func fetchHeroTransformations(filter: NSPredicate?, sortAscending: Bool = true) -> [MOHeroTransformations] {
        let request = MOHeroTransformations.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \MOHeroTransformations.name, ascending: sortAscending)
        
        request.sortDescriptors = [sortDescriptor]
        request.predicate = filter
        return (try? context.fetch(request)) ?? []
    }
    
    // Inserta transformaciones de heroes en contexto y persiste en BBDD con saveContext()
    
    func insertTransformations(transformations: [ApiHeroTransformation]) {
        for transformation in transformations {
            let newTransformation = MOHeroTransformations(context: context)
            newTransformation.id = transformation.id
            newTransformation.name = transformation.name
            newTransformation.info = transformation.description
            newTransformation.photo = transformation.photo
            
            if let id = transformation.hero?.id {
                let predicate = NSPredicate(format: "id == %@", id)
                newTransformation.hero = fetchHeroes(filter: predicate).first
            }
        }
        saveContext()
    }
    
    /// Devuelve el número de transformaciones asociadas a un héroe
    func numTransformations(for hero: MOHero) -> Int {
        let request = MOHeroTransformations.fetchRequest()
        request.predicate = NSPredicate(format: "hero == %@", hero)
        return (try? context.count(for: request)) ?? -1
    }

    
    // MARK: Transformation añadido
    func clearBBDD() {
        // Quitamos los cambios pendientes que haya en el contexto
        context.rollback()
        
        // creamos los procesos batch de borrado, estos procesos se ejecutan  contra el Store, la BBDD  y no en el contexto.
        let deleteHeroes = NSBatchDeleteRequest(fetchRequest: MOHero.fetchRequest())
        let deleteHeroLocations = NSBatchDeleteRequest(fetchRequest: MOHeroLocation.fetchRequest())
        let deleteTransformations = NSBatchDeleteRequest(fetchRequest: MOHeroTransformations.fetchRequest())
        
        for task in [deleteHeroes, deleteHeroLocations, deleteTransformations] {
            do {
                try context.execute(task)
            } catch {
                debugPrint("There wwas an error clearing BBDD \(error)")
            }
        }
    }
}
