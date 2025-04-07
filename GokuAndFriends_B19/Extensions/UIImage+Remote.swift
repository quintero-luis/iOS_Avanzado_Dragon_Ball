//
//  UIImage+Remote.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 06/04/25.
//

import UIKit

extension UIImageView {
    func setImage(url: URL) {
        downloadWithURLSession(url: url) { [weak self] result in
            switch result {
                case let .success(image):
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                case .failure:
                    break
            }
        }
    }
    
    private func downloadWithURLSession(
        url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data,
                  let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "Image Download Error", code: 0)))
                return
            }
            
            completion(.success(image))
        }
        .resume()
    }
}
