//
//  Renderer.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

protocol Renderer {
    func canRenderFile(named filename: String, withExtension ext: String?) -> Bool

    func render(site: Site, fileURL: URL, targetDir: URL) throws
}
