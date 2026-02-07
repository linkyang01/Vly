// MARK: - 服务导入

// MARK: - 服务

@_exported import Foundation
@_exported import SwiftUI
@_exported import AVFoundation
@_exported import Combine

// MARK: - HealthKit (需要条件导入)

#if canImport(HealthKit)
@_exported import HealthKit
#endif

// MARK: - WatchConnectivity (需要条件导入)

#if canImport(WatchConnectivity)
@_exported import WatchConnectivity
#endif
