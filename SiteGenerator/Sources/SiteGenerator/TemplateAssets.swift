//
//  TemplateAssets.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-20.
//

import Foundation

public struct TemplateAssets {
    public let scripts: [String]
    public let styles: [String]

    public init(scripts: [String], styles: [String]) {
        self.scripts = scripts
        self.styles = styles
    }

    public static func none() -> TemplateAssets {
        TemplateAssets(scripts: [], styles: [])
    }
}
