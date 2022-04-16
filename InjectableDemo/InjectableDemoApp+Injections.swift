//
//  InjectableDemoApp+Injections.swift
//  InjectableDemo
//
//  Created by Michael Long on 12/13/21.
//

import Foundation

// basic injection extensions

extension Injections {
    var myServiceType: MyServiceType { shared( MyService() as MyServiceType ) }
    var mockServiceType: MyServiceType { MockService() }
}

// testing constructor injection

extension Injections {
    var constructedService: ConstructedService {
        ConstructedService(resolve(\.myServiceType))
    }
}

// testing registering mocks

extension Injections {
    func registerMockServices() {
        register { self.shared( MockService() ) as MyServiceType }
    }
}
