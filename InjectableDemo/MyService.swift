//
//  MyService.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import Foundation

protocol MyServiceType  {
    func service() -> String
}

class MyService: MyServiceType {
    private let id = UUID()
    func service() -> String {
        "Service \(id)"
    }
}

class MockService: MyServiceType {
    private let id = UUID()
    func service() -> String {
        "Mock \(id)"
    }
}

extension Injections {
    var myServiceType: MyServiceType { shared( MyService() ) }
}

extension Injections {
    static func registerMockServices() {
        container.register { container.shared( MockService() ) as MyServiceType }
    }
}
