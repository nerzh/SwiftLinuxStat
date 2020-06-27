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

    /// 9       2 md2 1662164 0 32184250 0 247353783 0 7830748704 0 0 0 0
    class func diskLoad(name: String, delay: Seconds = 1) -> DiskLoad {
        let statPath: String = "/proc/diskstats"
        var result1: DiskLoad = (0, 0)
        var result2: DiskLoad = (0, 0)
        var result: DiskLoad = (0, 0)
        try? FileUtils.readFileByLine(statPath) { (line) in
            let diskData = getDiskData(line)
            if diskData.deviceName == name {
                result1.read = diskData.readSectors
                result1.write = diskData.writeSectors
            }
        }
        usleep(UInt32(Seconds(usleepSecond) * delay))
        try? FileUtils.readFileByLine(statPath) { (line) in
            let diskData = getDiskData(line)
            if diskData.deviceName == name {
                result2.read = diskData.readSectors
                result2.write = diskData.writeSectors
            }
        }
        result.read = (result2.read - result1.read) * diskSectorSize
        result.write = (result2.write - result1.write) * diskSectorSize

        return result
    }

    class func diskLoadTotal(delay: Seconds = 1) -> DiskLoad {
        let statPath: String = "/proc/diskstats"
        var result1: DiskLoad = (0, 0)
        var result2: DiskLoad = (0, 0)
        var result: DiskLoad = (0, 0)
        try? FileUtils.readFileByLine(statPath) { (line) in
            let diskData = getDiskData(line)
            result1.read += diskData.readSectors
            result1.write += diskData.writeSectors
        }
        usleep(UInt32(Seconds(usleepSecond) * delay))
        try? FileUtils.readFileByLine(statPath) { (line) in
            let diskData = getDiskData(line)
            result2.read += diskData.readSectors
            result2.write += diskData.writeSectors
        }
        result.read = (result2.read - result1.read) * diskSectorSize
        result.write = (result2.write - result1.write) * diskSectorSize

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
    private class func getDiskData(_ line: String
    ) -> (
        majorNumber: Int,
        minorNumber: Int,
        deviceName: String,
        readIO: Int,
        readMerges: Int,
        readSectors: Int,
        readTicks: Int,
        writeIO: Int,
        writeMerges: Int,
        writeSectors: Int,
        writeTicks: Int,
        inFlight: Int,
        ioTicks: Int,
        timeInQueue: Int
        )
    {
        var result: (
        majorNumber: Int,
        minorNumber: Int,
        deviceName: String,
        readIO: Int,
        readMerges: Int,
        readSectors: Int,
        readTicks: Int,
        writeIO: Int,
        writeMerges: Int,
        writeSectors: Int,
        writeTicks: Int,
        inFlight: Int,
        ioTicks: Int,
        timeInQueue: Int
        ) = (0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
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
//#endif
