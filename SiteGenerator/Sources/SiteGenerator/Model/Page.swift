//
//  Page.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

protocol Page {
    var title: String { get }
    var template: String? { get }
    var styles: [String] { get }
    var scripts: [String] { get }
}
