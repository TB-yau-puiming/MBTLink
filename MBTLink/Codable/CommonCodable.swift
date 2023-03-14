//
// CommonCodable.swift
// 共通Codable
//
// MBTLink
//

import Foundation

struct CommonCodable  {
    /// 共通
    struct Common : Codable {
        /// IoTゲートウェイ番号
        var GWN : String
        ///位置情報(緯度)　※スマホから現在位置を取得
        var GPS_LAT : String
        ///位置情報(経度)
        var GPS_LNG : String
        ///タイムゾーン
        var TIME_ZONE : String
        ///データ送信日時(YYYYMMDDhhmmss)
        var POST_DATE : String
        ///連番 (IoTゲートウェイ起動時からの要求連番 1～65534)
        var TSN : String
        ///モジュールバージョン
        var MODULE_VERSION : String
        ///個人認証ID
        var PERSONAL_ID : String
        
        /// イニシャライザ
        init(){
            /// IoTゲートウェイ番号
//            GWN = "1019F30001"
            GWN = ""
            ///位置情報(緯度)　※スマホから現在位置を取得
            GPS_LAT = ""
            ///位置情報(経度)
            GPS_LNG = ""
            ///タイムゾーン
            TIME_ZONE = ""
            ///データ送信日時(YYYYMMDDhhmmss)
            POST_DATE = ""
            ///連番 (IoTゲートウェイ起動時からの要求連番 1～65534)
            TSN = ""
            ///モジュールバージョン
            MODULE_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            ///個人認証ID
//            PERSONAL_ID = "9000030001"
            PERSONAL_ID = ""
        }
        
        mutating func setUserSetting(){
            let key = "key" + "_" + "userSettingData"
            let userSettings = UserDefaults.standard.getUserSetting(key)
            GWN = userSettings?.serialNumber ?? ""
            PERSONAL_ID = userSettings?.personalID ?? ""
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "CommonCodable" , functionName: #function , message: "")
        }
    }
    
    //アプリバージョン通知
    struct AppVersion : Codable {
        /// IoTゲートウェイ番号
        var GWN : String
        /// ゲートウェイタイプ
        var GATEWAY_TYPE : String
        ///個人認証ID
        var PERSONAL_ID : String
        ///モジュールバージョン
        var MODULE_VERSION : String
        
        init(){
            /// IoTゲートウェイ番号
            GWN = ""
            /// ゲートウェイタイプ
            GATEWAY_TYPE = "iOSGW"
            ///個人認証ID
            PERSONAL_ID = ""
            ///モジュールバージョン
            MODULE_VERSION = ""
        }
        mutating func setUserSetting(){
            let key = "key" + "_" + "userSettingData"
            let userSettings = UserDefaults.standard.getUserSetting(key)
            GWN = userSettings?.serialNumber ?? ""
            PERSONAL_ID = userSettings?.personalID ?? ""
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "CommonCodable" , functionName: #function , message: "")
        }
    }
    
    ///デバイス情報
    struct DeviceInfo : Codable {
        ///デバイスID
        var DEVICE_ID : String
        ///デバイスアドレス
        var DEVICE_ADR : String
        ///電池残量
        var BATTERY_LEVEL : String
        ///RSSI
        var RSSI : String
        ///デバイス種別
        var DEVICE_TYPE : Int
        ///送信データ種別
        var DATA_TYPE : Int
        
        /// イニシャライザ
        init(){
            ///デバイスID
            DEVICE_ID = ""
            ///デバイスアドレス
            DEVICE_ADR = ""
            ///電池残量
            BATTERY_LEVEL = ""
            ///RSSI
            RSSI = ""
            ///デバイス種別
            DEVICE_TYPE = 0
            ///送信データ種別
            DATA_TYPE = 0
        }
    }
    
    ///デバイス情報ペアリング用
    struct DeviceInfoPairing : Codable {
        ///デバイスID
        var DEVICE_ID : String
        ///デバイスアドレス
        var DEVICE_ADR : String
        ///デバイスファームウェア情報
        var FIRMWARE_VERSION : String
        ///デバイス種別
        var DEVICE_TYPE : Int
        ///送信データ種別
        var DATA_TYPE : Int
        
        /// イニシャライザ
        init(){
            ///デバイスID
            DEVICE_ID = ""
            ///デバイスアドレス
            DEVICE_ADR = ""
            ///デバイスファームウェア情報
            FIRMWARE_VERSION = ""
            ///デバイス種別
            DEVICE_TYPE = 0
            ///送信データ種別
            DATA_TYPE = 0
        }
    }
    /// データ
    struct Data : Codable {
        /// データ
        var DATA : String
        /// イニシャライザ
        init(){
            // データ
            DATA = ""
        }
    }
    
    ///位置情報データ送信用
    struct DataInfo : Codable {
        ///デバイス種別
        var DEVICE_TYPE : Int
        ///送信データ種別
        var DATA_TYPE : Int
        
