import Foundation

/// Una clase builder para construir `URLRequest` de forma segura y fluída.
public final class RequestBuilder {
    private var urlString: String
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var queryItems: [URLQueryItem] = []
    private var body: [String: Any] = [:]

    public init(urlString: String) {
        self.urlString = urlString
    }

    public func method(_ method: HTTPMethod) -> RequestBuilder {
        let copy = self
        copy.method = method
        return copy
    }

    public func addHeader(key: String, value: String) -> RequestBuilder {
        let copy = self
        copy.headers[key] = value
        return copy
    }
    
    public func headers(_ headers: [String: String]) -> RequestBuilder {
        let copy = self
        copy.headers = headers
        return copy
    }

    public func setQuery(key: String, value: String?) -> RequestBuilder {
        let copy = self
        if let value = value, !value.isEmpty {
               // Añadimos al array interno, sin tocar `URLComponents` ni `self.urlString`
            let existingIndex = copy.queryItems.firstIndex(where: { $0.name == key })
            if let index = existingIndex {
                copy.queryItems[index].value = value
            } else {
                copy.queryItems.append(URLQueryItem(name: key, value: value))
            }
        } else if let existingIndex = copy.queryItems.firstIndex(where: { $0.name == key }) {
               // Si el valor es nil o vacío, lo eliminamos del array
            copy.queryItems.remove(at: existingIndex)
        }
        return copy
    }

    public func setQueries(_ queries: [String: String]) -> RequestBuilder {
        let copy = self
        queries.forEach { key, value in
            _ = copy.setQuery(key: key, value: value)
        }
        return copy
    }
    
    public func setJSONBody(_ json: [String: Any]) throws -> RequestBuilder {
        let copy = self
        copy.body = json
        return copy
    }
    
    public func addBodyAsString<T: CustomStringConvertible>(key: String, value: T) -> RequestBuilder {
        let copy = self
        copy.body[key] = value.description
        return copy
    }
    
    public func addBody(key: String, value: Any) -> RequestBuilder {
        let copy = self
        copy.body[key] = value
        return copy
    }
    
    public func addBody<M: BodyModifier>(key: String, modifier: M) -> RequestBuilder where M.ValueType: CustomStringConvertible {
        let copy = self
        if let newValue = modifier.modify(currentBody: copy.body, forKey: key) {
            copy.body[key] = newValue.description
        }
        return copy
    }
    
    public func addBody(key: String, valueProvider: ([String: Any]) -> Any?) -> RequestBuilder {
        let copy = self
        if let newValue = valueProvider(copy.body) {
            copy.body[key] = newValue
        }
        return copy
    }

    public func build() throws -> URLRequest {
        guard let baseURL = URL(string: urlString) else {
            throw NSError(domain: "RequestBuilder", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string: \(urlString)"])
        }
        
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = baseURL.path
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let finalURL = components.url else {
            throw NSError(domain: "RequestBuilder", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not construct final URL with query parameters"])
        }
            
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
            
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
            
        if !body.isEmpty {
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
