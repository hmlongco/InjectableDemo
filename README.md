# InjectableDemo

Preliminary musings and demonstration code for a simple Swift property-wrapper, keypath-based dependency injection system. The keypaths ensure compile-time safety for all injectable services.

Injectable also supports overriding services for mocking and testing purposes, as well as a rudimentary thread-safe scoping system that enables unique, shared, cached, and application-level scopes for services.

## Demo Code
Here's a SwiftUI view that uses an injectable view model.

```swift
struct ContentView: View {
    
    @InjectableObject(\.contentViewModel) var viewModel: ContentViewModel
    
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
```
And here's the code for the view model which in turn has its own injectable service. 
```Swift
class ContentViewModel {
    
    @Injectable(\.myServiceType) var service: MyServiceType
    
    var id: String {
        service.service()
    }
    
    func test() {
        print(service.service())
    }
}
```
Note that `MyServiceType` is a protocol and as such can be overridden with other values for testing.

The service protocol, service, and a mock service appear as follows.
```swift
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
```

## Resolving the ViewModel and Services

Here's are the registrations that resolve the various keypaths. 
```swift
extension Injections {
    var contentViewModel: ContentViewModel { shared( ContentViewModel() ) }
    var myServiceType: MyServiceType { shared( MyService() ) }
}
```
For each one we extend `Injections` to add a factory closure that will be called to provide a new instance of the viewmodel or service when needed.

Note that we're using shared scopes here in order to ensure persistance across view updates in SwiftUI.

## Mocking and Testing

The key to overriding a given service for mocking and testing lies in adding a Resolver-style inferred-type registration factory that will override the keypath registration.
```swift
extension Injections {
    static func registerMockServices() {
        container.register { MockService() as MyServiceType }
        // others as needed
    }
}
```
Here's an example of the mocks being used in the ContentView preview.
```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Injections.registerMockServices()
        return ContentView()
    }
}
```

## Injectable

And finally, here's part of the @Injectable property wrapper that demonstrates the basic technique used. The initialization function checks to see if an override exists (optional). If not it resorts to using the required keypath.
```swift
@propertyWrapper public struct Injectable<Service> {
    
    private var service: Service
    
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.service = Injections.container.resolve() ?? Injections.container[keyPath: keyPath]
    }
    
    ...
    
}
```
As the initializer requires the keypath, it *must* exist. Thus all registrations are required to exist, which ensures compile-time safety.

Overrides to the keypaths are exceptions to the rule, and are treated as such.

All of the code, including the code for the scopes, requires about 160 lines of code. That also includes an addtional property wrapper, `@InjectableObject`, which can be used in SwiftUI code like an `ObservableObject`. 

## The Idea

The impetus for this code and demo resolves around an article written by Antoine van der Lee, titled [Dependency Injection in Swift using latest Swift features](https://www.avanderlee.com/swift/dependency-injection/).

That article, in turn, triggered my own Medium article, [I Hate Swift. I Love Swift](https://medium.com/geekculture/i-hate-swift-i-love-swift-318171a0f0df), where I detailed some of my own attempts to solve some of the issues perceived in Antoine's original approach.

And this is the final result.
