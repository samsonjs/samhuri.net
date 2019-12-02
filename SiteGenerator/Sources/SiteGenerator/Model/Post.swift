//
//  Post.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Post {
    let date: Date
    let formattedDate: String
    let title: String
    let slug: String
    let author: String
    let tags: [String]
    let body: String

    var path: String {
        let dateComponents = Calendar.current.dateComponents([.year], from: date)
        let year = dateComponents.year!
        let month = dateComponents.month!
        return "/" + [
            "posts",
            "\(year)",
            "\(month)",
            "\(slug)",
        ].joined(separator: "/")
    }
}
