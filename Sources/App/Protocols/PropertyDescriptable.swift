//
//  PropertyDescriptable.swift
//  App
//
//  Created by João Campos on 30/07/2018.
//

import Vapor

protocol PropertyDescribable: Reflectable {
    associatedtype Object: Reflectable
}

extension PropertyDescribable {
    static func describe<T>(withKeyPath keyPath: KeyPath<Object, T>) throws -> String? {
        guard let property = try Object.reflectProperty(forKey: keyPath)?.description.split(separator: ":")[0] else {
            return nil
        }
        return String(property)
    }
}
