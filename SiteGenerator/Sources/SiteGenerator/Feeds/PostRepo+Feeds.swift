//
//  PostRepo+Feeds.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-10.
//

import Foundation

extension PostRepo {
    var feedPostsCount: Int { 30 }

    var postsForFeed: [Post] {
        Array(sortedPosts.prefix(feedPostsCount))
    }
}
