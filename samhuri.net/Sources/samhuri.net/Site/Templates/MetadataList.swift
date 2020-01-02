//
//  MetadataList.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    func commaSeparatedList(key: String) -> [String] {
        self[key, default: ""]
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
