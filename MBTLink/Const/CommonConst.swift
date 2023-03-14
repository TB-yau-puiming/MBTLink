//
// CommonConst.swift
// 共通定数
//
// MBTLink
//

import Foundation

struct CommonConst {
    
    /// ファイル保存ディレクトリ
    static let ReceiveDir : String = "Receive"
    //iBeacon用
    static let iBeacon : String = "iBeacon"
    /// ファイル送信ディレクトリ
    static let SendDir : String = "Send"
    /// データサーバURL
//    static var DataServerUrl = "https://dev.mbtlink.net"
    static var DataServerUrl = ""
    /// MBT Link パーソナルURL
    static let MBTLinkPersonalUrl = "https://dev.mbtlink.net/personal/user"
    
//    /// データ送信URI
    static let DataSendUri = "/api/iotgw/device"
//    /// バージョン通知URI
    static let VersionNotice = "/api/iotgw/version"
//    /// ログ送信URI
    static let LogSendUri = "/api/iotgw/log"
    
    // 旧フォーマット -->
    /// データ送信URI
//    static let DataSendUri = "/iot/ezulink/data/input"
    /// バージョン通知URI
//    static let VersionNotice = "/iot/ezulink/version"
    /// ログ送信URI
//    static let LogSendUri = "/iot/ezulink/acty/log"
    // <--
    
    /// タイマーInterval（秒）
    struct TimeInterval {
        /// iOS端末バッテリー取得監視
        static let IOSDeviceBatteryMonitering : Double = 60*60
    }
    
    /// Segue名称
    struct Segue{
        ///サーバー設定
        static let ServerSettingManage = "showServerSettingManageSegue"
        ///位置情報設定
        static let LocationSettingManage = "showLocationSettingManageSegue"
        /// 測定機器設定
        static let MeasuringInstrumentSetting = "showMeasuringInstrumentSettingSegue"
        /// ウォッチ設定管理
        static let WatchSettingManage = "showWatchSettingManageSegue"
        /// ウォッチ設定LANCEBAND
        static let WatchSetting = "showWatchSettingSegue"
        /// ウォッチ設定CRPSmartBand
        static let WatchSettingCRPSmartBand = "showWatchSettingCRPSmartBandSegue"
        /// ウォッチ種類選択
        static let WatchTypeSelect = "showWatchTypeSelectSegue"
        /// iBeacon表示
        static let IbeaconView = "showIbeaconViewSegue"
        /// WebView
        static let WebView = "showWebViewSegue"
    }
    
    // 半角英数字（大文字）
    static let UpperHalfEngChar = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    // 半角英数字（小文字）
    static let LowerHalfEngChar = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    // 数字
    static let NumericChar = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    
    // 特殊記号
    static let SpecialChar = ["@", "&", "(", ")", ";", ":", "/", "-", "'", "!", "?", ",", ".", "*", "+", "=", "_", "~", "$"]
    
    
    //位置情報送信
    struct locationSendData{
        static var locationSendTimerInterval: Double = 5
        static var locationSendFlg: Bool = false
    }
    
    // ログ出力ディレクトリ
    static let logDir = "Log/WebRequestLog"
    
    // ログ保持日数
    static let logSavingDate = -2
}
