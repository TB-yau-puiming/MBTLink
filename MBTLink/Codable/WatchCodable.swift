//
// WatchCodable.swift
// ウォッチCodable
//
// MBTLink
//

import Foundation

struct WatchCodable :Codable {
    ///デバイスファームウェアバージョン
    var FIRMWARE_VERSION : String
    ///デバイスデータ取得日時(YYYYMMDDhhmmss)
    var GET_DATE : String
    ///デバイスデータ配列
    var DEVICE : [CommonCodable.Data]
    
    /// イニシャライザ
    init(){
        ///デバイスファームウェアバージョン
        FIRMWARE_VERSION = ""
        ///デバイスデータ取得日時(YYYYMMDDhhmmss)
        GET_DATE = ""
        ///デバイスデータ配列
        DEVICE = [CommonCodable.Data]()
    }
}
