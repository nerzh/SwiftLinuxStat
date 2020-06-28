//
//  MemCollector.swift
//  
//
//  Created by Oleh Hudeichuk on 28.06.2020.
//

import Foundation
import FileUtils

public extension SwiftLinuxStat {

    class Mem {

        public init() {}

        public func memLoad() -> MemLoad {
            currentNetData()
        }

        private func currentNetData() -> MemData {
            let statPath: String = "/proc/meminfo"
            var result: MemData = (0, 0, 0, 0, 0, 0)
            let pattern: String = #"^\s*(\w+):*\s+(\d+).*"#
            try? FileUtils.readFileByLine(statPath) { (line) -> Void in
                let matches: [Int: String] = line.regexp(pattern)
                if matches[0] == nil { return }
                switch matches[1]! {
                case "MemTotal":
                    result.memTotal = KBytes(matches[2]!)!
                case "MemFree":
                    result.memFree = KBytes(matches[2]!)!
                case "MemAvailable":
                    result.memAvailable = KBytes(matches[2]!)!
                case "Buffers":
                    result.buffers = KBytes(matches[2]!)!
                case "SwapTotal":
                    result.swapTotal = KBytes(matches[2]!)!
                case "SwapFree":
                    result.swapFree = KBytes(matches[2]!)!
                default:
                    break
                }
            }

            return result
        }
    }
}

