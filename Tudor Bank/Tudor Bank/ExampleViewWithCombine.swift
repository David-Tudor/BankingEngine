//
//  ExampleViewWithCombine.swift
//  Tudor Bank
//
//  Created by Rolando Rodriguez on 15/10/2023.
//

import SwiftUI
import Combine

enum Names {
    case pepe(String)
    case david
}

// Unwrapping associated value of Enum. You have two ways of doing it:

func accessValue(of name: Names) {
    switch name {
        case .david:
            break
        case .pepe(let value):
            break
    }
    
    if case let .pepe(value) = name {
        // then consume string
    }
}

// End of.


struct MyCustomTextField {
    let onTextChange: (String) -> ()
    
    private var storedText = ""
    
    // CurrentValueSubject // stores a value in memory
    // PassthroughSubject // sends values to subscribers but doesn´t store them in memory

    // Future -> Async work
    // Just -> Sync
    // flatMap we use this to create new publishers based on the emmited value of another publisher
    
    var textChangedPublisher = CurrentValueSubject<String, Never>("")
    
    var modifiedTextPublisher: AnyPublisher<String, Never> {
        textChangedPublisher
            .map { originalText in
                "Modified by David! " + originalText
            }
            .eraseToAnyPublisher()
    }
    
    init(onTextChange: @escaping (String) -> Void) {
        self.onTextChange = onTextChange
    }
    
    func doSomeAyncValidationWorkOnThis(string: String) -> Bool {
        if string.contains("shit") || string.contains("fuck") {
            return false
        }
        
        return true
    }
    
    func buildValidationAsyncPublisher(with string: String) -> Future<Bool, Error> {
        let validationAsyncPublisher = Future<Bool, Error> { promise in
            // Do work
            let isValid = doSomeAyncValidationWorkOnThis(string: string)
            
            promise(.success(isValid))
        }

            
// MARK: Possible values here david!
//            promise(.success(true))
//            promise(.success(false))
//            promise(.failure(myError))
        
//        validationAsyncPublisher.sink { completion in
//            // when does it finish? A publisher finishes when it error or whenever it emits a value.
//            if case let .failure(error) = completion {
//                // publisher failed
//            }
//
//        } receiveValue: { result in
//            // whenever the publisher succeeds and emits a value
//        }
        
        return validationAsyncPublisher
    }
    
    private func textDidUpdate() {
        // some logic here
        
        onTextChange(storedText)
        
        var justPepe: AnyPublisher<Int, Never> = modifiedTextPublisher
            .flatMap({ string in
                Just(123456)
            })
            .eraseToAnyPublisher()
        
        

        
        var shouldButtonBeEnabledPublisher: AnyPublisher<Bool, Never> {
           return modifiedTextPublisher
                .flatMap({ modifiedText in
                    buildValidationAsyncPublisher(with: modifiedText)
                        .catch { error in
                            Just(false)
                        }
                })
                .eraseToAnyPublisher()
        }
        
       
        
    
        
        textChangedPublisher.send(storedText)
    }
}

let customField = MyCustomTextField(onTextChange: { text in
    // do something
    // call API
    // lbah algd
})

var myFirstSubscription: AnyCancellable?
var subscriptions = Set<AnyCancellable>()

func subscribeExample() {
    myFirstSubscription = customField.modifiedTextPublisher.sink { modifiedText in
        // runs every time modifiedTextPublisher emits a value
        //
    }
    
    // myFirstSubscription?.cancel()
    
    customField.textChangedPublisher.sink { text in
        // runs every tine textChangedPublisher emits a value
        // body.reRender()
    }.store(in: &subscriptions)
}

class MyModel: ObservableObject {
    @Published var text = ""
    @Published var header = "Hello!"
        
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = isTextSaintPublisher.sink { completion in
            // no-op
        } receiveValue: { [weak self] isTextValid in
            guard let self else {
                return
            }
            
            header = isTextValid ? "Hey there! Type like saint" : "Naughty dickhead!"
        }
    }

    func buildValidationAsyncPublisher(with string: String) -> Future<Bool, Error> {
        let validationAsyncPublisher = Future<Bool, Error> { promise in
            // Do work
            let isValid = self.doSomeAyncValidationWorkOnThis(string: string)
            
            promise(.success(isValid))
        }
        return validationAsyncPublisher
    }

    
    func doSomeAyncValidationWorkOnThis(string: String) -> Bool {
        if string.contains("shit") || string.contains("fuck") {
            return false
        }
        
        return true
    }
    
    var isTextSaintPublisher: AnyPublisher<Bool, Never> {
        return $text
            .flatMap({ text in
                self.buildValidationAsyncPublisher(with: text)
                    .catch { error in
                        Just(false)
                    }
            })
            .eraseToAnyPublisher()
    }
}


struct ExampleViewWithCombine: View {
    @StateObject private var model = MyModel()
    
    var header: String = ""
    
    var body: some View {
        VStack {
            Text(model.header)
            
            TextField("Type here!", text: $model.text)
        }
    }
}

#Preview {
    ExampleViewWithCombine()
}
