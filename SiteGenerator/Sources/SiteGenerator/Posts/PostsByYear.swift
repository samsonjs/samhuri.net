//
//  Posts.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct MonthPosts {
    let month: Month
    var posts: [Post]

    var title: String {
        month.padded
    }

    var isEmpty: Bool {
        posts.isEmpty
    }
}

// MARK: -

struct YearPosts {
    let year: Int
    var byMonth: [Month: MonthPosts]

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
            byMonth[month, default: MonthPosts(month: month, posts: [])]
        }
        set {
            byMonth[month] = newValue
        }
    }
}

// MARK: -

struct PostsByYear {
    private(set) var byYear: [Int: YearPosts]

    init(posts: [Post]) {
        byYear = [:]
        posts.forEach { add(post: $0) }
    }

    subscript(year: Int) -> YearPosts {
        get {
            byYear[year, default: YearPosts(year: year, byMonth: [:])]
        }
        set {
            byYear[year] = newValue
        }
    }

    var isEmpty: Bool {
        byYear.isEmpty || byYear.values.allSatisfy { $0.isEmpty }
    }

    mutating func add(post: Post) {
        let (year, month) = (post.date.year, Month(post.date.month))
        self[year][month].posts.append(post)
    }

    /// Returns an array of all posts.
    func flattened() -> [Post] {
        byYear.values.flatMap { $0.byMonth.values.flatMap { $0.posts } }
    }
}
