//
//  ContentView.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import SwiftUI

struct ContentView: View {
    
    @Injectable(\.contentViewModel) var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(viewModel.id)")
                .font(.footnote)
            
            NavigationLink("Next", destination: ContentView())
        }
        .onAppear(perform: {
            viewModel.test()
        })
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Injections.registerMockServices()
        return ContentView()
    }
}
