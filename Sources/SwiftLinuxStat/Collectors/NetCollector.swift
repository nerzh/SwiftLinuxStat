//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.06.2020.
//

import Foundation

import Foundation
import FileUtils

public extension SwiftLinuxStat {

    class Net {

        public var scanTime: Seconds = 1
        public var netDataFirst: NetData = ("", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        public var netDataLast: NetData = ("", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        public var diffNetData: NetData {
            var result: NetData
            result.interface = netDataLast.interface
            result.bytesRx = netDataLast.bytesRx - netDataFirst.bytesRx
            result.packetsRx = netDataLast.packetsRx - netDataFirst.packetsRx
            result.errsRx = netDataLast.errsRx - netDataFirst.errsRx
            result.dropRx = netDataLast.dropRx - netDataFirst.dropRx
            result.fifoRx = netDataLast.fifoRx - netDataFirst.fifoRx
            result.frameRx = netDataLast.frameRx - netDataFirst.frameRx
            result.compressedRx = netDataLast.compressedRx - netDataFirst.compressedRx
            result.multicastRx = netDataLast.multicastRx - netDataFirst.multicastRx
            result.bytesTx = netDataLast.bytesRx - netDataFirst.bytesRx
            result.packetsTx = netDataLast.bytesTx - netDataFirst.bytesTx
            result.errsTx = netDataLast.errsTx - netDataFirst.errsTx
            result.dropTx = netDataLast.dropTx - netDataFirst.dropTx
            result.fifoTx = netDataLast.fifoTx - netDataFirst.fifoTx
            result.frameTx = netDataLast.frameTx - netDataFirst.frameTx
            result.compressedTx = netDataLast.compressedTx - netDataFirst.compressedTx
            result.multicastTx = netDataLast.multicastTx - netDataFirst.multicastTx

            return result
        }

        public init() {}

        public func netLoad(interface: String? = nil, current: Bool = true, scanTime: Seconds = 1) -> NetLoad {
            var result: NetLoad = (0, 0)
            if current { update(interface: interface, scanTime: scanTime) }
            result.receive = diffNetData.bytesRx
            result.transmit = diffNetData.bytesTx

            return result
        }

        @discardableResult
        public func update(interface: String? = nil, scanTime: Seconds = 1) -> Self {
            self.scanTime = scanTime
            netDataFirst = currentNetData(interface: interface)
            usleep(UInt32(Seconds(usleepSecond) * scanTime))
            netDataLast = currentNetData(interface: interface)

            return self
        }

        private func currentNetData(interface name: String?) -> NetData {
            let statPath: String = "/proc/net/dev"
            var result: NetData = ("", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            let interface: String = name != nil ? name! : getDefaultInterface()
            try? FileUtils.readFileByLine(statPath) { (line) -> Bool in
                let netData = getNetData(line)
                if netData.interface.clean() == interface.clean() {
                    result = netData
                    return false
                }
                return true
            }

            return result
        }

        /// Inter-face |   Receive                                                                             |  Transmit
        ///        |  bytes packets errs drop fifo frame compressed multicast  |  bytes packets errs drop fifo colls carrier compressed
        public func getNetData(_ line: String) -> NetData {
            var result: NetData = ("", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            let pattern: String = #"^\s*(\w+):*\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+).*$"#
            let matches: [Int: String] = line.regexp(pattern)
            if matches[0] != nil {
                result.interface = matches[1]!
                result.bytesRx = Int(matches[2]!)!
                result.packetsRx = Int(matches[3]!)!
                result.errsRx = Int(matches[4]!)!
                result.dropRx = Int(matches[5]!)!
                result.fifoRx = Int(matches[6]!)!
                result.frameRx = Int(matches[7]!)!
                result.compressedRx = Int(matches[8]!)!
                result.multicastRx = Int(matches[9]!)!
                result.bytesTx = Int(matches[10]!)!
                result.packetsTx = Int(matches[11]!)!
                result.errsTx = Int(matches[12]!)!
                result.dropTx = Int(matches[13]!)!
                result.fifoTx = Int(matches[14]!)!
                result.frameTx = Int(matches[15]!)!
                result.compressedTx = Int(matches[16]!)!
                result.multicastTx = Int(matches[17]!)!
            }

            return result
        }

        /// Iface    Destination    Gateway     Flags    RefCnt    Use    Metric    Mask        MTU    Window    IRTT
        /// ens3    00000000    01C7932D    0003         0           0          0      00000000      0           0             0
        public func getDefaultInterface() -> String {
            var result: String = .init()
            let routePath: String = "/proc/net/route"
            let pattern: String = #"^\s*(\w+)\s+(\w+)\s+.+"#
            try? FileUtils.readFileByLine(routePath) { (line) -> Bool in
                let matches: [Int: String] = line.regexp(pattern)
                if  let interface = matches[1],
                    let ip = matches[2],
                    Int(ip, radix: 16) == 0
                {
                    result = interface.clean()
                    return false
                }
                return true
            }

            return result
        }
    }
}
