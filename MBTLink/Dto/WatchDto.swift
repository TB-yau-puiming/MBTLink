//
// WatchDto.swift
// LANCEBAND2,3関連DTO
//
// MBTLink
//

import Foundation

struct WatchDto{

    /// ウォッチ設定情報
    struct WatchSettingInfo{
        /// ウォッチ設定中かどうか
        private var isWatchSettings : Bool =  false
        /// デバイス名
        private var watchDeviceName : String? = ""
        /// MACアドレス
        private var watchMacAddress : String? = ""
        /// 電話が通知設定中かどうか
        private var isCallNotificationSettings : Bool = false
        /// SMSが通知設定中かどうか
        private var isSmsNotificationSettings : Bool = false
        /// LINEが通知設定中かどうか
        private var isLineNotificationSettings : Bool = false
        /// qqが通知設定中かどうか
        private var isQqNotificationSettings : Bool = false
        /// weChatが通知設定中かどうか
        private var isWeChatNotificationSettings : Bool = false
        /// faceBookが通知設定中かどうか
        private var isFaceBookNotificationSettings : Bool = false
        /// twitterが通知設定中かどうか
        private var isTwitterNotificationSettings : Bool = false
        /// skypeが通知設定中かどうか
        private var isSkypeNotificationSettings : Bool = false
        /// instagramが通知設定中かどうか
        private var isInstagramNotificationSettings : Bool = false
        /// whatsAppが通知設定中かどうか
        private var isWhatsAppNotificationSettings : Bool = false
        /// kakaoTalkが通知設定中かどうか
        private var isKakaoTalkNotificationSettings : Bool = false
        /// gmailが通知設定中かどうか
        private var isGmailNotificationSettings : Bool = false
        /// messengerが通知設定中かどうか
        private var isMessengerNotificationSettings : Bool = false
        /// othersが通知設定中かどうか
        private var isOthersNotificationSettings : Bool = false
        /// 血圧測定するかどうか
        private var bloodPressureMeasure : Bool = true
        /// SpO2測定するかどうか
        private var spO2Measure : Bool = true
        /// 自動測定 測定間隔
        private var measurementInterval : Int = 5
        /// 歩数測定 送信間隔
        private var stepSendInterval : Int = 5
        ///歩幅
        private var stepLength : Int = 70
        /// ウォッチ設定中かどうか
        var IsWatchSettings : Bool{
            get{
                return self.isWatchSettings
            }
            set{
                self.isWatchSettings = newValue
            }
        }
        /// デバイス名
        var WatchDeviceName : String?{
            get{
                return self.watchDeviceName
            }
            set{
                self.watchDeviceName = newValue
            }
        }
        /// MACアドレス
        var WatchMacAddress : String?{
            get{
                return self.watchMacAddress
            }
            set{
                self.watchMacAddress = newValue
            }
        }
        /// 電話が通知設定中かどうか
        var IsCallNotificationSettings : Bool{
            get{
                return self.isCallNotificationSettings
            }
            set{
                self.isCallNotificationSettings = newValue
            }
        }
        /// SMSが通知設定中かどうか
        var IsSmsNotificationSettings : Bool{
            get{
                return self.isSmsNotificationSettings
            }
            set{
                self.isSmsNotificationSettings = newValue
            }
        }
        /// LINEが通知設定中かどうか
        var IsLineNotificationSettings : Bool{
            get{
                return self.isLineNotificationSettings
            }
            set{
                self.isLineNotificationSettings = newValue
            }
        }
        /// qqが通知設定中かどうか
        var IsQqNotificationSettings : Bool{
            get{
                return self.isQqNotificationSettings
            }
            set{
                self.isQqNotificationSettings = newValue
            }
        }
        /// weChatが通知設定中かどうか
        var IsWeChatNotificationSettings : Bool{
            get{
                return self.isWeChatNotificationSettings
            }
            set{
                self.isWeChatNotificationSettings = newValue
            }
        }
        /// faceBookが通知設定中かどうか
        var IsFaceBookNotificationSettings : Bool{
            get{
                return self.isFaceBookNotificationSettings
            }
            set{
                self.isFaceBookNotificationSettings = newValue
            }
        }
        /// twitterが通知設定中かどうか
        var IsTwitterNotificationSettings : Bool{
            get{
                return self.isTwitterNotificationSettings
            }
            set{
                self.isTwitterNotificationSettings = newValue
            }
        }
        /// skypeが通知設定中かどうか
        var IsSkypeNotificationSettings : Bool{
            get{
                return self.isSkypeNotificationSettings
            }
            set{
                self.isSkypeNotificationSettings = newValue
            }
        }
        /// instagramが通知設定中かどうか
        var IsInstagramNotificationSettings : Bool{
            get{
                return self.isInstagramNotificationSettings
            }
            set{
                self.isInstagramNotificationSettings = newValue
            }
        }
        /// whatsAppが通知設定中かどうか
        var IsWhatsAppNotificationSettings : Bool{
            get{
                return self.isWhatsAppNotificationSettings
            }
            set{
                self.isWhatsAppNotificationSettings = newValue
            }
        }
        /// kakaoTalkが通知設定中かどうか
        var IsKakaoTalkNotificationSettings : Bool{
            get{
                return self.isKakaoTalkNotificationSettings
            }
            set{
                self.isKakaoTalkNotificationSettings = newValue
            }
        }
        /// gmailが通知設定中かどうか
        var IsGmailNotificationSettings : Bool{
            get{
                return self.isGmailNotificationSettings
            }
            set{
                self.isGmailNotificationSettings = newValue
            }
        }
        /// messengerが通知設定中かどうか
        var IsMessengerNotificationSettings : Bool{
            get{
                return self.isMessengerNotificationSettings
            }
            set{
                self.isMessengerNotificationSettings = newValue
            }
        }
        /// othersが通知設定中かどうか
        var IsOthersNotificationSettings : Bool{
            get{
                return self.isOthersNotificationSettings
            }
            set{
                self.isOthersNotificationSettings = newValue
            }
        }
        /// 血圧測定するかどうか
        var BloodPressureMeasure : Bool{
            get{
                return self.bloodPressureMeasure
            }
            set{
                self.bloodPressureMeasure = newValue
            }
        }
        /// SpO2測定するかどうか
        var SpO2Measure : Bool{
            get{
                return self.spO2Measure
            }
            set{
                self.spO2Measure = newValue
            }
        }
        /// 自動測定 測定間隔
        var MeasurementInterval : Int{
            get{
                return self.measurementInterval
            }
            set{
                self.measurementInterval = newValue
            }
        }
        /// 歩数測定 送信間隔
        var StepSendInterval : Int{
            get{
                return self.stepSendInterval
            }
            set{
                self.stepSendInterval = newValue
            }
        }
        ///歩幅
        var StepLength : Int{
            get{
                return self.stepLength
            }
            set{
                self.stepLength = newValue
            }
        }
    }
    /// 歩数
    struct Step{
        /// テスト開始時間（UNIX時間）
        private var startTimeUnixTime : String = ""
        /// テスト開始時間
        private var startTime : String = ""
        /// テスト終了時間（UNIX時間）
        private var endTimeUnixTime : String = ""
        /// テスト終了時間
        private var endTime : String = ""
        /// 歩数
        private var step : String = ""
        /// カロリー（単位：Kcal）
        private var calories : String = ""
        /// 距離（単位：メートル）
        private var distance : String = ""
        
