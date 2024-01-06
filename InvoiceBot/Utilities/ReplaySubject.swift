import Combine
import Foundation

extension Publisher {
    func shareReplay(_ bufferSize: Int) -> AnyPublisher<Output, Failure> {
        return multicast(subject: ReplaySubject(bufferSize: bufferSize))
            .autoconnect()
            .eraseToAnyPublisher()
    }
}

final class ReplaySubject<Output, Failure: Error>: Subject {
    private var buffer: [Output]
    private let bufferSize: Int
    private var subscriptions: [Subscription] = []

    init(bufferSize: Int) {
        self.bufferSize = bufferSize
        buffer = []
    }

    func send(subscription: Combine.Subscription) {
        // No operation needed for this custom subject
    }

    func send(_ value: Output) {
        buffer.append(value)
        if buffer.count > bufferSize {
            buffer.removeFirst()
        }
        subscriptions.forEach {
            _ = $0.receive(value)
        }
    }

    func send(completion: Subscribers.Completion<Failure>) {
        subscriptions.forEach { $0.receive(completion: completion) }
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, subject: self)
        subscriber.receive(subscription: subscription)
        subscriptions.append(subscription)
    }

    private class Subscription: Combine.Subscription {
        var subject: ReplaySubject
        var subscriber: AnySubscriber<Output, Failure>?

        init<S: Subscriber>(subscriber: S, subject: ReplaySubject) where S.Input == Output, S.Failure == Failure {
            self.subscriber = AnySubscriber(subscriber)
            self.subject = subject
            subject.buffer.forEach { _ = self.subscriber?.receive($0) }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
        }

        func receive(_ input: Output) -> Subscribers.Demand {
            return subscriber?.receive(input) ?? .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            subscriber?.receive(completion: completion)
            subscriber = nil
        }
    }
}
