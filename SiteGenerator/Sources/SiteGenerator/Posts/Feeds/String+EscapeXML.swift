//
//  XMLEscape.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-12.
//

import Foundation

extension String {
    func escapedForXML() -> String {
        replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
