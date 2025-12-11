import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var isIncomingBlockEnabled: Bool = true
    @Published var isOutgoingBlockEnabled: Bool = true
    @Published var internationalBlockEnabled: Bool = true
    @Published var blockedNumbers: [BlockedNumber] = []
    @Published var latestAdvisory: String?
    @Published var detectedRiskCount: Int = 0
    @Published var recentRiskEvents: [ScamRiskEvent] = []

    private let numberProvider: ScamNumberProvider
    private let detectionService: ScamDetectionService
    private let advisoryService: SecurityAdvisoryService
    private var cancellables: Set<AnyCancellable> = []

    init(
        numberProvider: ScamNumberProvider = PoliceListNumberProvider(),
        detectionService: ScamDetectionService = MockScamDetectionService(),
        advisoryService: SecurityAdvisoryService = MockSecurityAdvisoryService()
    ) {
        self.numberProvider = numberProvider
        self.detectionService = detectionService
        self.advisoryService = advisoryService
        setupBindings()
        detectionService.start()
    }

    deinit {
        detectionService.stop()
    }

    func setupBindings() {
        numberProvider
            .recommendedNumbers()
            .receive(on: DispatchQueue.main)
            .assign(to: &$blockedNumbers)

        advisoryService
            .latestAdvisory()
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestAdvisory)

        detectionService
            .riskEvents()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                detectedRiskCount += 1
                recentRiskEvents.insert(event, at: 0)
                recentRiskEvents = Array(recentRiskEvents.prefix(5))
            }
            .store(in: &cancellables)
    }

    func refreshPoliceList() {
        numberProvider.refresh()
        advisoryService.refresh()
    }

    func resetCounters() {
        detectedRiskCount = 0
        recentRiskEvents.removeAll()
    }
}
