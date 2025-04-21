//
//  PermissionsTests.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

@testable import samhuri_net
import Testing

struct PermissionsTests {
    @Test func optionsAreMutuallyExclusive() {
        // If any of the bits overlap then the `or` value will be less than the sum of the raw values.
        let allValues = [Permissions.execute, Permissions.write, Permissions.read].map { $0.rawValue }
        #expect(allValues.reduce(0, +) == allValues.reduce(0, |))
    }

    @Test func rawValuesAreUnixy() {
        #expect(Permissions.none.rawValue == 0o0)
        #expect(Permissions.read.rawValue == 0o4)
        #expect(Permissions.write.rawValue == 0o2)
        #expect(Permissions.execute.rawValue == 0o1)
    }

    @Test func initFromString() {
        #expect(Permissions(string: "---") == [.none])
        #expect(Permissions(string: "--x") == [.execute])
        #expect(Permissions(string: "-w-") == [.write])
        #expect(Permissions(string: "r--") == [.read])

        #expect(Permissions(string: "rw-") == [.read, .write])
        #expect(Permissions(string: "r-x") == [.read, .execute])
        #expect(Permissions(string: "-wx") == [.write, .execute])
        #expect(Permissions(string: "rwx") == [.read, .write, .execute])

        // Refuses to initialize with nonsense.
        #expect(Permissions(string: "abc") == nil)
        #expect(Permissions(string: "awx") == nil)
        #expect(Permissions(string: "rax") == nil)
        #expect(Permissions(string: "rwa") == nil)
    }

    @Test func description() {
        #expect(Permissions.none.description == "---")
        #expect(Permissions.read.description == "r--")
        #expect(Permissions.write.description == "-w-")
        #expect(Permissions.execute.description == "--x")
        #expect(Permissions(arrayLiteral: [.read, .write]).description == "rw-")
        #expect(Permissions(arrayLiteral: [.read, .execute]).description == "r-x")
        #expect(Permissions(arrayLiteral: [.write, .execute]).description == "-wx")
        #expect(Permissions(arrayLiteral: [.read, .write, .execute]).description == "rwx")
    }

    @Test func expressibleByStringLiteral() {
        #expect(Permissions.read == "r--")
    }
}
