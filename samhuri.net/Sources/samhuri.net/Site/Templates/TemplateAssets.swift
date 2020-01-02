//
//  TemplateAssets.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-20.
//

import Foundation

struct TemplateAssets {
    var scripts: [String]
    var styles: [String]

    static func empty() -> TemplateAssets {
        TemplateAssets(scripts: [], styles: [])
    }
}
