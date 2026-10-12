//
//  BodyModifierTests.swift
//  RequestBuilder
//
//  Created by Pedro Alberto Parra on 12/10/26.
//


import XCTest
@testable import RequestBuilder

final class BodyModifierTests: XCTestCase {

    // MARK: - TimestampModifier
    
    func testTimestampModifier_GeneratesValidTimestampString() {
        // Para este test, inyectamos un date falso
        let modifier = TimestampModifier()
        let timestamp = modifier.modify(currentBody: [:], forKey: "timestamp") // En un test real podrías inyectar el date
        
        // Como no podemos inyectar el date en este ejemplo simple,
        // verificamos que el resultado es un String y que se puede parsear a un Date
        guard let timestampString = timestamp else {
            XCTFail("El timestamp modifier no devolvió un valor")
            return
        }
        
        // Verificamos que es un String
        XCTAssertTrue(type(of: timestampString) == String.self, "Debería ser un String")
        
        // Intentamos convertirlo a Double
        let valueAsDouble = Double(timestampString)
        XCTAssertNotNil(valueAsDouble, "El timestamp debería ser convertibles a Double")
        
        // Verificamos que el valor es "reciente" (más reciente que 1 segundo atrás)
        let now = Date().timeIntervalSince1970
        let threshold = now - 1.0
        XCTAssertGreaterThanOrEqual(valueAsDouble!, threshold, "El timestamp debería ser reciente")
    }

    
    // MARK: - Modificador Personalizado con closure
    func testCustomClosureModifier_UsesBody() {
       
        let initialBody = ["input": "data"]
        
        let modifier: ([String: Any]) -> Any? = { body in
            // Lógica personalizada: combina "input" con un prefijo
            return "PREFIX-\(body["input"] ?? "")"
        }
        
        let result = modifier(initialBody)
        XCTAssertEqual(result as? String, "PREFIX-data")
    }
}
