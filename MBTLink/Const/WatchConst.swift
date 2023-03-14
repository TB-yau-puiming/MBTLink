//
// WatchConst.swift
// ウォッチ関連定数
//
// MBTLink
//

import Foundation

struct WatchConst {
    /// CSVファイルヘッダー
    struct CsvFileHeader {
        /// LANCEBAND
        struct Lanceband {
            /// 履歴データ歩数 CSVファイルヘッダー
            static let HistoryDataStepCsvFileHeader = "receiveDateTime,startTimeUnixTime,endTimeUnixTime,startTime,endTime,step,calories,distance"
            /// 履歴データ心拍数 CSVファイルヘッダー
            static let HistoryDataHeartCsvFileHeader = "receiveDateTime,startTimeUnixTime,startTime,heartNum"
            /// 履歴データ血圧 CSVファイルヘッダー
            static let HistoryDataBloodCsvFileHeader = "receiveDateTime,startTimeUnixTime,startTime,sbp,dbp"
            /// 履歴データSPO2 CSVファイルヘッダー
            static let HistoryDataSpo2CsvFileHeader = "receiveDateTime,startTimeUnixTime,startTime,spo2"
        }
        /// CRPSmartBand
        struct CRPSmartBand {
            /// 心拍数 CSVファイルヘッダー
            static let HeartRateDataCsvFileHeader = "receiveDateTime,heartRate"
            /// 血圧 CSVファイルヘッダー
            static let BloodDataCsvFileHeader = "receiveDateTime,heartRate,sbp,dbp"
            /// SPO2 CSVファイルヘッダー
            static let Spo2DataCsvFileHeader = "receiveDateTime,spo2"
            /// 歩数 CSVファイルヘッダー
            static let StepDataCsvFileHeader = "receiveDateTime,step,calories,distance,getTime"
            /// 24時間心拍数ファイルヘッダー
            static let HeartRate24DataCsvFileHeader = "receiveDateTime,heartrate"
            /// 24時間心拍数ファイルヘッダー
            static let SleepHistoryDataCsvFileHeader = "receiveDateTime,detail"
            /// 24時間歩数ファイルヘッダー
            static let Step24DataCsvFileHeader = "receiveDateTime,steps"
            
            ///睡眠CSVファイルヘッダー
            static let SleepDataCsvFileHeader = "receiveDateTime,awake,lightSleep,deepSleep"
        }
    }

    /// ウォッチデバイス名
    struct WatchDeviceName{
        /// LANCEBAND2
        static let Lanceband2 : String = "V5"
        /// LANCEBAND3
        static let Lanceband3 : String = "M18 Plus"
        /// CRPSmartBand
        static let CRPSmartBand : String = "H76"
    }
    
    /// ウォッチ種類
    struct WatchType{
        /// LANCEBAND
        static let Lanceband : String = "LANCEBAND"
        /// CRPSmartBand
        static let CRPSmartBand : String = "H76"
        /// その他
        static let Other : String = "その他"
    }
    
    /// LANCEBAND種類
    struct LancebandType{
        /// LANCEBAND2
        static let Lanceband2 : String = "LANCEBAND2"
        /// LANCEBAND3
        static let Lanceband3 : String = "LANCEBAND3"
        /// その他
        static let Other : String = "その他"
    }
    
    /// タイマーInterval（秒）
    struct TimeInterval {
        /// スキャンデバイス
        static let WatchScanDevice : Double = 5
        /// 履歴データ取得・歩数
        static let WatchSyncHistoryStep : Double = 1800
        /// 履歴データ取得・脈拍
        static let WatchSyncHistoryHeart : Double = 60
        /// 履歴データ取得・血圧
        static let WatchSyncHistoryBlood : Double = 60
        /// 履歴データ取得・総合
        static let WatchSyncHistoryCombined: Double = 60
        /// 測定結果データ取得
        static let WatchMeasurementResultData :Double = 120
        /// ウォッチ接続監視
        static let WatchConnectMonitoring : Double = 3
        /// MACアドレス取得
        static let GetMacAddress : Double = 1
        /// CRPSmartbandデータ取得監視
        static let CRPSmartBandGetDataMonitoring : Double = 180 //30
        /// CRPSmartband歩数データ取得監視
        static let CRPSmartBandGetStepsDataMonitoring : Double = 300
    }
    
