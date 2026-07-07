//
//  AzkarDebugLog.swift
//  HRSD
//
//  Created by Ahmed AlTahhan on 29/05/2026.
//  Copyright © 2026 Future Workshops. All rights reserved.
//

import Foundation

enum AzkarDebugLog {
    static func log(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("hello azkar: [\(fileName):\(line)] \(message)")
        #endif
    }
}
