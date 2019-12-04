//
//  RenderedPost.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct RenderedPost {
    let post: Post
    let body: String

    var author: String { post.author }

    var title: String { post.title }

    var date: Date { post.date }

    var formattedDate: String { post.formattedDate }

    var isLink: Bool { post.isLink }

    var link: URL? { post.link }

    var path: String { post.path }
}
