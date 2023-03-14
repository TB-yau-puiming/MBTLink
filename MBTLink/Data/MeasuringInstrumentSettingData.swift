//
// MeasuringInstrumentSettingData.swift
// 測定機器設定情報登録データ関連
//
// MBTLink
//

import Foundation.NSObject

class MeasuringInstrumentSettingData: NSObject, NSCoding {

    /// 設定中かどうか
    var IsSettings : Bool
    /// デバイス名
    var DeviceName : String?
    /// シリアルナンバー
    var SerialNumber : String?
    /// UUID
    var Uuid : String?
    /// 測定間隔
    var MeasuringInterval : String?
    /// 接続中デバイス名
    var deviceNamePairing : String?
    
    init(isSettings: Bool, deviceName: String?, serialNumber : String?, uuid : String?, measuringInterval : String?, deviceNamePairing: String?) {
        self.IsSettings = isSettings
        self.DeviceName = deviceName
        self.SerialNumber = serialNumber
        self.Uuid = uuid
        self.MeasuringInterval = measuringInterval
        self.deviceNamePairing = deviceNamePairing
    }
    
    /// デシリアライズ処理
    required init?(coder: NSCoder) {
        // 設定中かどうか
        self.IsSettings = coder.decodeBool(forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.IsSettings)
        // デバイス名
        self.DeviceName = (coder.decodeObject(forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.DeviceName) as? String) ?? ""
        // シリアルナンバー
        self.SerialNumber = (coder.decodeObject(forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.SerialNumber) as? String) ?? ""
        // UUID
        self.Uuid = (coder.decodeObject(forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.Uuid) as? String) ?? ""
        // 測定間隔
        self.MeasuringInterval = (coder.decodeObject(forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.MeasuringInterval) as? String) ?? ""
        // 接続中デバイス名
        self.deviceNamePairing = (coder.decodeObject(forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.DeviceNamePairing) as? String) ?? ""
    }
    
    /// シリアライズ処理
    func encode(with coder: NSCoder) {
        // 設定中かどうか
        coder.encode(self.IsSettings, forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.IsSettings)
        // デバイス名
        coder.encode(self.DeviceName, forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.DeviceName)
        // シリアルナンバー
        coder.encode(self.SerialNumber, forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.SerialNumber)
        // UUID
        coder.encode(self.Uuid, forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.Uuid)
        // 測定間隔
        coder.encode(self.MeasuringInterval, forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.MeasuringInterval)
        // 接続中デバイス名
        coder.encode(self.deviceNamePairing, forKey: MeasuringInstrumentConst.MeasuringInstrumentSettingInfoRegistData.DeviceNamePairing)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "MeasuringInstrumentSettingData" , functionName: #function , message: "")
    }
}