        /// イニシャライザ
        init(){
            ///デバイス種別
            DEVICE_TYPE = 0
            ///送信データ種別
            DATA_TYPE = 0
        }
    }
    
    ///H76歩数
    struct H76StepModel {
        ///歩数
        var step : Int
        ///消費カロリー(kcal)
        var calories : Int
        ///距離(m)
        var distance : Int
        ///取得時間
        var getTime : String
        
        /// イニシャライザ
        init(){
            step = 0
            calories = 0
            distance = 0
            getTime = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        }
    }
    
    // MARK: -  旧仕様フォーマット
    struct OldCommon: Codable{
        ///EasyUplinkのシリアル番号
        var ESN : String
        ///SIM情報
        var MGN : String
        ///位置情報(緯度)
        var GPS_LAT : String
        ///位置情報(経度)
        var GPS_LONG : String
        ///位置情報(制度低下率)　0～100
        var GPS_DOP : String
        ///位置情報(衛星数)　0～12(個)
        var GPS_NOS : String
        ///位置情報(信号強度)　0～99(dB)
        var GPS_SS : String
        ///基地局情報　(MCC,MNC,LAC,CID)(10進数ASCII)
        var CEL : String
        ///データ送信日時(YYYYMMDDhhmmss)
        var DATE : String
        ///連番 (EasyUplink起動時からの要求連番 1～65534)
        var TSN : String
        ///サービスID
        var SERVICE_ID : String
        ///API認証キー
        var API_KEY : String
        ///クライアント種別
        var CLIENT_TYPE : String
        ///モジュールバージョン
        var MODULE_VERSION : String
        ///共通GW予備①
        var CG_RSRV1 : String
        ///共通GW予備②
        var CG_RSRV2 : String
        ///共通GW予備③
        var CG_RSRV3 : String
        
        init(){
            ///EasyUplinkのシリアル番号
//            ESN = "1019F30001"
            ESN = ""
            ///SIM情報
            MGN = ""
            ///位置情報(緯度)
            GPS_LAT = ""
            ///位置情報(経度)
            GPS_LONG = ""
            ///位置情報(制度低下率)　0～100
            GPS_DOP = ""
            ///位置情報(衛星数)　0～12(個)
            GPS_NOS = ""
            ///位置情報(信号強度)　0～99(dB)
            GPS_SS = ""
            ///基地局情報　(MCC,MNC,LAC,CID)(10進数ASCII)
            CEL = ""
            ///データ送信日時(YYYYMMDDhhmmss)
            DATE = ""
            ///連番 (EasyUplink起動時からの要求連番 1～65534)
            TSN = ""
            ///サービスID
            SERVICE_ID = "data"
            ///API認証キー
            API_KEY = ""
            ///クライアント種別
            CLIENT_TYPE = ""
            ///モジュールバージョン
            MODULE_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            ///共通GW予備①
            CG_RSRV1 = ""
            ///共通GW予備②
            CG_RSRV2 = ""
            ///共通GW予備③
            CG_RSRV3 = ""
        }
        
        mutating func setUserSetting(){
            let key = "key" + "_" + "userSettingData"
            let userSettings = UserDefaults.standard.getUserSetting(key)
            ESN = userSettings?.serialNumber ?? ""
        }
    }
    ///デバイス情報
    struct OldDeviceInfo : Codable {
        /// デバイスID
        var DVID : String
        ///デバイスアドレス
        var DVAD : String
        ///電池残量
        var BATTERY_LEVEL : String
        ///RSSI
        var RSSI : String
        ///個人認証ID (ソフトG/Wの場合に必要)
        var CS_RSRV1 : String
        
        /// イニシャライザ
        init(){
            /// デバイスID
            DVID = ""
            ///デバイスアドレス
            DVAD = ""
            ///電池残量
            BATTERY_LEVEL = ""
            ///RSSI
            RSSI = ""
            ///個人認証ID (ソフトG/Wの場合に必要)
//            CS_RSRV1 = "9000030001"
            CS_RSRV1 = ""
        }
        
        mutating func setUserSetting(){
            let key = "key" + "_" + "userSettingData"
            let userSettings = UserDefaults.standard.getUserSetting(key)
            CS_RSRV1 = userSettings?.personalID ?? ""
        }
    }
    
    /// Beacon情報
    struct BeaconInfo : Codable {
        /// Beacon取得日時(YYYYMMDDhhmmss+n)
        var TM : String
        /// Beacon取得情報
        var DT : String
        /// イニシャライザ
        init(){
            /// Beacon取得日時(YYYYMMDDhhmmss+n)
            TM = ""
            /// Beacon取得情報
            DT = ""
        }
    }
    
    /// データ
    struct OldData : Codable {
        /// データ
        var DT : String
        /// イニシャライザ
        init(){
            // データ
            DT = ""
        }
    }
    
