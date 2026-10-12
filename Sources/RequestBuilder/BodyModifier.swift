//
//  BodyModifier.swift
//  RequestBuilder
//
//  Created by Pedro Alberto Parra on 12/10/26.
//

import Foundation

public protocol BodyModifier {
    associatedtype ValueType
    
    func modify(currentBody: [String: Any], forKey key: String) -> ValueType?
}


extension BodyModifier {
    func modify(currentBody: [String: Any], forKey key: String) -> Any? {
        return nil
    }
}
