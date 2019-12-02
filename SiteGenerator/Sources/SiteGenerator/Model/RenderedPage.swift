//
//  RenderedPage.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

struct RenderedPage<SomePage: Page> {
    let page: SomePage
    let body: String
}
