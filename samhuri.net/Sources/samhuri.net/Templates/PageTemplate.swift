//
//  PartialTemplates.swift
//  
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation
import Plot

extension Node where Context == HTML.BodyContext {
    static func page(title: String, bodyHTML: String) -> Node<HTML.BodyContext> {
        .group([
            .article(.class("container"),
                .h1(.text(title)),
                .raw(bodyHTML)
            ),
            .div(.class("row clearfix"),
                .p(.class("fin"), .i(.class("fa fa-code")))
            )
        ])
    }
}
