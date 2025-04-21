//
//  FilePermissionsTests.swift
//  samhuri.net
//
//  Created by Sami Samhuri on 2019-12-31.
//

@testable import samhuri_net
import Testing

struct FilePermissionsTests {
    @Test func description() {
        #expect(FilePermissions(user: "---", group: "---", other: "---").description == "---------")
        #expect(FilePermissions(user: "r--", group: "r--", other: "r--").description == "r--r--r--")
        #expect(FilePermissions(user: "-w-", group: "-w-", other: "-w-").description == "-w--w--w-")
        #expect(FilePermissions(user: "--x", group: "--x", other: "--x").description == "--x--x--x")
        #expect(FilePermissions(user: "rwx", group: "r-x", other: "r--").description == "rwxr-xr--")
    }

    @Test func initFromString() {
        #expect(FilePermissions(user: "---", group: "---", other: "---") == FilePermissions(string: "---------"))
        #expect(FilePermissions(user: "r--", group: "r--", other: "r--") == FilePermissions(string: "r--r--r--"))
        #expect(FilePermissions(user: "-w-", group: "-w-", other: "-w-") == FilePermissions(string: "-w--w--w-"))
        #expect(FilePermissions(user: "--x", group: "--x", other: "--x") == FilePermissions(string: "--x--x--x"))
        #expect(FilePermissions(user: "rwx", group: "r-x", other: "r--") == FilePermissions(string: "rwxr-xr--"))

        // Refuses to initialize with nonsense.
        #expect(FilePermissions(string: "abcdefghi") == nil)
        #expect(FilePermissions(string: "abcrwxrwx") == nil)
        #expect(FilePermissions(string: "rwxabcrwx") == nil)
        #expect(FilePermissions(string: "rwxrwxabc") == nil)
    }

    @Test func initFromRawValue() {
        #expect(FilePermissions(rawValue: 0o000) == FilePermissions(string: "---------"))
        #expect(FilePermissions(rawValue: 0o755) == FilePermissions(string: "rwxr-xr-x"))
        #expect(FilePermissions(rawValue: 0o644) == FilePermissions(string: "rw-r--r--"))
        #expect(FilePermissions(rawValue: 0o600) == FilePermissions(string: "rw-------"))
        #expect(FilePermissions(rawValue: 0o777) == FilePermissions(string: "rwxrwxrwx"))
    }

    @Test func rawValue() {
        #expect(FilePermissions(string: "---------")!.rawValue == 0o000)
        #expect(FilePermissions(string: "rwxr-xr-x")!.rawValue == 0o755)
        #expect(FilePermissions(string: "rw-r--r--")!.rawValue == 0o644)
        #expect(FilePermissions(string: "rw-------")!.rawValue == 0o600)
        #expect(FilePermissions(string: "rwxrwxrwx")!.rawValue == 0o777)
    }

    @Test func expressibleByStringLiteral() {
        #expect(FilePermissions(user: "rwx", group: "r-x", other: "r-x") == "rwxr-xr-x")
    }
}
