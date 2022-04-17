//
//  ContentView.swift
//  InjectableDemo
//
//  Created by Michael Long on 7/31/21.
//

import SwiftUI

struct ContentView: View {
    init() {
        print("init ContentView")
    }
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Test", destination: TestView())
            }
            .onAppear {
                print("ContentView appeared")
            }
        }
    }
}

struct TestView: View {
    @StateObject var viewModel = TestViewModel()
    init() {
        print("init TestView")
    }
    var body: some View {
        Text("TestView")
            .onAppear {
                print("TestView appeared")
            }
    }
}

class TestViewModel: ObservableObject {
    @Injectable(\.myService) var service
    let id = UUID()
    init() {
        print("init VM \(id)")
    }
    deinit {
        print("deinit VM \(id)")
    }
}


class TestViewModel2: ObservableObject {
    @Injectable(\.myService) var service
    @Injectable(\.constructedService) var constructedService
    let id = UUID()
    init() {
        print("init vm \(id)")
        print("init vm using \(service.id)")
    }
    deinit {
        print("deinit vm \(id)")
        print("deinit vm using \(service.id)")
    }
}

struct TestView2: View {

    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("\(viewModel.id)")
                .font(.footnote)

            Text("\(viewModel.count)")

            TextField("Name", text: $viewModel.string)

            Button("Increment") {
                viewModel.bump()
            }

            NavigationLink("Next", destination: TestView2())
        }
        .padding()
        .onAppear {
            viewModel.test()
        }
    }

}

struct WrappedTestView: View {
    var body: some View {
        TestView2()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Injections.container.registerMockServices()
        return ContentView()
    }
}
