//
//  FunctionComposition.swift
//  SiteGenerator
//
//  Created by Sami Samhuri on 2019-11-18.
//

import Foundation

infix operator |> :AdditionPrecedence

// MARK: Synchronous

public func |> <A, B, C> (
    f: @escaping (A) -> B,
    g: @escaping (B) -> C
) -> (A) -> C {
    return { a in
        let b = f(a)
        let c = g(b)
        return c
    }
}

public func |> <A, B, C> (
    f: @escaping (A) throws -> B,
    g: @escaping (B) throws -> C
) -> (A) throws -> C {
    return { a in
        let b = try f(a)
        let c = try g(b)
        return c
    }
}
