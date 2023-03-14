//
// PulseOximeterConst.swift
// A&D パルスオキシメータ TM1121関連定数
//
// MBTLink
//

import Foundation

struct PulseOximeterConst {
    
    /// タイトル名
    static let TitleName = "A&D パルスオキシメータTM1121"
    /// デバイスID
    static let DeviceId = "TM1121"
    /// デバイス名
    static let DeviceName = "TM1121"
    /// 測定機器設定情報登録データキー
    static let MeasuringInstrumentSettingData = "PulseOximeterSettingData"
    /// CSVファイルヘッダー
    static let CsvFileHeader = "receiveDateTime,flag,stat,spo2,pulseRate,timeStamp"
    /// BLEサービス
    struct BleService{
        struct PulseOximeter {
            /// サービスのUUID
            struct Service {
                static let kUUID = "23444100-9C95-1740-A38A-000BDB712C7C"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                    static let kUUID = "23444102-9C95-1740-A38A-000BDB712C7C"
            }
        }
    }
}
