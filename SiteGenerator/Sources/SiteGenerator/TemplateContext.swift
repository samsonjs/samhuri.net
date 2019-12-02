//
//  TemplateContext.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-01.
//

import Foundation

enum PageType {
    case page(DefaultPage)

    case index(Index)
    case archive(Archive)
//    case monthPosts(MonthPosts)
//    case yearPosts(YearPosts)
    case post(Post)

    case projects(Projects)
    case project(Project)
}

struct TemplateContext {
    let site: Site
    let pageType: PageType

    var page: Page {
        switch pageType {
        case let .index(page as Page),
             let .archive(page as Page),
             let .projects(page as Page),
             let .project(page as Page),
             let .post(page as Page),
             let .page(page as Page):
            return page
        }
    }

    var title: String {
        if case .index = pageType {
            return site.title
        }
        return "\(site.title): \(page.title)"
    }

    var template: String {
        page.template ?? site.template
    }
}

// MARK: - Dictionary form

extension PageType {
    var dictionary: [String: Any] {
        switch self {
        case let .index(index):
            return ["index": index]

        case let .archive(archive):
            return ["archive": archive]

        case let .projects(projects):
            return ["projects": projects]

        case let .project(project):
            return ["project": project]

        case let .post(post):
            return ["post": post]

        case .page:
            return [:]
        }
    }
}

extension TemplateContext {
    var dictionary: [String: Any] {
        [
            "site": site,
            "page": page,
            "title": title,
            "styles": site.styles + page.styles,
            "scripts": site.scripts + page.scripts,
        ].merging(pageType.dictionary, uniquingKeysWith: { current, _ in current })
    }
}
