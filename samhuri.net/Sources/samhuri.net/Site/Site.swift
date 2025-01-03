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
    let description: String
    let imageURL: URL?
    let url: URL
    let scripts: [Script]
    let styles: [Stylesheet]
    let renderers: [Renderer]
    let plugins: [Plugin]
}
