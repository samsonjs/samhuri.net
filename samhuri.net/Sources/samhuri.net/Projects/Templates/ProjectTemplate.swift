//
//  ProjectTemplate.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func project(_ context: ProjectContext) -> Self {
        .group([
            .article(.class("container project"),
                // projects.js picks up this data-title attribute and uses it to render all the Github stuff
                .h1(.id("project"), .data(named: "title", value: context.title), .text(context.title)),
                .h4(.text(context.description)),

                .div(.class("project-stats"),
                    .p(
                        .a(.href(context.githubURL), "GitHub"),
                        "•",
                        .a(.id("nstar"), .href(context.stargazersURL)),
                        "•",
                        .a(.id("nfork"), .href(context.networkURL))
                    ),
                    .p("Last updated on ", .span(.id("updated")))
                ),

                .div(.class("project-info row clearfix"),
                    .div(.class("column half"),
                         .h3("Contributors"),
                         .div(.id("contributors"))
                    ),
                    .div(.class("column half"),
                        .h3("Languages"),
                        .div(.id("langs"))
                    )
                )
            ),

            .div(.class("row clearfix"),
                .p(.class("fin"), Icons.code())
            ),

            .group(context.scripts.map { url in
                .script(.attribute(named: "defer"), .src(url))
            })
        ])
    }
}
