//
//  Site.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Site {
    let author: String
    let email: String
    let title: String
    let description: String?
    let url: URL
    let styles: [String]
    let scripts: [String]
    let renderers: [Renderer]
    let plugins: [Plugin]
}
