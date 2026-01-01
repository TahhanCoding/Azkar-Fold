//
//  UpdateStatus.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import Foundation

enum UpdateStatus: Equatable {
    case upToDate
    case forceUpdate(requiredVersion: String, currentVersion: String)
    case optionalUpdate(availableVersion: String, currentVersion: String)
}

