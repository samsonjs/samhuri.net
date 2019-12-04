//
//  Month.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-03.
//

import Foundation

struct Month {
    static let names = [
        "January", "Februrary", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    ]

    let number: Int

    var padded: String {
        String(format: "%02d", number)
    }

    var name: String {
        Month.names[number]
    }

    var abbreviatedName: String {
        String(name.prefix(3))
    }
}
