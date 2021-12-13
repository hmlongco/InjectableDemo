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
    @Injectable var myInjectableType: MyInjectableType
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

// service with constructor injection

class ConstructedService {
    init(_ myServiceType: MyServiceType) {
        // demo
    }
}

// testing injectable type

final class MyInjectableType {
    init() {
        print("init MyInjectableType")
    }
}

extension MyInjectableType: InjectableType {
    static func resolve(_ args: Any?) -> MyInjectableType {
        MyInjectableType()
    }
}
