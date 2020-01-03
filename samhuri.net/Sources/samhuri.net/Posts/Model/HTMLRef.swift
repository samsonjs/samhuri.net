//
//  HTMLRef.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2020-01-02.
//

import Foundation

protocol HTMLRef: ExpressibleByStringLiteral {
    // Concrete requirements, must be implemented

    var ref: String { get }

    // These all have default implementations

    init(ref: String)

    func url(dir: URL) -> URL
}

extension HTMLRef {
    init(stringLiteral value: String) {
        self.init(ref: value)
    }

    func url(dir: URL) -> URL {
        // ref is either an absolute HTTP URL or path relative to the given directory.
        isHTTPURL ? URL(string: ref)! : dir.appendingPathComponent(ref)
    }
}

private extension HTMLRef {
    var isHTTPURL: Bool {
        ref.hasPrefix("http:") || ref.hasPrefix("https:")
    }
}
