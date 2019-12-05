//
//  RenderedPost.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct RenderedPost {
    let path: String
    let post: Post
    let body: String

    var dictionary: [String: Any] {
        [
            "author": post.author,
            "title": post.title,
            "date": post.date,
            "day": post.date.day,
            "formattedDate": post.formattedDate,
            "link": post.link as Any,
            "path": path,
            "body": body,
        ]
    }
}
