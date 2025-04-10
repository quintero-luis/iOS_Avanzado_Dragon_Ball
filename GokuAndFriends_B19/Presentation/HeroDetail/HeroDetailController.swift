//
//  HeroDetailControllerViewController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 3/4/25.
//

import UIKit
import MapKit
import CoreLocation

enum TransformationSection {
    case main
}

class HeroDetailController: UIViewController {
    
    typealias DataSourceTransformation = UICollectionViewDiffableDataSource<TransformationSection, HeroTransformations>
    
    typealias CellRegistration = UICollectionView.CellRegistration<TransformationCell , HeroTransformations>
    
    // Transformations CollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var heroNameLabel: UILabel!
    
    @IBOutlet weak var heroDescriptionLabel: UITextView!
  
    private var viewModel: HeroDetailViewModel
    
    private var transformationViewModel: TransformationsViewModel
    
    
    private var locationManager: CLLocationManager = .init()
    
    private var dataSource: DataSourceTransformation?
    
    
    init(viewModel: HeroDetailViewModel) {
        self.viewModel = viewModel
        self.transformationViewModel = TransformationsViewModel(hero: viewModel.heroInstance, useCase: TransformationsUseCase())
        super.init(nibName: String(describing: HeroDetailController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurateView() {
        mapView.delegate = self
        mapView.pitchButtonVisibility = .visible
        mapView.showsUserLocation = true
        
        configure_CollectionView_Transformations()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurateView()
        listenChangesInViewModel()
        /// Transformations
        listen_States_Changes_In_View_Model_For_Transformations()
        checkLocationAuthorizationStatus()
        viewModel.loadData()
        
        
        // Transformaitons
        transformationViewModel.loadTransformationsData()
        
        
        // Mostrar detalle de héroe
        heroDetails()
        
    }
    
    /// Transformations 1
    func configure_CollectionView_Transformations() {
        collectionView.delegate = self
        
        let nib = UINib(nibName: TransformationCell.identifier, bundle: nil)
        let cellRegistration = CellRegistration(cellNib: nib) {  cell, indexPath, transformation in
            
            cell.configureWithTrans(transformation: transformation)
        }
        
        dataSource = DataSourceTransformation(collectionView: collectionView, cellProvider: {collectionView, indexPath, transformation in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: transformation)
        })
    }
        
        
        func listen_States_Changes_In_View_Model_For_Transformations() {
            transformationViewModel.stateTransformationChanged = { [weak self] state in
                switch state {
                    
                case .transformation_Data_Updated:
                    self?.updateCollectionView()
                case .errorLoadingTransformations(error: let error):
                    print("Error cargando transformaciones: \(error.localizedDescription)")
                }
                
            }
            
        }
    
    func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<TransformationSection, HeroTransformations>()
        snapshot.appendSections([.main])
        snapshot.appendItems(transformationViewModel.getTransformations(), toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
        
        
        // MARK: - Función para nombre y descripción de héroe
        private func heroDetails() {
            heroNameLabel.text = viewModel.heroName
            heroDescriptionLabel.text = viewModel.heroDescription
        }
        
        // MARK: - Botón de Transformaciones
//        
//        @IBAction func transformationsButtonTapped(_ sender: UIButton) {
//            
//            
//            
//        }
        
        func listenChangesInViewModel() {
            viewModel.stateChanged = { [weak self] state in
                switch state {
                case .locationsUpdated:
                    self?.addAnnotationsToMAp()
                case .errorLoadingLocation(error: let error):
                    debugPrint(error.localizedDescription)
                }
            }
        }
        
        func addAnnotationsToMAp() {
            let annotations = mapView.annotations
            if !annotations.isEmpty {
                mapView.removeAnnotations(annotations)
            }
            mapView.addAnnotations(viewModel.getHeroLocations())
            
            if let annotation = mapView.annotations.sorted(by: {$0.coordinate.latitude > $1.coordinate.latitude}).first {
                mapView.region = MKCoordinateRegion(center: annotation.coordinate,
                                                    latitudinalMeters: 100_000,
                                                    longitudinalMeters: 100_000)
            }
        }
        
        private func checkLocationAuthorizationStatus() {
            
            let status = locationManager.authorizationStatus
            
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                mapView.showsUserLocation = false
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserTrackingButton = true
                locationManager.startUpdatingLocation()
            @unknown default:
                break
            }
        }
    }
    
    extension HeroDetailController: MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
            
            guard annotation is HeroAnnotation else {
                return nil
            }
            if  let view = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) {
                return view
            }
            return HeroAnnotationView(annotation: annotation, reuseIdentifier: HeroAnnotationView.identifier)
        }
    }

extension HeroDetailController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 80.0)
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            let transformation = transformationViewModel.getTransformations()[indexPath.row]
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransformationCell.identifier, for: indexPath) as! TransformationCell
//            cell.configureWithTrans(transformation: transformation)
//            return cell
//        }
    
    
}

