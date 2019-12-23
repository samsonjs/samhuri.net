//
//  MarkdownPageRenderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

protocol MarkdownPageRenderer {
    func renderPage(site: Site, bodyHTML: String, metadata: [String: String]) throws -> String
}
