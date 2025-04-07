//
//  HeroDetailControllerViewController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 3/4/25.
//

import UIKit
import MapKit
import CoreLocation

class HeroDetailController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var heroNameLabel: UILabel!
    
    @IBOutlet weak var heroDescriptionLabel: UILabel!
    private var viewModel: HeroDetailViewModel
    private var locationManager: CLLocationManager = .init()
    
    init(viewModel: HeroDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroDetailController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurateView() {
        mapView.delegate = self
        mapView.pitchButtonVisibility = .visible
        mapView.showsUserLocation = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        listenChangesInViewModel()
        checkLocationAuthorizationStatus()
        viewModel.loadData()
        // Mostrar detalle de héroe
        heroDetails()
    }
    
    // MARK: - Función para nombre y descripción de héroe
    private func heroDetails() {
        heroNameLabel.text = viewModel.heroName
        heroDescriptionLabel.text = viewModel.heroDescription
    }
    
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
