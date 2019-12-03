//
//  Date+CurrentYear.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

extension Date {
    static var currentYear: Int {
        Calendar.current.dateComponents([.year], from: Date()).year!
    }
}
