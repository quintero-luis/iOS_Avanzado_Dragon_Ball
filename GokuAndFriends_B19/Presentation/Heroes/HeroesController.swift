//
//  HeroesController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//

import UIKit

enum HeroesSections {
    case main
}

class HeroesController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<HeroesSections, Hero>
    typealias CellRegistration = UICollectionView.CellRegistration<HeroCell , Hero>
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: HeroesViewModel
    private var datasource: DataSource?
    
    init(viewModel: HeroesViewModel = HeroesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroesController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listneStatesChangesInViewModel()
        configureCollectionView()
        viewModel.loadData()
    }

    func configureCollectionView() {
        collectionView.delegate = self
        
        // Usamos un CellRegistration para crear las celdas  una ventaja que tiene es que si usamos el objeto como
        // identificador ya nos viene en el handler y no necesitamos acceder a él por su indexPath
        let nib = UINib(nibName: HeroCell.identifier, bundle: nil)
        let cellRegistration = CellRegistration(cellNib: nib) { cell, indexPath, hero in
            cell.configureWith(hero: hero)
        }
        
        datasource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: hero)
        })
    }
    
    
    func listneStatesChangesInViewModel() {
        
        // Ecuchamos los cambio de estado del viewModel y actualizamos el interfaz
        viewModel.stateChanged = { [weak self] state in
            switch state {
            case .dataUpdated:
                var snapshot = NSDiffableDataSourceSnapshot<HeroesSections, Hero>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self?.viewModel.fetchHeroes() ?? [], toSection: .main)
                self?.datasource?.applySnapshotUsingReloadData(snapshot)
                
            case .errorLoadingHeroes(error: let error):
                print(error)
            }
        }
    }
    
    // Al pulsar en logout limpiamos la BBDD y volverá a usar el servicio al pedir los heroes el caso de uso
    @IBAction func logoutTapped(_ sender: Any) {
        viewModel.performLogout()
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension HeroesController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 80.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let hero = viewModel.heroWith(index: indexPath.row) else {
            return
        }
        let viewModel = HeroDetailViewModel(hero: hero)
        let heroDetail = HeroDetailController(viewModel: viewModel)
        navigationController?.pushViewController(heroDetail, animated: true)
        
        // Ejemeplo para mostrar un controller de forma modal.
        //present(heroDetail, animated: true)
    }
}
