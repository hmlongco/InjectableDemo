//
//  InjectableDemoApp.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import Foundation

@main
struct InjectableDemoApp: App {
    init() {
        //Injections.registerMockServices()
    }
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
