//
//  Injectable.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import Foundation
import SwiftUI

// add simple injectable type

public protocol InjectableType {
    static func resolve() -> Self
}

// Injectable property wrapper

@propertyWrapper public struct Injectable<Service> {
    
    private var service: Service
    
    public init() where Service: InjectableType {
        self.service = Injections.container.resolve() ?? Service.resolve()
    }
    
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.service = Injections.container.resolve() ?? Injections.container[keyPath: keyPath]
    }
    
    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    
    public var projectedValue: Injectable<Service> {
        get { return self }
        mutating set { self = newValue }
    }
    
}

// additional wrapper for SwfitUI that allows for observable objects

@propertyWrapper public struct InjectableObject<Service>: DynamicProperty where Service: ObservableObject {
    
    @ObservedObject private var service: Service
    
    public init() where Service: InjectableType {
        self.service = Injections.container.resolve() ?? Service.resolve()
    }
    
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.service = Injections.container.resolve() ?? Injections.container[keyPath: keyPath]
    }

    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    
    public var projectedValue: ObservedObject<Service>.Wrapper {
        return self.$service
    }
    
}


// add core container class for factories with registration and resolution mechanisms for overrides

public class Injections {
    
    static let container = Injections()
    
    func register<Service>(factory: @escaping () -> Service) {
        let id = ObjectIdentifier(Service.self).hashValue
        registrations[id] = factory
    }
        
    func resolve<Service>() -> Service? {
        let id = ObjectIdentifier(Service.self).hashValue
        if let service = registrations[id]?() as? Service {
            return service
        }
        return nil
    }
    
    func reset() {
        registrations = [:]
    }

    private init() {}
    private var registrations: [Int:() -> Any] = [:]
    
}

// add basic scoping mechanisms

extension Injections {
    // singleton scope where services exist for lifetime of the app
    var application: InjectableScope { Self.applicationScope }
    private static var applicationScope = InjectableApplicationScope()
    
    // cached scope where services exist until scope is reset
    var cached: InjectableScope { Self.cacheScope }
    private static var cacheScope = InjectableCacheScope()
    
    // shared scope where services are maintained until last reference is released
    var shared: InjectableScope { Self.sharedScope }
    private static var sharedScope = InjectableSharedScope()
}

protocol InjectableScope {
    func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S
}

class InjectableApplicationScope: InjectableScope {
    func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S {
        defer { lock.unlock() }
        lock.lock()
        let id = ObjectIdentifier(S.self).hashValue
        if let service = cache[id] as? S {
            return service
        }
        let service = factory()
        cache[id] = service
        return service
    }
    fileprivate var cache = [Int:Any]()
    fileprivate var lock = NSRecursiveLock()
}

class InjectableCacheScope: InjectableApplicationScope {
    func reset() {
        defer { lock.unlock() }
        lock.lock()
        cache = [:]
    }
}

class InjectableSharedScope: InjectableScope {
    private struct WeakBox {
        weak var service: AnyObject?
    }
    func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S {
        defer { lock.unlock() }
        lock.lock()
        let id = ObjectIdentifier(S.self).hashValue
        if let service = cache[id]?.service as? S {
            return service
        }
        let service = factory()
        cache[id] = WeakBox(service: service as AnyObject)
        return service
    }
    func reset() {
        defer { lock.unlock() }
        lock.lock()
        cache = [:]
    }
    private var cache = [Int:WeakBox]()
    private var lock = NSRecursiveLock()
}
