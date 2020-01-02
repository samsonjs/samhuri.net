//
//  PostsAssets.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

import Foundation

extension Collection where Element == Post {
    var templateAssets: TemplateAssets {
        reduce(into: TemplateAssets.empty()) { assets, post in
            assets.scripts.append(contentsOf: post.scripts)
            assets.styles.append(contentsOf: post.styles)
        }
    }
}
