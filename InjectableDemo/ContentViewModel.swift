//
//  ContentViewModel.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import Foundation

class ContentViewModel: ObservableObject {
    
    @Injectable(\.myServiceType) var service

    @Published var count = 0
    @Published var string = ""

    var id: String {
        service.service()
    }

    init() {
        print("init ContentViewModel")
    }

    deinit {
        print("deinit ContentViewModel")
    }

    func bump() {
        count += 1
    }
    
    func test() {
        print(service.service() + " = \(count)")
    }
}
