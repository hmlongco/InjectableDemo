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
    static func resolve(_ args: Any?) -> Self
}

// Injectable property wrapper

@propertyWrapper public struct Injectable<Service> {
    
    private var service: Service
    
    public init() where Service: InjectableType {
        self.service = Injections.container.resolve()
    }
    
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.service = Injections.container.resolve(keyPath)
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

@propertyWrapper public struct LazyInjectable<Service:InjectableType> {
    
    var args: Any?
    
    private var service: Service!
    
    public init() {
        // lazy, does nothing
    }
    
    public var wrappedValue: Service {
        mutating get {
            if service == nil {
                self.service = Injections.container.resolve(args)
            }
            return service
        }
        mutating set { service = newValue }
    }
    
    public var projectedValue: LazyInjectable<Service> {
        get { return self }
        mutating set { self = newValue }
    }
    
}

// additional wrapper for SwfitUI that allows for observable objects

@propertyWrapper public struct InjectableObject<Service>: DynamicProperty where Service: ObservableObject {
    
    @ObservedObject private var service: Service
    
    public init() where Service: InjectableType {
        self.service = Injections.container.resolve()
    }
    
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.service = Injections.container.resolve(keyPath)
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
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        registrations[id] = factory
    }
    
    func register<Service>(factory: @escaping (_ arg: Any) -> Service) {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        registrationsArgs[id] = factory
    }
    
    
    func resolve<Service>() -> Service where Service: InjectableType {
        return Injections.container.registered() ?? Service.resolve(nil)
    }

    func resolve<Service>(_ args: Any?) -> Service where Service: InjectableType {
        return Injections.container.registered(args) ?? Service.resolve(args)
    }

    func resolve<Service>(_ keyPath: KeyPath<Injections, Service>) -> Service {
        return registered() ?? Self.container[keyPath: keyPath]
    }
    
    
    func registered<Service>() -> Service? {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        return registrations[id]?() as? Service
    }
    
    func registered<Service>(_ args: Any?) -> Service? {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        return registrationsArgs[id]?(args) as? Service
    }
    
    func reset() {
        registrations = [:]
        registrationsArgs = [:]
    }

    private init() {}
    private var registrations: [Int:() -> Any] = [:]
    private var registrationsArgs: [Int:(_ arg: Any?) -> Any] = [:]
    private var lock = NSRecursiveLock()

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
        let id = Int(bitPattern: ObjectIdentifier(S.self))
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
        let id = Int(bitPattern: ObjectIdentifier(S.self))
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
