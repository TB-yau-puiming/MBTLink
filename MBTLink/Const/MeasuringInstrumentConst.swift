//
// MeasuringInstrumentConst.swift
// 測定機器関連定数
//
// MBTLink
//

import Foundation

struct MeasuringInstrumentConst {
    
    /// 測定機器設定
    struct MeasuringInstrumentSetting{
        /// 未設定
        static let NonSetting = StringsConst.NOT_CONFIGURED
        /// 設定済み
        static let Setting = StringsConst.CONFIGURED
    }
    
    /// 測定機器設定情報登録データ
    struct MeasuringInstrumentSettingInfoRegistData{
        /// 設定中かどうか
        static let IsSettings = "isWatchSettings"
        /// デバイス名
        static let DeviceName = "deviceName"
        /// シリアルナンバー
        static let SerialNumber = "serialNumber"
        /// UUID
        static let Uuid = "uuid"
        /// 測定間隔
        static let MeasuringInterval = "measuringInterval"
        /// 接続中デバイス名
        static let DeviceNamePairing = "deviceNamePairing"
    }
}
