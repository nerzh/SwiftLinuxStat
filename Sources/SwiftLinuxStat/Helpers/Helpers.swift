//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 27.06.2020.
//

import Foundation



public extension SwiftLinuxStat {

    typealias Bytes = Int
    typealias Seconds = Float
    typealias BytesPerSecond = Int
    typealias DiskLoad = (read: BytesPerSecond , write: BytesPerSecond)

    static var diskSectorSize: Bytes { 512 }
    static var usleepSecond: UInt32 { 1_000_000 }
}
