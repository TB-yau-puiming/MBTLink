//
// LogCodable.swift
// ログ送信Codable
//
// MBTLink
//

import Foundation

struct LogCodable :Codable {
    /// IoTゲートウェイ番号
    var GWN : String
    /// ゲートウェイタイプ　("iOSGW" または "AndroidGW")
    var GATEWAY_TYPE : String
    ///個人認証ID
    var PERSONAL_ID : String
    ///モジュールバージョン
    var MODULE_VERSION : String
    ///デバイス種別
    var DEVICE_TYPE : Int
    ///デバイスID
    var DEVICE_ID : String
    ///デバイスアドレス
    var DEVICE_ADR : String
    ///ログ種別
    var LOG_TYPE : Int
    ///エラーコード
    var LOG_CODE : Int
    ///ログメッセージ または エラーメッセージ
    var LOG_MSG : String

    /// イニシャライザ
    init(){
        /// IoTゲートウェイ番号
        GWN = ""
        /// ゲートウェイタイプ　("iOSGW" または "AndroidGW")
        GATEWAY_TYPE = "iOSGW"
        ///個人認証ID
        PERSONAL_ID = ""
        ///モジュールバージョン
        MODULE_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        ///デバイス種別
        DEVICE_TYPE = 0
        ///デバイスID
        DEVICE_ID = ""
        ///デバイスアドレス
        DEVICE_ADR = ""
        ///ログ種別
        LOG_TYPE = 0
        ///エラーコード
        LOG_CODE = 0
        ///ログメッセージ または エラーメッセージ
        LOG_MSG = ""
    }
    
    mutating func setUserSetting(){
        let key = "key" + "_" + "userSettingData"
        let userSettings = UserDefaults.standard.getUserSetting(key)
        GWN = userSettings?.serialNumber ?? ""
        PERSONAL_ID = userSettings?.personalID ?? ""
        //システムログ作成、送信
        //アプリクラッシュ
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "CommonCodable" , functionName: #function , message: "")
    }
}
