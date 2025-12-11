//
//  Item.swift
//  ScamGuard
//
//  Created by 有田健一郎 on 2025/12/12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
