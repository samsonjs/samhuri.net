//
//  Posts.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct MonthPosts {
    let month: Month
    var posts: [Post]
    let path: String

    var title: String {
        month.padded
    }

    var isEmpty: Bool {
        posts.isEmpty
    }

    var year: Int {
        posts[0].date.year
    }
}

// MARK: -

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
}

// MARK: -

struct PostsByYear {
    private(set) var byYear: [Int: YearPosts]
    let path: String

    init(posts: [Post], path: String) {
        byYear = [:]
        self.path = path
        posts.forEach { add(post: $0) }
    }

    var isEmpty: Bool {
        byYear.isEmpty || byYear.values.allSatisfy { $0.isEmpty }
    }

    var years: [Int] {
        Array(byYear.keys)
    }

    subscript(year: Int) -> YearPosts {
        get {
            byYear[year, default: YearPosts(year: year, byMonth: [:], path: "\(path)/\(year)")]
        }
        set {
            byYear[year] = newValue
        }
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
