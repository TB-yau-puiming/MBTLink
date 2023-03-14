//
// ThermometerConst.swift
// A&D 体温計 UT-201BLE関連定数
//
// MBTLink
//

import Foundation

struct ThermometerConst {
    
    // タイトル名
    static let TitleName = "A&D 体温計 UT-201BLE"
    /// デバイスID
    static let DeviceId = "UT-201BLE"
    /// デバイス名
    static let DeviceName = "UT201BLE"
    /// 測定機器設定情報登録データキー
    static let MeasuringInstrumentSettingData = "ThermometerSettingData"
    /// CSVファイルヘッダー
    static let CsvFileHeader = "receiveDateTime,temperature,timeStamp"
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
        struct ThermometerService {
            /// サービスのUUID
            struct Service {
                static let kUUID  = "1809"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct TemperatureMeasurement {
                    static let kUUID = "2A1C"
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
