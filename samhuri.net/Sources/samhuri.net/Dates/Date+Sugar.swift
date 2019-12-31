//
//  Date+Sugar.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation

extension Date {
    static var defaultCalendar = Calendar.current

    var year: Int {
        Date.defaultCalendar.dateComponents([.year], from: self).year!
    }

    var month: Int {
        Date.defaultCalendar.dateComponents([.month], from: self).month!
    }

    var day: Int {
        Date.defaultCalendar.dateComponents([.day], from: self).day!
    }
}
