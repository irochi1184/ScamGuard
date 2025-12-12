import Combine
import Foundation

enum CallAction: String {
    case block = "遮断"
    case warn = "警告"
    case allow = "許可"
}

struct CallEvaluationResult {
    let action: CallAction
    let reasons: [String]
    let notifications: [String]
    let timestamp: Date
}

final class ScamLogicEngine: ObservableObject {
    @Published private(set) var policeListedNumbers: [ScamNumber]
    @Published private(set) var aiDetections: [ScamNumber]
    @Published private(set) var reportQueue: [String] = []

    private let riskyKeywords: [String] = ["還付", "送金", "口座", "ワンタイム", "確認コード", "身分証", "至急"]

    init() {
        policeListedNumbers = [
            .init(number: "+44 20 7946 0999", label: "国際送金要求", source: "警察庁リスト", isInternational: true, lastUpdated: "11/11 09:00"),
            .init(number: "+65 3123 4567", label: "銀行サポート偽装", source: "警察庁リスト", isInternational: true, lastUpdated: "11/10 17:40"),
            .init(number: "050-1234-5678", label: "自治体調査装う", source: "警察庁リスト", isInternational: false, lastUpdated: "11/09 13:20")
        ]

        aiDetections = [
            .init(number: "+81 90-9876-5432", label: "還付金詐欺ボイスを検知", source: "AI自動検知", isInternational: false, lastUpdated: "11/11 12:05"),
            .init(number: "+1 646-555-0100", label: "国際番号からの未承諾勧誘", source: "AI自動検知", isInternational: true, lastUpdated: "11/10 21:15")
        ]
    }

    func evaluateCall(number: String, isInternational: Bool, transcript: String, blockInternational: Bool, blockPoliceList: Bool, aiDetection: Bool, showWarnings: Bool, autoReport: Bool) -> CallEvaluationResult {
        var reasons: [String] = []
        var notifications: [String] = []
        var action: CallAction = .allow

        if blockInternational && isInternational {
            reasons.append("国際番号は即遮断設定")
            action = .block
        }

        if blockPoliceList && isPoliceListed(number: number) {
            reasons.append("警察庁提供リストに一致")
            action = .block
        }

        if aiDetection, let risk = detectRisk(in: transcript) {
            let label = "AI検知: \(risk.keyword) を含む不審ワード"
            reasons.append(label)
            let shouldBlock = risk.score > 1
            action = shouldBlock ? .block : (action == .block ? .block : .warn)
            appendDetection(for: number, label: label, isInternational: isInternational)
        }

        if action == .allow && showWarnings && (isInternational || !reasons.isEmpty) {
            action = .warn
            if reasons.isEmpty {
                reasons.append("国際番号への注意喚起")
            }
        }

        if autoReport && action != .allow {
            let reportMessage = "\(number) を \(action.rawValue) し警察へ匿名共有"
            reportQueue.append(reportMessage)
            notifications.append("自動報告キューへ追加")
        }

        if reasons.isEmpty {
            reasons.append("検知されたリスクなし")
        }

        return CallEvaluationResult(action: action, reasons: reasons, notifications: notifications, timestamp: Date())
    }

    func isPoliceListed(number: String) -> Bool {
        policeListedNumbers.contains { $0.number.replacingOccurrences(of: " ", with: "") == number.replacingOccurrences(of: " ", with: "") }
    }

    private func detectRisk(in transcript: String) -> (keyword: String, score: Int)? {
        let lowercased = transcript.lowercased()
        var highest: (keyword: String, score: Int)?
        for keyword in riskyKeywords {
            let count = lowercased.components(separatedBy: keyword.lowercased()).count - 1
            guard count > 0 else { continue }
            if highest == nil || count > highest!.score {
                highest = (keyword, count)
            }
        }
        return highest
    }

    private func appendDetection(for number: String, label: String, isInternational: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        let timeStamp = formatter.string(from: Date())
        let detection = ScamNumber(number: number, label: label, source: "AI自動検知", isInternational: isInternational, lastUpdated: timeStamp)
        aiDetections.insert(detection, at: 0)
    }
}
