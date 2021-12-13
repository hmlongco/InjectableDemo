//
//  InjectableDemoApp+Injections.swift
//  InjectableDemo
//
//  Created by Michael Long on 12/13/21.
//

import Foundation

// basic injection extensions

extension Injections {
    var contentViewModel: ContentViewModel { shared( ContentViewModel() ) }
}

extension Injections {
    var myServiceType: MyServiceType { shared( MyService() ) }
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
    static func registerMockServices() {
        container.register { container.shared( MockService() ) as MyServiceType }
    }
}
