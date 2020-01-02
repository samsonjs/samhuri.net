//
//  MonthPosts.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2020-01-01.
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
