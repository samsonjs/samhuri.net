//
//  Post.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Post: Page {
    // Page properties
    let title: String
    let template: String?
    let styles: [String]
    let scripts: [String]

    // Other properties
    let date: Date
    let formattedDate: String
}
