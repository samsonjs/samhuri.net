//
//  TemplateContext.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

protocol TemplateContext {
    var template: String { get }

    var dictionary: [String : Any] { get }
}
