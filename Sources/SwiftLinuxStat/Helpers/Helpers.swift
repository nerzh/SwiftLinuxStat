//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 27.06.2020.
//

import Foundation



public extension SwiftLinuxStat {

    typealias Bytes = Float
    typealias BytesFloat = Float
    typealias KBytes = Float
    typealias Seconds = Float
    typealias BytesPerSecond = Float
    typealias Percent = Float
    typealias DiskLoad = (read: BytesFloat , write: BytesFloat)
    typealias DiskSpace = (name: String, size: KBytes, used: KBytes, avail: KBytes, use: Percent, mounted: String)
    typealias DiskIOs = (readIOs: Float, writeIOs: Float)
    typealias NetLoad = (receive: BytesFloat, transmit: BytesFloat)
    typealias MemLoad = MemData
    typealias DiskData = (
        majorNumber: Float,
        minorNumber: Float,
        deviceName: String,
        readIO: Float,
        readMerges: Float,
        readSectors: Float,
        readTicks: Float,
        writeIO: Float,
        writeMerges: Float,
        writeSectors: Float,
        writeTicks: Float,
        inFlight: Float,
        ioTicks: Float,
        timeInQueue: Float
    )

    typealias CPUData = (
        name: String,
        user: Float,
        nice: Float,
        system: Float,
        idle: Float,
        iowait: Float,
        irq: Float,
        softirq: Float,
        steal: Float
    )

    typealias NetData = (
        interface: String,
        bytesRx: Bytes,
        packetsRx: Float,
        errsRx: Float,
        dropRx: Float,
        fifoRx: Float,
        frameRx: Float,
        compressedRx: Float,
        multicastRx: Float,
        bytesTx: Bytes,
        packetsTx: Float,
        errsTx: Float,
        dropTx: Float,
        fifoTx: Float,
        frameTx: Float,
        compressedTx: Float,
        multicastTx: Float
    )

    typealias MemData = (
        memTotal: KBytes,
        memFree: KBytes,
        memAvailable: KBytes,
        buffers: KBytes,
        swapTotal: KBytes,
        swapFree: KBytes
    )

    static var diskSectorSize: Bytes { 512 }
    static var usleepSecond: UInt32 { 1_000_000 }
}
