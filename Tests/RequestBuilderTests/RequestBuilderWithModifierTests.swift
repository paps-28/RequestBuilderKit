//
//  RequestBuilderWithModifierTests.swift
//  RequestBuilder
//
//  Created by Pedro Alberto Parra on 12/10/26.
//


import XCTest
@testable import RequestBuilder

final class RequestBuilderWithModifierTests: XCTestCase {
    
    // MARK: - BodyModifier con Class
    
    func testAddBody_WithTimestampModifier_AddsTimestamp() throws {
        let urlString = "https://api.example.com/data"
        
        let builder = RequestBuilder(urlString: urlString)
            .addBody(key: "timestamp", modifier: TimestampModifier())
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        guard let timestampValue = json?["timestamp"] else {
            XCTFail("La clave 'timestamp' no fue añadida al body")
            return
        }
        
        // El valor debe ser un String (o Double)
        XCTAssertNotNil(Double(timestampValue as! String))
    }

    // MARK: - BodyModifier con Closure
    
    func testAddBody_WithClosureModifier_AddsComputedValue() throws {
        let urlString = "https://api.example.com/data"
        
        let builder = RequestBuilder(urlString: urlString)
            .addBody(key: "user_id", value: "123")
            .addBody(key: "computed") { body in
                guard let userId = body["user_id"] as? String else { return nil }
                return "computed-\(userId)"
            }
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        XCTAssertEqual(json?["computed"] as? String, "computed-123")
    }
    
    func testAddBody_WithClosureModifier_UsesNilIfConditionNotMet() throws {
        let urlString = "https://api.example.com/data"
        
        // El closure devuelve nil si no hay clave "user_id"
        let builder = RequestBuilder(urlString: urlString)
            .addBody(key: "computed") { body in
                guard let userId = body["user_id"] as? String else { return nil }
                return "computed-\(userId)"
            }
        
        let request = try builder.build()
        
        // La clave "computed" no debería existir
        XCTAssertNil(request.httpBody)
    }
}
