//
//  TemplateContext.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-18.
//

import Foundation
import SiteGenerator

protocol TemplateContext {
    // Concrete requirements, must be implemented

    var site: Site { get }
    var title: String { get }
    var styles: [URL] { get }
    var scripts: [URL] { get }

    // These all have default implementations

    var currentYear: Int { get }

    func url(for path: String) -> URL
    func imageURL(_ filename: String) -> URL
}

extension TemplateContext {
    var currentYear: Int {
        Date().year
    }

    func url(for path: String) -> URL {
        site.url.appendingPathComponent(path)
    }

    func imageURL(_ filename: String) -> URL {
        site.url
            .appendingPathComponent("images")
            .appendingPathComponent(filename)
    }
}
