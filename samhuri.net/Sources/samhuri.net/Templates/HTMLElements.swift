//
//  HTMLElements.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-18.
//

import Foundation
import Plot

extension Node where Context == HTML.HeadContext {
    static func jsonFeedLink(_ url: URLRepresentable, title: String) -> Node<HTML.HeadContext> {
        .link(.rel(.alternate), .href(url), .type("application/json"), .attribute(named: "title", value: title))
    }
}

extension Node where Context == HTML.HeadContext {
    static func appleTouchIcon(_ url: URLRepresentable) -> Node<HTML.HeadContext> {
        .link(.attribute(named: "rel", value: "apple-touch-icon"), .href(url))
    }

    static func safariPinnedTabIcon(_ url: URLRepresentable, color: String) -> Node<HTML.HeadContext> {
        .link(.attribute(named: "rel", value: "mask-icon"), .attribute(named: "color", value: color), .href(url))
    }
}

extension Node where Context == HTML.BodyContext {
    static func asyncStylesheetLinks(_ urls: [URLRepresentable]) -> Node<HTML.BodyContext> {
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
