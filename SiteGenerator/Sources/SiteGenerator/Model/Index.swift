//
//  Index.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Index: Page {
    // Page properties
    let template: String?
    let styles: [String]
    let scripts: [String]

    var title: String {
        assertionFailure("Don't use this. Use Site.title instead.")
        return "easter egg"
    }

    // Other properties
    let recentPosts: [Post]
}
