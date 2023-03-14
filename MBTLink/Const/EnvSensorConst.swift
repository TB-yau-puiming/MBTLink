//
// EnvSensorConst.swift
// オムロン 環境センサ 2JCIE-BL01関連定数
//
// MBTLink
//

import Foundation

struct EnvSensorConst {
    
    /// タイトル名
    static let TitleName = "オムロン環境センサ 2JCIE-BL01"
    /// デバイスID
    static let DeviceId = "2JCIE-BL01"
    /// デバイス名
    //static let DeviceName = "EnvSensor-BL01"
    static let DeviceName = "Env"
    /// 測定機器設定情報登録データキー
    static let MeasuringInstrumentSettingData = "EnvSensorSettingData"
    /// CSVファイルヘッダー
    static let CsvFileHeader = "receiveDateTime,temperature,relativeHumidity,ambientLight,uvIndex,pressure,soundNoise,discomfortIndex,featStroke,supplyVoltage"
    /// BLEサービス
    struct BleService{
        struct DeviceInformationService {
            /// サービスのUUID
            struct Service {
                static let kUUID = "180A"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct SerialNumberString {
                    static let kUUID = "2A25"
                }
            }
        }
    
        struct SensorService {
            /// サービスのUUID
            struct Service {
                static let kUUID = "0C4C3000-7700-46F4-AA96-D5E974E32A54"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct LatestData {
                    static let kUUID = "0C4C3001-7700-46F4-AA96-D5E974E32A54"
                }
            }
        }
    
        struct ControlService {
            /// サービスのUUID
            struct Service {
                static let kUUID = "0C4C3030-7700-46F4-AA96-D5E974E32A54"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct TimeInformation {
                    static let kUUID = "0C4C3031-7700-46F4-AA96-D5E974E32A54"
                }
                struct LEDonDuration {
                    static let kUUID = "0C4C3032-7700-46F4-AA96-D5E974E32A54"
                }
                struct ErrorStatus {
                    static let kUUID = "0C4C3033-7700-46F4-AA96-D5E974E32A54"
                }
                struct Trigger {
                    static let kUUID = "0C4C3034-7700-46F4-AA96-D5E974E32A54"
                }
            }
        }
    
        struct ParameterService {
            /// サービスのUUID
            struct Service {
                static let kUUID = "0C4C3040-7700-46F4-AA96-D5E974E32A54"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct ADVsetting {
                    static let kUUID = "0C4C3042-7700-46F4-AA96-D5E974E32A54"
                }
            }
        }
    
        struct GenericAccessService {
            /// サービスのUUID
            struct Service {
                static let kUUID = "0C4C1800-7700-46F4-AA96-D5E974E32A54"
            }
            /// サービスのキャラクタリスティックのUUID
            struct Characteristic {
                struct DeviceName {
                    static let kUUID = "0C4C2A00-7700-46F4-AA96-D5E974E32A54"
                }
            }
        }
    }
}
