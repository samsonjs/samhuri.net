//
//  Plugin.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

protocol Plugin {
    func setUp(site: Site, sourceURL: URL) throws

    func render(site: Site, targetURL: URL) throws
}
