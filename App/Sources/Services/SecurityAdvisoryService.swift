import Foundation
import Combine

protocol SecurityAdvisoryService {
    func latestAdvisory() -> AnyPublisher<String?, Never>
    func refresh()
}

final class MockSecurityAdvisoryService: SecurityAdvisoryService {
    private let advisories: [String] = [
        "警察庁推奨リストを自動更新し、国際電話番号からの着信をブロックします。",
        "+から始まる番号の不審なSMSに注意し、金融情報は入力しないでください。",
        "架空料金請求の電話が増加中。家族や知人を装う手口に注意。"
    ]

    private let subject: CurrentValueSubject<String?, Never>
    private var nextIndex = 0

    init() {
        subject = CurrentValueSubject<String?, Never>(advisories.first)
        nextIndex = advisories.indices.dropFirst().first ?? 0
    }

    func latestAdvisory() -> AnyPublisher<String?, Never> {
        subject.eraseToAnyPublisher()
    }

    func refresh() {
        guard !advisories.isEmpty else { return }
        let advisory = advisories[nextIndex]
        subject.send(advisory)
        nextIndex = advisories.index(after: nextIndex) % advisories.count
    }
}
