import XCTest
@testable import RequestBuilder

final class RequestBuilderTests: XCTestCase {
    
    // MARK: - Inicialización y Propiedades Básicas
    
    func testInit_SetsURLString() throws {
        let urlString = "https://api.example.com/v1/users"
        let builder = RequestBuilder(urlString: urlString)
        let request = try builder.build()
        
        XCTAssertEqual(request.url?.absoluteString, urlString)
    }
    
    func testMethod_SetsHTTPMethod() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .method(.post)
        
        let request = try builder.build()
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func testAddHeader_AddsHeaderToRequest() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .addHeader(key: "Authorization", value: "Bearer token123")
            .addHeader(key: "X-Custom", value: "MyValue")
        
        let request = try builder.build()
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token123")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Custom"), "MyValue")
    }
    
    func testHeaders_OverwritesAllHeaders() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .addHeader(key: "A", value: "1")
            .addHeader(key: "B", value: "2")
            .headers(["C": "3", "D": "4"])
        
        let request = try builder.build()
        XCTAssertEqual(request.value(forHTTPHeaderField: "A"), nil)
        XCTAssertEqual(request.value(forHTTPHeaderField: "C"), "3")
    }

    // MARK: - Query Items
    
    func testSetQuery_AddsQueryItem() throws {
        let urlString = "https://api.example.com/users"
        let builder = RequestBuilder(urlString: urlString)
            .setQuery(key: "page", value: "2")
        
        let request = try builder.build()
        XCTAssertEqual(request.url?.query, "page=2")
    }
    
    func testSetQuery_UpdatesExistingQueryItem() throws {
        let urlString = "https://api.example.com/users?page=1"
        let builder = RequestBuilder(urlString: urlString)
            .setQuery(key: "page", value: "3")
        
        let request = try builder.build()
        XCTAssertEqual(request.url?.query, "page=3")
    }
    
    func testSetQuery_NilsValueRemovesQueryItem() throws {
        let urlString = "https://api.example.com/users?page=1&sort=asc"
        let builder = RequestBuilder(urlString: urlString)
            .setQuery(key: "page", value: nil)
        
        let request = try builder.build()
        XCTAssertNil(request.url?.query)
    }
    
    func testSetQueries_AddsMultipleQueryItems() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .setQueries(["page": "1", "limit": "10"])
        
        let request = try builder.build()
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems?.sorted(by: { $0.name < $1.name })
        
        XCTAssertEqual(queryItems?.count, 2)
        XCTAssertEqual(queryItems?[0].name, "limit")
        XCTAssertEqual(queryItems?[0].value, "10")
        XCTAssertEqual(queryItems?[1].name, "page")
        XCTAssertEqual(queryItems?[1].value, "1")
    }
    
    // MARK: - Body
    
    func testAddBody_AddsStringToJSONBody() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .addBody(key: "name", value: "Ana")
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        XCTAssertEqual(json?["name"] as? String, "Ana")
    }
    
    func testAddBody_AddsIntToJSONBody() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .addBody(key: "age", value: 30)
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        guard let age = json?["age"] as? NSNumber else {
            XCTFail("age no es un número")
            return
        }
        XCTAssertEqual(age.int32Value, 30)
    }
    
    func testAddBody_AddsBoolToJSONBody() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .addBody(key: "isActive", value: true)
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        XCTAssertEqual(json?["isActive"] as? Bool, true)
    }

    func testAddBody_AddsNestedDictionary() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .addBody(key: "address", value: ["city": "Madrid", "zip": "28001"])
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        let address = json?["address"] as? [String: String]
        XCTAssertEqual(address?["city"], "Madrid")
        XCTAssertEqual(address?["zip"], "28001")
    }
    
    func testAddBody_AddsArray() throws {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .addBody(key: "scores", value: [10, 20, 30])
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        XCTAssertEqual(json?["scores"] as? [Int], [10, 20, 30])
    }

    func testJSONBody_OverwritesEntireBody() throws {
        let builder = try RequestBuilder(urlString: "https://api.example.com")
            .addBody(key: "a", value: "1")
            .addBody(key: "b", value: "2")
            .setJSONBody(["c": "3"])
        
        let request = try builder.build()
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        
        XCTAssertEqual(json?.count, 1)
        XCTAssertEqual(json?["c"] as? String, "3")
    }
    
    // MARK: - Combinaciones
    
    func testBuilder_ComposesURLWithQueryAndHeadersAndBody() throws {
        let urlString = "https://api.example.com/users"
        let builder = RequestBuilder(urlString: urlString)
            .method(.post)
            .addHeader(key: "Content-Type", value: "application/json")
            .addHeader(key: "Authorization", value: "Bearer token")
            .setQuery(key: "source", value: "mobile")
            .addBody(key: "name", value: "Carlos")
            .addBody(key: "age", value: 25)
        
        let request = try builder.build()
        
        XCTAssertEqual(request.url?.query, "source=mobile")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        
        let json = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: Any]
        XCTAssertEqual(json?["name"] as? String, "Carlos")
        XCTAssertEqual(json?["age"] as? Int, 25)
    }
    
    func testBuilder_IsFluentAndChainable() {
        let builder = RequestBuilder(urlString: "https://api.example.com")
            .method(.get)
            .addHeader(key: "A", value: "1")
            .addHeader(key: "B", value: "2")
            .setQuery(key: "X", value: "Y")
            .addBody(key: "K", value: "V")
        
        XCTAssertNotNil(builder)
    }
}

private extension XCTestCase {
    func assertURL(_ url: URL?, matches expected: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let url = url else { XCTFail("URL es nil", file: file, line: line); return }
        XCTAssertEqual(url.absoluteString, expected, file: file, line: line)
    }
}