        /// テスト開始時間（UNIX時間）
        var StartTimeUnixTime : String {
            get{
                return self.startTimeUnixTime
            }
            set{
                self.startTimeUnixTime = newValue
            }
        }
        /// テスト開始時間
        var StartTime : String {
            get{
                return self.startTime
            }
            set{
                self.startTime = newValue
            }
        }
        /// テスト終了時間（UNIX時間）
        var EndTimeUnixTime : String {
            get{
                return self.endTimeUnixTime
            }
            set{
                self.endTimeUnixTime = newValue
            }
        }
        /// テスト終了時間
        var EndTime : String {
            get{
                return self.endTime
            }
            set{
                self.endTime = newValue
            }
        }
        /// 歩数
        var Step : String {
            get{
                return self.step
            }
            set{
                self.step = newValue
            }
        }
        /// カロリー（単位：Kcal）
        var Calories : String {
            get{
                return self.calories
            }
            set{
                self.calories = newValue
            }
        }
        /// 距離（単位：メートル）
        var Distance : String {
            get{
                return self.distance
            }
            set{
                self.distance = newValue
            }
        }
    }

    ///H76歩数
    struct H76StepModel {
        ///歩数
        private var step : Int
        ///消費カロリー(kcal)
        private var calories : Int
        ///距離(m)
        private var distance : Int
        ///取得時間
        private var getTime : String

        
        ///歩数
        var Step : Int {
            get{
                return self.step
            }
            set{
                self.step = newValue
            }
        }
        ///消費カロリー(kcal)
        var Calories : Int {
            get{
                return self.calories
            }
            set{
                self.calories = newValue
            }
        }
        ///距離(m)
        var Distance : Int {
            get{
                return self.distance
            }
            set{
                self.distance = newValue
            }
        }
        ///取得時間
        var GetTime : String {
            get{
                return self.getTime
            }
            set{
                self.getTime = newValue
            }
        }
    }
    
