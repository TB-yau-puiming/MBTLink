//
// LocationCodable.swift
// 位置情報Codable
//
// MBTLink
//

import Foundation

struct LocationCodable : Codable {
    /// デバイス種別(0)
    var DEVICE_TYPE : Int
    /// 送信データ種別(1)
    var DATA_TYPE : Int
    /// イニシャライザ
    init(){
        /// デバイス種別
        DEVICE_TYPE = DataCommunicationService.DeviceType.NoData.rawValue
        /// 送信データ種別
        DATA_TYPE = 1
    }
}
