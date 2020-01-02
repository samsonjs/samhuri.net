//
//  YearPosts.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2020-01-01.
//

import Foundation

struct YearPosts {
    let year: Int
    var byMonth: [Month: MonthPosts]
    let path: String

    var title: String {
        "\(year)"
    }

    var isEmpty: Bool {
        byMonth.isEmpty || byMonth.values.allSatisfy { $0.isEmpty }
    }

    var months: [Month] {
        Array(byMonth.keys)
    }

    subscript(month: Month) -> MonthPosts {
        get {
            byMonth[month, default: MonthPosts(month: month, posts: [], path: "\(path)/\(month.padded)")]
        }
        set {
            byMonth[month] = newValue
        }
    }

    /// Returns an array of all posts.
    func flattened() -> [Post] {
        byMonth.values.flatMap { $0.posts }
    }
}
