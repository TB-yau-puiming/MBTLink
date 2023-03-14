//
// WeightScaleConst.swift
// A&D 体重計 UC-352BLE関連定数
//
// MBTLink
//

import Foundation

struct WeightScaleConst {
    
    /// タイトル名
    static let TitleName = "A&D 体重計 UC-352BLE"
    /// デバイスID
    static let DeviceId = "UC-352BLE"
    /// デバイス名
    static let DeviceName = "UC-352BLE"
    /// 測定機器設定情報登録データキー
    static let MeasuringInstrumentSettingData = "WeightScaleSettingData"
    /// CSVファイルヘッダー
    static let CsvFileHeader = "receiveDateTime,weightScale,timeStamp"
    /// 測定データエラー値
    static let measurementErrorData = 65535.0
    /// BLEサービス
    struct BleService{
        struct DeviceInformationService {
            /// サービスのUUID
            struct Service {
                static let kUUID  = "180A"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct SerialNumberString {
                    static let kUUID = "2A25"
                }
                struct SystemId {
                    static let kUUID = "2A23"
                }
            }
        }
        struct WeightScaleService {
            /// サービスのUUID
            struct Service {
                static let kUUID  = "181D"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct Measurement {
                    static let kUUID = "2A9D"
                }
                struct DateTime {
                    static let kUUID = "2A08"
                }
            }
        }
        struct BatteryService {
            /// サービスのUUID
            struct Service {
                static let kUUID = "180F"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct BatteryLevel {
                    static let kUUID = "2A19"
                }
            }
        }

    }
}
