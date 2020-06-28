# swift-linux-stat


[![Swift Linux Statistic Metrics](https://img.shields.io/badge/Swift-Linux-orange)](https://swift.org/server/)

Swift library for collecting linux metrics 

Linux exposes detailed sub-system and device level statistics through procfs. These statistics are useful for system debugging as well as performance tuning. These statistics are often consumed through one-off analysis scripts or a number of command-line tools, such as, vmstat, iostat, netstat, sar, atop, collectl, numastat, and so on. There is a need to capture these statistics 24x7 in a cloud environment to support system health monitoring and alerting, live site incident triage and investigations, performance debugging, and capacity monitoring and planning with instruments like a Prometheus, Zabbix etc.


- Disk
- CPU
- Net
- RAM


## USAGE


```swift
import Foundation
import SwiftLinuxStat

class Test {

    func test() {
        let collectorGroup = DispatchGroup()
        
        let disk = SwiftLinuxStat.Disk()
        let cpu = SwiftLinuxStat.CPU()
        let net = SwiftLinuxStat.Net()
        let mem = SwiftLinuxStat.Mem()
        
        for _ in 0...40 {
            collectorGroup.enter()
            Thread {
              disk.update() // update data for statistic, default 1 second
              collectorGroup.leave()
            }.start()
            
            collectorGroup.enter()
            Thread {
              cpu.update() // update data for statistic, default 1 second
              collectorGroup.leave()
            }.start()

            collectorGroup.enter()
            Thread {
              net.update() // update data for statistic, default 1 second
              collectorGroup.leave()
            }.start()
            
            collectorGroup.wait() // collectors are waiting for each other
            
            print("load", disk.diskLoadPerSecond(current: false)) // bytes
            print("io", disk.diskIOs(current: false)) // requests
            print("busy", disk.diskBusy(current: false)) // percent
            print("cpu", cpu.cpuLoad(current: false)) // percent
            print("net", net.netLoadPerSecond(current: false)) // bytes 
            print("mem", mem.memLoad()) // Kbytes
            print("\n")
        }
    }
}

Test.init().test()

```

## INSTALL

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Project",
    dependencies: [
        .package(name: "SwiftLinuxStat", url: "https://github.com/nerzh/SwiftLinuxStat.git", .upToNextMajor(from: "0.3.1")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "SwiftLinuxStat", package: "SwiftLinuxStat"),
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")])
    ]
)
```
