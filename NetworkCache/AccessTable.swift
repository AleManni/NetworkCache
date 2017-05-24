//
//  AccessTable.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation

struct AccessTable {
    private var table: [String: Int] = [:]
    var leastAccessed: String {
        return table.sorted(by: { $0.value < $1.value})[0].key
    }
    var count: Int {
        return table.count
    }

    mutating func increaseCount(for imageKey: String) {
        if var count = table[imageKey] {
            count += 1
            table[imageKey] = count
        } else {
            table[imageKey] = 0
        }
    }

    mutating func deleteEntry(for imageKey: String) {
        table.removeValue(forKey: imageKey)
    }

    mutating func clearAll() {
        table.removeAll()
    }
}
