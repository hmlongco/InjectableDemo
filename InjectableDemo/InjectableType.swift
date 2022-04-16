////
////  InjectableType.swift
////  InjectableDemo
////
////  Created by Michael Long on 1/2/22.
////
//
//import Foundation
//
//#define INJECTABLE
//
//// add simple injectable type
//
//public protocol InjectableType {
//    static func resolve(_ args: Any?) -> Self
//}
//
//extension Injectable {
//    public init() where Service: InjectableType {
//        self.service = (Injections.container as? InjectableTypeSupport)?.resolve(nil)
//    }
//}
//
//public class InjectableTypeSupport: Injections {
//
//    public override init() {}
//
//    public func register<Service>(factory: @escaping (_ arg: Any) -> Service) {
//        defer { lock.unlock() }
//        lock.lock()
//        let id = Int(bitPattern: ObjectIdentifier(Service.self))
//        registrationsArgs[id] = factory
//    }
//
//    public func resolve<Service>(_ args: Any? = nil) -> Service where Service: InjectableType {
//        return registered(args) ?? Service.resolve(args)
//    }
//
//    public func registered<Service>(_ args: Any?) -> Service? {
//        defer { lock.unlock() }
//        lock.lock()
//        let id = Int(bitPattern: ObjectIdentifier(Service.self))
//        return registrationsArgs[id]?(args) as? Service
//    }
//
//    public override func reset() {
//        super.reset()
//        registrationsArgs = [:]
//    }
//
//    internal var registrationsArgs: [Int:(_ arg: Any?) -> Any] = [:]
//
//}
//// testing injectable type
//
//final class MyInjectableType {
//    init() {
//        print("init MyInjectableType")
//    }
//}
//
//extension MyInjectableType: InjectableType {
//    static func resolve(_ args: Any?) -> MyInjectableType {
//        MyInjectableType()
//    }
//}
