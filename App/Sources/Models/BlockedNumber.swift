import Foundation

struct BlockedNumber: Identifiable, Hashable {
    let id = UUID()
    let displayName: String
    let number: String
    let source: BlockSource
    let reason: String

    enum BlockSource: String {
        case policeRecommended = "警察庁リスト"
        case international = "国際番号"
        case aiDetected = "AI検知"
    }
}
