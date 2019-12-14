//
//  Plugin.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

public protocol Plugin {
    func setUp(site: Site, sourceURL: URL) throws

    func render(site: Site, targetURL: URL, templateRenderer: TemplateRenderer) throws
}
