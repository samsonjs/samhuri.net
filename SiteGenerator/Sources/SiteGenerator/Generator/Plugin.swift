//
//  Plugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public protocol Plugin {
    init(options: [String: Any])

    func setUp(site: Site, sourceURL: URL) throws

    func render(site: Site, targetURL: URL, templateRenderer: TemplateRenderer) throws
}
