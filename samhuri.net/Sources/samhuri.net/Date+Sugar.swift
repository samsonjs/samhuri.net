//
//  Date+Sugar.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-19.
//

import Foundation

extension Date {
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }
}
