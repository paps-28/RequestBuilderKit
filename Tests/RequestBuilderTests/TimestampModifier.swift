//
//  TimestampModifier.swift
//  RequestBuilder
//
//  Created by Pedro Alberto Parra on 12/10/26.
//


import Foundation
import RequestBuilder

/// Un `BodyModifier` que añade un timestamp (segundos desde 1970) al cuerpo.
/// Puedes usar `Date()` para inyectar un date fijo en los tests.
struct TimestampModifier: BodyModifier {
    private let dateProvider: () -> Date
    
    // Inicializador por defecto, usa la fecha actual.
    init() {
        self.dateProvider = { Date() }
    }
    
    // Inicializador para tests, permite inyectar una fecha fija.
    init(date: Date) {
        self.dateProvider = { date }
    }
    
    func modify(currentBody: [String: Any], forKey key: String) -> String? {
        let date = dateProvider()
        // Usamos `timeIntervalSince1970` para un timestamp estándar
        // Convertimos a `Int` para evitar decimales y tener un JSON más limpio.
        let timestamp = Int(date.timeIntervalSince1970)
        return String(timestamp)
    }
}
