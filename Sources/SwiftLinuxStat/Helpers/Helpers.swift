//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 27.06.2020.
//

import Foundation



public extension SwiftLinuxStat {

    typealias Bytes = Int
    typealias Seconds = Int
    typealias BytesPerSecond = Int
    typealias Percent = Float
    typealias DiskLoad = (read: Bytes , write: Bytes)
    typealias DiskIOs = (readIOs: Float , writeIOs: Float)
    typealias NetLoad = (receive: Bytes , transmit: Bytes)
    typealias DiskData = (
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

    typealias CPUData = (
        name: String,
        user: Int,
        nice: Int,
        system: Int,
        idle: Int,
        iowait: Int,
        irq: Int,
        softirq: Int,
        steal: Int
    )

    typealias NetData = (
        interface: String,
        bytesRx: Int,
        packetsRx: Int,
        errsRx: Int,
        dropRx: Int,
        fifoRx: Int,
        frameRx: Int,
        compressedRx: Int,
        multicastRx: Int,
        bytesTx: Int,
        packetsTx: Int,
        errsTx: Int,
        dropTx: Int,
        fifoTx: Int,
        frameTx: Int,
        compressedTx: Int,
        multicastTx: Int
    )

    static var diskSectorSize: Bytes { 512 }
    static var usleepSecond: UInt32 { 1_000_000 }
}
