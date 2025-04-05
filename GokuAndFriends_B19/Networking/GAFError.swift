//
//  GAFError.swift
//  GokuAndFriends_B19
//
//  Created by Luis Quintero on 27/3/25.
//
import Foundation


// Enum para usar errorres personalizados en la api
enum GAFError: Error {
    case badUrl
    case serverErrot(error: Error)
    case responseError(code: Int?)
    case noDataReceived
    case errorPArsingData
    case sessionTokenMissed
}
