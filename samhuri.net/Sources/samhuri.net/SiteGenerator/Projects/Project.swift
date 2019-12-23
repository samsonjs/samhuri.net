//
//  Project.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

struct Project {
    let title: String
    let description: String
    let url: URL

    init(title: String, description: String, url: URL) {
        self.title = title
        self.description = description
        self.url = url
    }
}
