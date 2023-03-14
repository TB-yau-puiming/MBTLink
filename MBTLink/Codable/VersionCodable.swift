//
// VersionCodable.swift
// バージョン通知Codable
//
// MBTLink
//

import Foundation

struct VersionCodable :Codable {
    /// IoTゲートウェイ番号
    var GWN : String
    /// ゲートウェイタイプ　("iOSGW" または "AndroidGW")
    var GATEWAY_TYPE : String
    ///個人認証ID
    var PERSONAL_ID : String
    ///モジュールバージョン
    var MODULE_VERSION : String

    /// イニシャライザ
    init(){
        /// IoTゲートウェイ番号
        GWN = ""
        /// ゲートウェイタイプ　("iOSGW" または "AndroidGW")
        GATEWAY_TYPE = ""
        ///個人認証ID
        PERSONAL_ID = ""
        ///モジュールバージョン
        MODULE_VERSION = ""
    }
}
