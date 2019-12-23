//
//  HTMLElements.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-18.
//

import Foundation
import Plot

extension Node where Context == HTML.HeadContext {
    static func jsonFeedLink(_ url: URLRepresentable, title: String) -> Self {
        .link(.rel(.alternate), .href(url), .type("application/json"), .attribute(named: "title", value: title))
    }
}

extension Node where Context == HTML.HeadContext {
    static func appleTouchIcon(_ url: URLRepresentable) -> Self {
        .link(.attribute(named: "rel", value: "apple-touch-icon"), .href(url))
    }

    static func safariPinnedTabIcon(_ url: URLRepresentable, color: String) -> Self {
        .link(.attribute(named: "rel", value: "mask-icon"), .attribute(named: "color", value: color), .href(url))
    }
}

extension Node where Context == HTML.BodyContext {
    static func asyncStylesheetLinks(_ urls: [URLRepresentable]) -> Self {
        .script("""
            (function() {
              var urls = [\(urls.map { "'\($0)'" }.joined(separator: ", "))];
              urls.forEach(function(url) {
                  var css = document.createElement('link');
                  css.href = url;
                  css.rel = 'stylesheet';
                  css.type = 'text/css';
                  document.getElementsByTagName('head')[0].appendChild(css);
              });
            })();
        """)
    }
}

extension Node where Context == HTML.BodyContext {
    static func time(_ nodes: Node<HTML.BodyContext>...) -> Self {
        .element(named: "time", nodes: nodes)
    }
}
