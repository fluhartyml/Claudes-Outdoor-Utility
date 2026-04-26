//
//  Item.swift
//  Claudes Outdoor Utility
//
//  Created by Michael Fluharty on 4/26/26.
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
