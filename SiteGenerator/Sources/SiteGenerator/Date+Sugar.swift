//
//  Date+Sugar.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-12-02.
//

import Foundation

extension Date {
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }

    var month: Int {
        Calendar.current.dateComponents([.month], from: self).month!
    }

    var day: Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }
}