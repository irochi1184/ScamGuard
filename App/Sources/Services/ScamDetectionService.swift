import Foundation
import Combine

protocol ScamDetectionService {
    func riskEvents() -> AnyPublisher<ScamRiskEvent, Never>
    func start()
    func stop()
}

final class MockScamDetectionService: ScamDetectionService {
    private let subject = PassthroughSubject<ScamRiskEvent, Never>()
    private var timerCancellable: AnyCancellable?

    func start() {
        let immediateEvent = ScamRiskEvent(
            occurredAt: Date(),
            message: "AI検知で不審な国際電話を警告しました"
        )
        subject.send(immediateEvent)

        timerCancellable = Timer
            .publish(every: 20, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                let event = ScamRiskEvent(
                    occurredAt: date,
                    message: "疑わしい発信を検知し、遮断候補に追加"
                )
                self?.subject.send(event)
            }
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func riskEvents() -> AnyPublisher<ScamRiskEvent, Never> {
        subject.eraseToAnyPublisher()
    }
}
