//
//  TemplateAssets.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-20.
//

import Foundation

struct TemplateAssets {
    let scripts: [String]
    let styles: [String]

    init(scripts: [String], styles: [String]) {
        self.scripts = scripts
        self.styles = styles
    }

    static func none() -> TemplateAssets {
        TemplateAssets(scripts: [], styles: [])
    }
}
