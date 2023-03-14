//
// CommonUtil.swift
// MBTLink
// 共通ユーティリティ関連クラス
//
// MBTLink
//

import Foundation

final class CommonUtil {
    private let className = String(String(describing: CommonUtil.self).split(separator: "-")[0])
    
    // MARK: - Public Methods
    /// print出力(クラス名, メッセージ)
    static func Print(className : String, message : String){
        
        let date = DateUtil.GetDateFormatConvert(format: "yyyy/MM/dd HH:mm:ss")
        
        print("\(date) \(className) \(message)")
    }
    
    /// print出力(クラス名, メソッド名,メッセージ)
    static func Print(logLevel : String, className : String, functionName : String, message : String){
        
        let date = DateUtil.GetDateFormatConvert(format: "yyyy/MM/dd HH:mm:ss")
        
        print("\(date) \(logLevel) \(className) \(functionName) \(message)")
    }
    
    /// JSON結合
    static func JsonJoin(json1 : Data,Json2 : Data)->Data{
        
//      let str = String(bytes: json1 + Json2, encoding: .utf8)!.replacingOccurrences(of: "\\", with: "")
        //let str = String(bytes: json1 + Json2, encoding: .utf8)!
        let str = String(bytes: json1, encoding: .utf8)!.replacingOccurrences(of: "\\/", with: "/") + String(bytes: Json2, encoding: .utf8)!
        let jsonValue = str.replacingOccurrences(of: "}{", with: ",").data(using: .utf8)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: CommonUtil().className , functionName: #function , message: "")
        return jsonValue!
    }

/*
    /// 睡眠JSON結合
    static func JsonSleepJoin(json1 : Data,Json2 : Data)->Data{
        let str = String(bytes: json1 + Json2, encoding: .utf8)!.replacingOccurrences(of: "\\\\", with: "")
        let jsonValue = str.replacingOccurrences(of: "}{", with: ",").data(using: .utf8)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: CommonUtil().className , functionName: #function , message: "")
        return jsonValue!
    }
*/
    /// デバイス情報JSON作成
    static func CreateDeviceInfoJson(deviceId : String,deviceAddress : String, batteryLevel : String,rssi : String,deviceType :  Int,sendDataType : Int)->Data{
        ///新フォーマット
        var deviceInfo = CommonCodable.DeviceInfo()
        print(deviceAddress)
        // デバイスID
        deviceInfo.DEVICE_ID = deviceId
        // デバイスアドレス
        deviceInfo.DEVICE_ADR = deviceAddress
        // 電池残量
        deviceInfo.BATTERY_LEVEL = batteryLevel
        // RSSI
        deviceInfo.RSSI = rssi
        ///デバイス種別
        deviceInfo.DEVICE_TYPE = deviceType
        // 送信データ種別
//        deviceInfo.DATA_TYPE = dataType
        deviceInfo.DATA_TYPE = sendDataType
        print(sendDataType)
        
        // @@@旧フォーマット
//        var deviceInfo = CommonCodable.OldDeviceInfo()
//        deviceInfo.setUserSetting()
//        /// デバイスID
//        deviceInfo.DVID = deviceId
//        ///デバイスアドレス
//        deviceInfo.DVAD = deviceAddress
//        ///電池残量
//        deviceInfo.BATTERY_LEVEL = batteryLevel
//        ///RSSI
//        deviceInfo.RSSI = rssi
//        print(deviceInfo)
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(deviceInfo) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: CommonUtil().className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: CommonUtil().className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: CommonUtil().className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// ペアリング版デバイス情報JSON作成
    static func CreateDevicePairingInfoJson(firmwareVersion: String, deviceId : String,deviceAddress : String, deviceType :  Int,sendDataType : Int)->Data{
        ///新フォーマット
        var deviceInfo = CommonCodable.DeviceInfoPairing()
        // デバイスID
        deviceInfo.DEVICE_ID = deviceId
        // デバイスアドレス
        deviceInfo.DEVICE_ADR = deviceAddress
        //デバイスファームウェア情報
        deviceInfo.FIRMWARE_VERSION = firmwareVersion
        ///デバイス種別
        deviceInfo.DEVICE_TYPE = deviceType
        // 送信データ種別
//        deviceInfo.DATA_TYPE = dataType
        deviceInfo.DATA_TYPE = sendDataType
//        print(sendDataType)
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(deviceInfo) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: CommonUtil().className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: CommonUtil().className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: CommonUtil().className , functionName: #function , message: "")
        return jsonValue
    }
    
    // ウォッチデバイス情報登録
    static func SaveWatchDeviceData(watchDeviceArray : [String]) {
        
        let watchDeviceData = WatchDeviceData(
            watchDeviceArray: watchDeviceArray)
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: watchDeviceData,requiringSecureCoding: false)
            else {
                return
        }
        UserDefaults.standard.set(data, forKey: WatchConst.WatchDeviceRegistData.WatchDeviceData)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: CommonUtil().className , functionName: #function , message: "")
    }
    
    // ウォッチデバイス情報読み出し
    static func LoadWatchDeviceData() -> WatchDeviceData? {
        guard let data = UserDefaults.standard.data(forKey: WatchConst.WatchDeviceRegistData.WatchDeviceData) else {
            return nil
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: CommonUtil().className , functionName: #function , message: "")
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? WatchDeviceData
    }
    
    /// アプリ名を取得する
    static func GetAppName() -> String {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: CommonUtil().className , functionName: #function , message: "")
        if let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName"), let appName = value as? String {
            return appName
        } else {
            return ""
        }
    }
}
