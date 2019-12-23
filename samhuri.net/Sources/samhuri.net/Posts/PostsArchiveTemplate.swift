//
//  ArchiveTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-21.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func archive(_ postsByYear: PostsByYear) -> Self {
        .group([
            .div(.class("container"),
                 .h1("Archive")
            ),
            .group(postsByYear.years.sorted(by: >).map { year in
                .yearPosts(postsByYear[year])
            }),
        ])
    }
}
