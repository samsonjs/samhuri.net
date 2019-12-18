//
//  Page.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct Page {
    let title: String
    let styles: [String]
    let scripts: [String]
}

extension Page {
    init(metadata: [String: String]) {
        let styles = metadata["Styles", default: ""]
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        let scripts = metadata["Scripts", default: ""]
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        let title = metadata["Title", default: ""]
        self.init(title: title, styles: styles, scripts: scripts)
    }
}
