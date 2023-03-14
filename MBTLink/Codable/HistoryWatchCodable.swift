//
// WatchCodable.swift
// ウォッチCodable
//
// MBTLink
//

import Foundation

struct HistoryWatchCodable :Codable {
    ///デバイスファームウェアバージョン
    var FIRMWARE_VERSION : String
    ///デバイスデータ取得日時(YYYYMMDDhhmmss)
    var GET_DATE : String
    ///デバイスデータ配列
    var DEVICE : [CommonCodable.Data]
    /// データ履歴
    var HISTORY : [CommonCodable.Data]
    /// イニシャライザ
    init(){
        ///デバイスファームウェアバージョン
        FIRMWARE_VERSION = ""
        ///デバイスデータ取得日時(YYYYMMDDhhmmss)
        GET_DATE = ""
        ///デバイスデータ配列
        DEVICE = [CommonCodable.Data]()
        /// データ履歴
        HISTORY = [CommonCodable.Data]()
    }
}
