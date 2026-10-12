//
//  RequestSender.swift
//  RequestBuilder
//
//  Created by Pedro Alberto Parra on 12/10/26.
//

import Foundation

/// Servicio encargado exclusivamente de lanzar `URLRequest`.
public struct RequestSender {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    public func send(_ request: URLRequest, completion: @escaping @Sendable (Result<Data, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(data!))
        }
        task.resume()
    }
    
    public func send(_ request: URLRequest) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }.resume()
        }
    }
}
