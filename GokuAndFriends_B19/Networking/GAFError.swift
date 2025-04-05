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

/// Conforma al protocolo Error, lo que permite usarlo en throw y catch.
/*
 Si hay error en la conexión, retorna .serverErrot(error).

 Si el código HTTP no es 200, retorna .responseError(code).

 Si no hay datos en la respuesta, retorna .noDataReceived.

 Si falla la decodificación JSON, retorna .errorPArsingData.
 */
