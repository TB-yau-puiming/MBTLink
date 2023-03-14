//
// BloodPressuresMonitorConst.swift
// A&D 血圧計 UA-651BLE関連定数
//
// MBTLink
//

import Foundation

struct BloodPressuresMonitorConst {
    
    /// タイトル名
    static let TitleName = "A&D 血圧計 UA-651BLE"
    /// デバイスID
    static let DeviceId = "UA-651BLE"
    /// デバイス名
    static let DeviceName = "UA-651BLE"
    /// 測定機器設定情報登録データキー
    static let MeasuringInstrumentSettingData = "BloodPressuresMonitorSettingData"
    /// CSVファイルヘッダー
    static let CsvFileHeader = "receiveDateTime,systolicPressure,diastolicPressure,MeanArterialPressure,timeStamp,pulseRate"
    /// 測定データエラー値
    static let measurementErrorData = 255.0
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
        struct BloodPressure {
            /// サービスのUUID
            struct Service {
                static let kUUID  = "1810"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct Measurement {
                    static let kUUID = "2A35"
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
