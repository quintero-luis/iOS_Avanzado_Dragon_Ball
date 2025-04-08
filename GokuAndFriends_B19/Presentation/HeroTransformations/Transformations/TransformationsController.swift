//
//  TransformationsController.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 07/04/25.
//

//import UIKit
//
//class TransformationsController: UITableViewController {
//    
//    
//    
//    private var viewModel: HeroDetailViewModel
//    
//    init(viewModel: HeroDetailViewModel) {
//        self.viewModel = viewModel
//        super.init(style: .plain)
//    }
//        
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//        
//        viewModel.loadData()
//        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransformationCell")
//    }
//
//    // MARK: - Table view data source
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.getTransformations().count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TransformationCell", for: indexPath) as! TransformationCell
//        
//        let transformation = viewModel.getTransformations()[indexPath.row]
//        cell.configureTransformationCell(with: transformation)
//        return cell
//    }
//}

import UIKit

// Asegúrate de que TransformationsController implemente el protocolo HeroDetailControllerDelegate
class TransformationsController: UITableViewController, HeroDetailControllerDelegate {

    private var viewModel: HeroDetailViewModel

    init(viewModel: HeroDetailViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Transformations"
        
        // REGISTRA TU CELDA PERSONALIZADA (XIB)
        tableView.register(UINib(nibName: "TransformationCell", bundle: nil), forCellReuseIdentifier: "TransformationCell")

        // CARGA LOS DATOS
        viewModel.loadTransformations()

        // ESCUCHA LOS CAMBIOS EN EL VIEWMODEL Y RECARGA LA TABLA
        viewModel.stateChanged = { [weak self] state in
            switch state {
            case .locationsUpdated:
                self?.tableView.reloadData()  // Asegúrate de que se recargue la tabla
            case .errorLoadingLocation(let error):
                debugPrint("Error: \(error.localizedDescription)")
            case .errorLoadingTransformations(error: let error):
                debugPrint("Error: \(error.localizedDescription)")
            case .transformationsUpdated:
                // Aquí llamamos a la función del delegado cuando las transformaciones se actualicen
                self?.didUpdateTransformations()
            }
        }

        // Asignamos el delegado para que se actualice la vista de las transformaciones
        if let heroDetailController = navigationController?.viewControllers.first(where: { $0 is HeroDetailController }) as? HeroDetailController {
            heroDetailController.delegate = self  // Asignamos el delegado
        }
    }

    // MARK: - HeroDetailControllerDelegate
    // Implementación del delegado que maneja la actualización de las transformaciones
    func didUpdateTransformations() {
        // Recargamos la tabla cuando las transformaciones cambian
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTransformations().count
    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransformationCell", for: indexPath) as? TransformationCell else {
//            return UITableViewCell()
//        }
//
//        let transformation = viewModel.getTransformations()[indexPath.row]
//        cell.configureTransformationCell(with: transformation)
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Desencolar la celda personalizada (asegúrate de que TransformationCell esté registrada en tu table view)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransformationCell", for: indexPath) as? TransformationCell else {
            return UITableViewCell()
        }

        // Obtener la transformación correspondiente al índice de la fila
        let transformation = viewModel.getTransformations()[indexPath.row]
        
        // Configurar la celda con la transformación
        cell.configureTransformationCell(with: transformation)

        // Retornar la celda configurada
        return cell
    }
}
