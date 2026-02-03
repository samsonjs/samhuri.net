//
//  ProjectsTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func projects(_ projects: [Project]) -> Self {
        .group([
            .article(.class("container"),
                .h1("Projects"),

                .group(projects.map { project in
                    .div(.class("project-listing"),
                        .h4(.a(.href(project.url), .text(project.title))),
                        .p(.class("description"), .text(project.description))
                    )
                })
            ),

            .div(.class("row clearfix"),
                .p(.class("fin"), Icons.code())
            )
        ])
    }
}