    /// 心拍数
    struct Heart{
        /// テスト開始時間（UNIX時間）
        private var startTimeUnixTime : String = ""
        /// テスト開始時間
        private var startTime : String = ""
        /// 心拍数
        private var heartNum : String = ""
        
        /// テスト開始時間（UNIX時間）
        var StartTimeUnixTime : String {
            get{
                return self.startTimeUnixTime
            }
            set{
                self.startTimeUnixTime = newValue
            }
        }
        /// テスト開始時間
        var StartTime : String {
            get{
                return self.startTime
            }
            set{
                self.startTime = newValue
            }
        }
        /// 心拍数
        var HeartNum : String {
            get{
                return self.heartNum
            }
            set{
                self.heartNum = newValue
            }
        }
    }
    /// 血圧
    struct Blood{
        /// テスト開始時間（UNIX時間）
        private var startTimeUnixTime : String = ""
        /// テスト開始時間
        private var startTime : String = ""
        /// 収縮期血圧
        private var sbp : String = ""
        /// 拡張期血圧
        private var dbp : String = ""
        /// テスト開始時間（UNIX時間）
        var StartTimeUnixTime : String {
            get{
                return self.startTimeUnixTime
            }
            set{
                self.startTimeUnixTime = newValue
            }
        }
        /// テスト開始時間
        var StartTime : String {
            get{
                return self.startTime
            }
            set{
                self.startTime = newValue
            }
        }
        /// 拡張期血圧
        var Dbp : String {
            get{
                return self.dbp
            }
            set{
                self.dbp = newValue
            }
        }
        /// 収縮期血圧
        var Sbp : String {
            get{
                return self.sbp
            }
            set{
                self.sbp = newValue
            }
        }
    }
    
    /// 総合
    struct Combined{
        /// テスト開始時間（UNIX時間）
        private var startTimeUnixTime : String = ""
        /// テスト開始時間
        private var startTime : String = ""
        /// 歩数（単位:歩）
        private var step : String = ""
        /// 心拍数
        private var heatRate : String = ""
        /// 収縮期血圧
        private var sbp : String = ""
        /// 拡張期血圧
        private var dbp : String = ""
        /// 血中酸素濃度（SPO2）
        private var spo2 : String = ""
        /// 呼吸数
        private var respiratoryRate : String = ""
        /// HRV值
        private var hrv : String = ""
        /// CVRR值
        private var cvrr : String = ""
        /// 摂氏温度の整数部分
        private var tmepInt : String = ""
        /// 摂氏温度の小数部分
        private var tmepFloat : String = ""
        
        /// テスト開始時間（UNIX時間）
        var StartTimeUnixTime : String {
            get{
                return self.startTimeUnixTime
            }
            set{
                self.startTimeUnixTime = newValue
            }
        }
        /// テスト開始時間
        var StartTime : String {
            get{
                return self.startTime
            }
            set{
                self.startTime = newValue
            }
        }
        /// 歩数（単位:歩）
        var Step : String {
            get{
                return self.step
            }
            set{
                self.step = newValue
            }
        }
        /// 心拍数
        var HeatRate : String {
            get{
                return self.heatRate
            }
            set{
                self.heatRate = newValue
            }
        }
        /// 収縮期血圧
        var Sbp : String {
            get{
                return self.sbp
            }
            set{
                self.sbp = newValue
            }
        }
        /// 拡張期血圧
        var Dbp : String {
            get{
                return self.dbp
            }
            set{
                self.dbp = newValue
            }
        }
        /// 血中酸素濃度（SPO2）
        var Spo2 : String {
            get{
                return self.spo2
            }
            set{
                self.spo2 = newValue
            }
        }
        /// 呼吸数
        var RespiratoryRate : String {
            get{
                return self.respiratoryRate
            }
            set{
                self.respiratoryRate = newValue
            }
        }
        /// HRV值
        var Hrv : String {
            get{
                return self.hrv
            }
            set{
                self.hrv = newValue
            }
        }
        /// CVRR值
        var Cvrr : String {
            get{
                return self.cvrr
            }
            set{
                self.cvrr = newValue
            }
        }
        /// 摂氏温度の整数部分
        var TmepInt : String {
            get{
                return self.tmepInt
            }
            set{
                self.tmepInt = newValue
            }
        }
        /// 摂氏温度の小数部分
        var TmepFloat : String {
            get{
                return self.tmepFloat
            }
            set{
                self.tmepFloat = newValue
            }
        }
    }
}

