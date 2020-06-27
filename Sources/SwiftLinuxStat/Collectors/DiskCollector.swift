//
//  SwiftLinuxStat.swift
//  
//
//  Created by Oleh Hudeichuk on 27.06.2020.
//

import Foundation
import FileUtils

//#if os(Linux)
public extension SwiftLinuxStat {

    class Disk {

        var scanTime: Seconds = 1
        var diskDataFirst: DiskData = (0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        var diskDataLast: DiskData = (0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        var diffDiskData: DiskData {
            var result: DiskData
            result.majorNumber = diskDataFirst.majorNumber
            result.minorNumber = diskDataFirst.minorNumber
            result.deviceName = diskDataFirst.deviceName
            result.readIO = diskDataFirst.readIO - diskDataLast.readIO
            result.readMerges = diskDataFirst.readMerges - diskDataLast.readMerges
            result.readSectors = diskDataFirst.readSectors - diskDataLast.readSectors
            result.readTicks = diskDataFirst.readTicks - diskDataLast.readTicks
            result.writeIO = diskDataFirst.writeIO - diskDataLast.writeIO
            result.writeMerges = diskDataFirst.writeMerges - diskDataLast.writeMerges
            result.writeSectors = diskDataFirst.writeSectors - diskDataLast.writeSectors
            result.writeTicks = diskDataFirst.writeTicks - diskDataLast.writeTicks
            result.inFlight = diskDataFirst.inFlight - diskDataLast.inFlight
            result.ioTicks = diskDataFirst.ioTicks - diskDataLast.ioTicks
            result.timeInQueue = diskDataFirst.timeInQueue - diskDataLast.timeInQueue

            return result
        }

        public init() {}

        /// 9       2 md2 1662164 0 32184250 0 247353783 0 7830748704 0 0 0 0
        func diskLoad(name: String? = nil, current: Bool = true, scanTime: Seconds = 1) -> DiskLoad {
            var result: DiskLoad
            if current { update(name: name, scanTime: scanTime) }
            result.read = diffDiskData.readSectors * SwiftLinuxStat.diskSectorSize
            result.write = diffDiskData.writeSectors * SwiftLinuxStat.diskSectorSize

            return result
        }

        func diskLoadPerSecond(name: String? = nil, current: Bool = true, scanTime: Seconds = 1) -> DiskLoad {
            var result: DiskLoad = diskLoad(name: name, current: current, scanTime: scanTime)
            result.read = result.read / self.scanTime
            result.write = result.write / self.scanTime

            return result
        }

        func diskIOs(name: String? = nil, current: Bool = true, scanTime: Seconds = 1) -> DiskIOs {
            var result: DiskIOs
            if current { update(name: name, scanTime: scanTime) }
            result.readIOs = Float(diffDiskData.readIO) / Float(self.scanTime)
            result.writeIOs = Float(diffDiskData.writeIO) / Float(self.scanTime)

            return result
        }

        func diskBusy(name: String? = nil, current: Bool = true, scanTime: Seconds = 1) -> Percent {
            if current { update(name: name, scanTime: scanTime) }
            return 100 * Float(diffDiskData.ioTicks) / (1000 * Float(self.scanTime))
        }

        @discardableResult
        func update(name: String? = nil, scanTime: Seconds = 1) -> Self {
            self.scanTime = scanTime
            diskDataFirst = currentDiskData(name: name)
            usleep(UInt32(Seconds(usleepSecond) * scanTime))
            diskDataLast = currentDiskData(name: name)

            return self
        }

        private func currentDiskData(name: String?) -> DiskData {
            let statPath: String = "/proc/diskstats"
            var result: DiskData = (0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            if let name = name {
                try? FileUtils.readFileByLine(statPath) { (line) -> Bool in
                    let diskData = getDiskData(line)
                    if diskData.deviceName == name {
                        result = diskData
                        return false
                    }
                    return true
                }
            } else {
                try? FileUtils.readFileByLine(statPath) { (line) -> Void in
                    let diskData = getDiskData(line)
                    result.majorNumber += diskData.majorNumber
                    result.minorNumber += diskData.minorNumber
                    result.deviceName = "Total"
                    result.readIO += diskData.readIO
                    result.readMerges += diskData.readMerges
                    result.readSectors += diskData.readSectors
                    result.readTicks += diskData.readTicks
                    result.writeIO += diskData.writeIO
                    result.writeMerges += diskData.writeMerges
                    result.writeSectors += diskData.writeSectors
                    result.writeTicks += diskData.writeTicks
                    result.inFlight += diskData.inFlight
                    result.ioTicks += diskData.ioTicks
                    result.timeInQueue += diskData.timeInQueue
                }
            }

            return result
        }

        ///    major number
        ///    minor mumber
        ///    device name
        ///    read I/Os       requests      number of read I/Os processed
        ///    read merges     requests      number of read I/Os merged with in-queue I/O
        ///    read sectors    sectors       number of sectors read
        ///    read ticks      milliseconds  total wait time for read requests
        ///    write I/Os      requests      number of write I/Os processed
        ///    write merges    requests      number of write I/Os merged with in-queue I/O
        ///    write sectors   sectors       number of sectors written
        ///    write ticks     milliseconds  total wait time for write requests
        ///    in_flight       requests      number of I/Os currently in flight
        ///    io_ticks        milliseconds  total time this block device has been active
        ///    time_in_queue   milliseconds  total wait time for all requests
        func getDiskData(_ line: String) -> DiskData {
            var result: DiskData = (0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            let pattern: String = #"^\s*(\d+)\s+(\d+)\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$"#
            let matches: [Int: String] = line.regexp(pattern)
            if matches[0] != nil {
                result.majorNumber = Int(matches[1]!)!
                result.minorNumber = Int(matches[2]!)!
                result.deviceName = matches[3]!
                result.readIO = Int(matches[4]!)!
                result.readMerges = Int(matches[5]!)!
                result.readSectors = Int(matches[6]!)!
                result.readTicks = Int(matches[7]!)!
                result.writeIO = Int(matches[8]!)!
                result.writeMerges = Int(matches[9]!)!
                result.writeSectors = Int(matches[10]!)!
                result.writeTicks = Int(matches[11]!)!
                result.inFlight = Int(matches[12]!)!
                result.ioTicks = Int(matches[13]!)!
                result.timeInQueue = Int(matches[14]!)!
            }
            return result
        }
    }
}
//#endif
