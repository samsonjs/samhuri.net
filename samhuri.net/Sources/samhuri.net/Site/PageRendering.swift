//
//  PageRendering.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

protocol PageRendering {
    func renderPage(site: Site, url: URL, bodyHTML: String, metadata: [String: String]) throws -> String
}
