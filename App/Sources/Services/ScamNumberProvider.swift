import Foundation
import Combine

protocol ScamNumberProvider {
    func recommendedNumbers() -> AnyPublisher<[BlockedNumber], Never>
    func refresh()
}

final class PoliceListNumberProvider: ScamNumberProvider {
    private let subject = CurrentValueSubject<[BlockedNumber], Never>([])

    init() {
        loadInitialList()
    }

    func recommendedNumbers() -> AnyPublisher<[BlockedNumber], Never> {
        subject.eraseToAnyPublisher()
    }

    func refresh() {
        // Stub: replace with API integration for official police feed
        loadInitialList()
    }

    private func loadInitialList() {
        let seed = [
            BlockedNumber(
                displayName: "国際詐欺番号",
                number: "+441234567890",
                source: .international,
                reason: "海外番号からの不審な高額請求事例"
            ),
            BlockedNumber(
                displayName: "警察庁推奨リスト",
                number: "0330000000",
                source: .policeRecommended,
                reason: "警察庁提供リストに掲載"
            ),
            BlockedNumber(
                displayName: "架空料金請求の発信元",
                number: "05088880000",
                source: .aiDetected,
                reason: "AI検知で疑わしい音声パターンを検出"
            )
        ]
        subject.send(seed)
    }
}
