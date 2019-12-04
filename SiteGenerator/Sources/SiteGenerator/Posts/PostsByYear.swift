//
//  Posts.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct MonthPosts {
    let month: Int
    var posts: [Post]

    var isEmpty: Bool {
        posts.isEmpty
    }
}

struct YearPosts {
    let year: Int
    var byMonth: [Int: MonthPosts]

    subscript(month: Int) -> MonthPosts {
        get {
            byMonth[month, default: MonthPosts(month: month, posts: [])]
        }
        set {
            byMonth[month] = newValue
        }
    }

    var isEmpty: Bool {
        byMonth.isEmpty || byMonth.values.allSatisfy { $0.isEmpty }
    }
}

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
        let (year, month) = (post.date.year, post.date.month)
        self[year][month].posts.append(post)
    }

    /// Returns posts sorted by reverse date.
    func flattened() -> [Post] {
        byYear.values.flatMap { $0.byMonth.values.flatMap { $0.posts } }.sorted { $1.date < $0.date }
    }
}
