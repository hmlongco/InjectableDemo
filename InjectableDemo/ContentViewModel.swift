//
//  ContentViewModel.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import Foundation

class ContentViewModel {
    
    @Injectable(\.myServiceType) var service: MyServiceType
    
    var id: String {
        service.service()
    }
    
    func test() {
        print(service.service())
    }
    
}


extension Injections {
    var contentViewModel: ContentViewModel { ContentViewModel() }
}
