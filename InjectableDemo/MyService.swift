//
//  MyService.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import Foundation

protocol MyServiceType  {
    var id: UUID { get }
    func service() -> String
}

class MyService: MyServiceType {
    let id = UUID()
    init() {
        print("init MyService \(id)")
    }
    deinit {
        print("deinit MyService \(id)")
    }
    func service() -> String {
        "Service \(id)"
    }
}

class MockService: MyServiceType {
    let id = UUID()
    func service() -> String {
        "Mock \(id)"
    }
}

// service with constructor injection

class ConstructedService {
    let id = UUID()
    let service: MyServiceType
    init(_ service: MyServiceType) {
        self.service = service
        print("init ConstructedService \(id)")
        print("init ConstructedService using \(service.id)")
    }
    deinit {
        print("deinit ConstructedService \(id)")
        print("deinit ConstructedService using \(service.id)")
    }
}
