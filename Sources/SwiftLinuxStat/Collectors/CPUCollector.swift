//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 27.06.2020.
//

import Foundation
import FileUtils

public extension SwiftLinuxStat {

    class CPU {

        public var scanTime: Seconds = 1
        public var cpuDataFirst: CPUData = ("", 0, 0, 0, 0, 0, 0, 0, 0)
        public var cpuDataLast: CPUData = ("", 0, 0, 0, 0, 0, 0, 0, 0)
        public var diffCPUData: CPUData {
            var result: CPUData
            result.name = cpuDataLast.name
            result.user = cpuDataFirst.user - cpuDataLast.user
            result.nice = cpuDataFirst.nice - cpuDataLast.nice
            result.system = cpuDataFirst.system - cpuDataLast.system
            result.idle = cpuDataFirst.idle - cpuDataLast.idle
            result.iowait = cpuDataFirst.iowait - cpuDataLast.iowait
            result.irq = cpuDataFirst.irq - cpuDataLast.irq
            result.softirq = cpuDataFirst.softirq - cpuDataLast.softirq
            result.steal = cpuDataFirst.steal - cpuDataLast.steal

            return result
        }

        public init() {}

        public func cpuLoad(name: String = "cpu", current: Bool = true, scanTime: Seconds = 1) -> Percent {
            var result: Percent = 0
            if current { update(name: name, scanTime: scanTime) }
            let tTotal: Int = diffCPUData.user + diffCPUData.nice + diffCPUData.system + diffCPUData.idle + diffCPUData.iowait + diffCPUData.irq + diffCPUData.softirq + diffCPUData.steal
            let tIdle: Int = diffCPUData.idle + diffCPUData.iowait
            let tUsage: Int = tTotal - tIdle
            result = (Float(tUsage)/Float(tTotal)) * 100

            return result
        }

        @discardableResult
        public func update(name: String, scanTime: Seconds = 1) -> Self {
            self.scanTime = scanTime
            cpuDataFirst = currentCPUData(name: name)
            usleep(UInt32(Seconds(usleepSecond) * scanTime))
            cpuDataLast = currentCPUData(name: name)

            return self
        }

        private func currentCPUData(name: String) -> CPUData {
            let statPath: String = "/proc/stat"
            var result: CPUData = ("", 0, 0, 0, 0, 0, 0, 0, 0)
            try? FileUtils.readFileByLine(statPath) { (line) -> Bool in
                let cpuData = getCPUData(line)
                if cpuData.name == name {
                    result = cpuData
                    return false
                }
                return true
            }

            return result
        }

        ///    user: time spent on processes executing in user mode with normal priority
        ///    nice: time spent on processes executing in user mode with “niced” priority
        ///    system: time spent on processes executing in kernel mode
        ///    idle: time spent idling (i.e. with no CPU instructions) while there were no disk I/O requests outstanding.
        ///    iowait: time spent idling while there were outstanding disk I/O requests.
        ///    irq: time spent servicing interrupt requests
        ///    softirq: time spent servicing softirq
        ///    steal: time “stolen” from your processor to run other operating systems in a virtualized environment
        ///    guest: time spent on processes running on a virtual CPU with normal priority
        ///    guest_nice: time spent on processes running on a virtual CPU with niced priority
        public func getCPUData(_ line: String) -> CPUData {
            var result: CPUData = ("", 0, 0, 0, 0, 0, 0, 0, 0)
            let pattern: String = #"^\s*(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+).*"#
            let matches: [Int: String] = line.regexp(pattern)
            if matches[0] != nil {
                result.name = matches[1]!
                result.user = Int(matches[2]!)!
                result.nice = Int(matches[3]!)!
                result.system = Int(matches[4]!)!
                result.idle = Int(matches[5]!)!
                result.iowait = Int(matches[6]!)!
                result.irq = Int(matches[7]!)!
                result.softirq = Int(matches[8]!)!
                result.steal = Int(matches[9]!)!
            }

            return result
        }
    }
}