    /// 環境センサ
    struct EnvSensorCodable : Codable {
        /// データ取得日時(YYYYMMDDhhmmss+n)
        var TM : String
        ///温度
        var TEMP : String
        ///湿度
        var HUMD : String
        ///輝度
        var BRIT : String
        ///騒音
        var NOIS : String
        ///UV Index (BAG型環境センサ[2JCIE-BL01])
        var UV : String
        ///気圧
        var ATMS : String
        ///VOCガス (USB型環境センサ[2JCIE-BU01])
        var VOC : String
        ///不快指数
        var O_RSRV1 : String
        ///熱中症警戒度
        var O_RSRV2 : String
        
        /// イニシャライザ
        init(){
            /// データ取得日時(YYYYMMDDhhmmss+n)
            TM = ""
            ///温度
            TEMP = ""
            ///湿度
            HUMD = ""
            ///輝度
            BRIT  = ""
            ///騒音
            NOIS  = ""
            ///UV Index (BAG型環境センサ[2JCIE-BL01])
            UV  = ""
            ///気圧
            ATMS  = ""
            ///VOCガス (USB型環境センサ[2JCIE-BU01])
            VOC  = ""
            ///不快指数
            O_RSRV1  = ""
            ///熱中症警戒度
            O_RSRV2  = ""
        }
    }
    /// 血圧計
    struct BloodPressuresMonitorCodable : Codable {
        /// データ取得日時(YYYYMMDDhhmmss+n)
        var TM : String
        ///血圧(高)
        var BP_H : String
        ///血圧(低)
        var BP_L : String
        /// 心拍数
        var PLS : String
        /// イニシャライザ
        init(){
            /// データ取得日時(YYYYMMDDhhmmss+n)
            TM = ""
            ///血圧(高)
            BP_H = ""
            ///血圧(低)
            BP_L = ""
            ///心拍数
            PLS = ""
        }
    }
    /// 体重計
    struct WeightScaleCodable : Codable {
        /// データ取得日時(YYYYMMDDhhmmss+n)
        var TM : String
        ///体重
        var BW : String

        /// イニシャライザ
        init(){
            /// データ取得日時(YYYYMMDDhhmmss+n)
            TM = ""
            ///体重
            BW = ""
        }
    }
    /// 体温計
    struct ThermometerCodable : Codable {
        /// データ取得日時(YYYYMMDDhhmmss+n)
        var TM : String
        ///体温
        var BT : String
        /// イニシャライザ
        init(){
            /// データ取得日時(YYYYMMDDhhmmss+n)
            TM = ""
            ///体温
            BT = ""
        }
    }
    /// パルスオキシメーター
    struct PulseOximeterCodable : Codable {
        /// データ取得日時(YYYYMMDDhhmmss+n)
        var TM : String
        ///測定モード(1：スポット測定 2：モニタリング測定)
        var MEASURE_MODE : String
        ///パルスオキシメータ情報
        var PlsOx : [CommonCodable.OldData]
        
        /// イニシャライザ
        init(){
            /// データ取得日時(YYYYMMDDhhmmss+n)
            TM = ""
            ///測定モード(1：スポット測定 2：モニタリング測定)
            MEASURE_MODE = ""
            ///パルスオキシメータ情報
            PlsOx = [CommonCodable.OldData]()
        }
    }
    /// ウォッチ
    struct WatchCodable  {
        ///歩数
        struct Step : Codable {
            /// データ取得日時(YYYYMMDDhhmmss+n)
            var TM : String
            /// F07歩数データがライブデータの場合に"LIVE"を設定
            var F07_LIVE : String
            /// 歩数情報
            var Step : [CommonCodable.OldData]
            /// 歩行距離情報
            var Dstn : [CommonCodable.OldData]
            /// 消費カロリー情報
            var Cal : [CommonCodable.OldData]
            /// イニシャライザ
            init(){
                /// データ取得日時(YYYYMMDDhhmmss+n)
                TM = ""
                /// F07歩数データがライブデータの場合に"LIVE"を設定
                F07_LIVE = ""
                /// 歩数情報
                Step = [CommonCodable.OldData]()
                /// 歩行距離情報
                Dstn = [CommonCodable.OldData]()
                /// 消費カロリー情報
                Cal = [CommonCodable.OldData]()
            }
        }
        
        ///SPO2
        struct Spo2 : Codable {
            /// データ取得日時(YYYYMMDDhhmmss+n)
            var TM : String
            /// SpO2(経皮的動脈血酸素飽和度)
            var SPO2 : String
            /// イニシャライザ
            init(){
                /// データ取得日時(YYYYMMDDhhmmss+n)
                TM = ""
                // SpO2(経皮的動脈血酸素飽和度)
                SPO2 = ""
            }
        }
    }
    /// ペアリング情報
    struct PairingCodable: Codable  {
        /// ペアリングしたスマートウォッチのMAC(16進数12桁(：なし))
        var F07_MAC : String
        /// イニシャライザ
        init(){
            // ペアリングしたスマートウォッチのMAC(16進数12桁(：なし))
            F07_MAC = ""
        }
    }
}
