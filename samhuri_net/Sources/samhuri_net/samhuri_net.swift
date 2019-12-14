import Foundation
import SiteGenerator

public struct samhuri_net {
    public init() {}

    public func generate(sourceURL: URL, targetURL: URL, siteURLOverride: URL? = nil) throws {
        let generator = try SiteGenerator(
            sourceURL: sourceURL,
            siteURLOverride: siteURLOverride,
            renderers: [MarkdownRenderer()]
        )
        try generator.generate(targetURL: targetURL)
    }
}