    /// ウォッチ自動計測時間（分）
    struct WatchAutoMeasurementTime{
        /// 脈拍
        static let Heart : Int = 1
        /// 血圧
        static let Blood : Int = 1
    }
    
    /// リトライカウント
    struct Retry{
        /// 測定結果データ取得・処理中・接続中リトライ開始カウント
        static let ProssesingConnectRetryStartCount : Int = 1 ///5
        /// 測定結果データ取得・処理中・接続中リトライ終了カウント
        static let ProssesingConnectRetryEndCount : Int = 0 ///7
        /// 測定結果データ取得・未完・未接続リトライ終了カウント
        static let IncompleteDisconnectRetryEndCount : Int = 5
    }
    
    /// ウォッチ設定情報登録データ
    struct WatchSettingInfoRegistData{
        /// ウォッチ設定情報登録データキー
        static let WatchSettingData = "WatchSettingData"
        /// ウォッチ設定中かどうか
        static let IsWatchSettings = "isWatchSettings"
        /// デバイス名
        static let WatchDeviceName = "watchDeviceName"
        /// MACアドレス
        static let WatchMacAddress = "watchMacAddress"
        /// 電話が通知設定中かどうか
        static let IsCallNotificationSettings = "isCallNotificationSettings"
        /// SMSが通知設定中かどうか
        static let IsSmsNotificationSettings = "isSmsNotificationSettings"
        /// LINEが通知設定中かどうか
        static let IsLineNotificationSettings = "isLineNotificationSettings"
        ///qqが通知設定中かどうか
        static let IsQqNotificationSettings = "IsQqNotificationSettings"
        ///weChatが通知設定中かどうか
        static let IsWeChatNotificationSettings = "IsWeChatNotificationSettings"
        ///faceBookが通知設定中かどうか
        static let IsFaceBookNotificationSettings = "IsFaceBookNotificationSettings"
        ///twitterが通知設定中かどうか
        static let IsTwitterNotificationSettings = "IsTwitterNotificationSettings"
        ///skypeが通知設定中かどうか
        static let IsSkypeNotificationSettings = "IsSkypeNotificationSettings"
        ///instagramが通知設定中かどうか
        static let IsInstagramNotificationSettings = "IsInstagramNotificationSettings"
        ///whatsAppが通知設定中かどうか
        static let IsWhatsAppNotificationSettings = "IsWhatsAppNotificationSettings"
        ///kakaoTalkが通知設定中かどうか
        static let IsKakaoTalkNotificationSettings = "IsKakaoTalkNotificationSettings"
        ///gmailが通知設定中かどうか
        static let IsGmailNotificationSettings = "IsGmailNotificationSettings"
        ///messengerが通知設定中かどうか
        static let IsMessengerNotificationSettings = "IsMessengerNotificationSettings"
        ///othersが通知設定中かどうか
        static let IsOthersNotificationSettings = "IsOthersNotificationSettings"
        /// 血圧測定するかどうか
        static let BloodPressureMeasure = "BloodPressureMeasure"
        /// SpO2測定するかどうか
        static let SpO2Measure = "SpO2Measure"
        /// 自動測定 測定間隔
        static let MeasurementInterval =  "measurementInterval"
        /// 歩数測定 送信間隔
        static let StepSendInterval =  "stepSendInterval"
        /// 歩数測定 送信間隔
        static let StepLength =  "stepLength"
    }
    
    /// ウォッチデバイス登録データ
    struct WatchDeviceRegistData{
        /// ウォッチデバイス登録データキー
        static let WatchDeviceData = "WatchDeviceData"
        /// ウォッチデバイスArray
        static let WatchDeviceArray = "watchDeviceArray"
    }
    
    ///ウォッチ言語設定
    struct H76DeviceLanguage{
        static let ENG = 0
        static let CH = 1
        static let JP = 2
    }
}

