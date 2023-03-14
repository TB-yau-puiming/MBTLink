//
// WatchSettingData.swift
// ウォッチ設定情報登録データ関連
//
// MBTLink
//

import Foundation.NSObject

class WatchSettingData: NSObject, NSCoding {

    /// ウォッチ設定中かどうか
    var IsWatchSettings : Bool
    /// デバイス名
    var WatchDeviceName : String?
    /// MACアドレス
    var WatchMacAddress : String?
    /// 電話が通知設定中かどうか
    var IsCallNotificationSettings : Bool
    /// SMSが通知設定中かどうか
    var IsSmsNotificationSettings : Bool
    /// LINEが通知設定中かどうか
    var IsLineNotificationSettings : Bool
    ///qqが通知設定中かどうか
    var IsQqNotificationSettings : Bool
    ///weChatが通知設定中かどうか
    var IsWeChatNotificationSettings : Bool
    ///faceBookが通知設定中かどうか
    var IsFaceBookNotificationSettings : Bool
    ///twitterが通知設定中かどうか
    var IsTwitterNotificationSettings : Bool
    ///skypeが通知設定中かどうか
    var IsSkypeNotificationSettings : Bool
    ///instagramが通知設定中かどうか
    var IsInstagramNotificationSettings : Bool
    ///whatsAppが通知設定中かどうか
    var IsWhatsAppNotificationSettings : Bool
    ///kakaoTalkが通知設定中かどうか
    var IsKakaoTalkNotificationSettings : Bool
    ///gmailが通知設定中かどうか
    var IsGmailNotificationSettings : Bool
    ///messengerが通知設定中かどうか
    var IsMessengerNotificationSettings : Bool
    ///othersが通知設定中かどうか
    var IsOthersNotificationSettings : Bool
    /// 血圧測定するかどうか
    var BloodPressureMeasure : Bool
    /// SpO2測定するかどうか
    var SpO2Measure : Bool
    /// 自動測定 測定間隔
    var MeasurementInterval : Int = 5
    /// 歩数測定 送信間隔
    var StepSendInterval : Int = 5
    /// 歩幅
    var StepLength : Int = 70
    
    init(isWatchSettings: Bool, watchDeviceName: String?, watchMacAddress : String?, isCallNotificationSettings : Bool, isSmsNotificationSettings : Bool, isLineNotificationSettings : Bool, IsQqNotificationSettings : Bool, IsWeChatNotificationSettings : Bool, IsFaceBookNotificationSettings : Bool, IsTwitterNotificationSettings : Bool, IsSkypeNotificationSettings : Bool, IsInstagramNotificationSettings : Bool, IsWhatsAppNotificationSettings : Bool, IsKakaoTalkNotificationSettings : Bool, IsGmailNotificationSettings : Bool, IsMessengerNotificationSettings : Bool, IsOthersNotificationSettings : Bool,BloodPressureMeasure : Bool, SpO2Measure : Bool, measurementInterval : Int, stepSendInterval : Int, stepLength : Int) {
        self.IsWatchSettings = isWatchSettings
        self.WatchDeviceName = watchDeviceName
        self.WatchMacAddress = watchMacAddress
        self.IsCallNotificationSettings = isCallNotificationSettings
        self.IsSmsNotificationSettings = isSmsNotificationSettings
        self.IsLineNotificationSettings = isLineNotificationSettings
        self.IsQqNotificationSettings = IsQqNotificationSettings
        self.IsWeChatNotificationSettings = IsWeChatNotificationSettings
        self.IsFaceBookNotificationSettings = IsFaceBookNotificationSettings
        self.IsTwitterNotificationSettings = IsTwitterNotificationSettings
        self.IsSkypeNotificationSettings = IsSkypeNotificationSettings
        self.IsInstagramNotificationSettings = IsInstagramNotificationSettings
        self.IsWhatsAppNotificationSettings = IsWhatsAppNotificationSettings
        self.IsKakaoTalkNotificationSettings = IsKakaoTalkNotificationSettings
        self.IsGmailNotificationSettings = IsGmailNotificationSettings
        self.IsMessengerNotificationSettings = IsMessengerNotificationSettings
        self.IsOthersNotificationSettings = IsOthersNotificationSettings
        self.BloodPressureMeasure = BloodPressureMeasure
        self.SpO2Measure = SpO2Measure
        self.MeasurementInterval = measurementInterval
        self.StepSendInterval = stepSendInterval
        self.StepLength = stepLength
    }
    
    required init?(coder: NSCoder) {
        // ウォッチ設定中かどうか
        self.IsWatchSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsWatchSettings)
        // デバイス名
        self.WatchDeviceName = (coder.decodeObject(forKey: WatchConst.WatchSettingInfoRegistData.WatchDeviceName) as? String) ?? ""
        // MACアドレス
        self.WatchMacAddress = (coder.decodeObject(forKey: WatchConst.WatchSettingInfoRegistData.WatchMacAddress) as? String) ?? ""
        // 電話が通知設定中かどうか
        self.IsCallNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsCallNotificationSettings)
        // SMSが通知設定中かどうか
        self.IsSmsNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsSmsNotificationSettings)
        // LINEが通知設定中かどうか
        self.IsLineNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsLineNotificationSettings)
        //qqが通知設定中かどうか
        self.IsQqNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsQqNotificationSettings)
        //weChatが通知設定中かどうか
        self.IsWeChatNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsWeChatNotificationSettings)
        //faceBookが通知設定中かどうか
        self.IsFaceBookNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsFaceBookNotificationSettings)
        //twitterが通知設定中かどうか
        self.IsTwitterNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsTwitterNotificationSettings)
        //skypeが通知設定中かどうか
        self.IsSkypeNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsSkypeNotificationSettings)
        //instagramが通知設定中かどうか
        self.IsInstagramNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsInstagramNotificationSettings)
        //whatsAppが通知設定中かどうか
        self.IsWhatsAppNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsWhatsAppNotificationSettings)
        //kakaoTalkが通知設定中かどうか
        self.IsKakaoTalkNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsKakaoTalkNotificationSettings)
        //gmailが通知設定中かどうか
        self.IsGmailNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsGmailNotificationSettings)
        //messengerが通知設定中かどうか
        self.IsMessengerNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsMessengerNotificationSettings)
        //othersが通知設定中かどうか
        self.IsOthersNotificationSettings = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.IsOthersNotificationSettings)
        // 血圧測定するかどうか
        self.BloodPressureMeasure = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.BloodPressureMeasure)
        // SpO2測定するかどうか
        self.SpO2Measure = coder.decodeBool(forKey: WatchConst.WatchSettingInfoRegistData.SpO2Measure)
        // 自動測定 自動計測
        self.MeasurementInterval = (coder.decodeInteger(forKey: WatchConst.WatchSettingInfoRegistData.MeasurementInterval))
        // 歩数測定 送信計測
        self.StepSendInterval = (coder.decodeInteger(forKey: WatchConst.WatchSettingInfoRegistData.StepSendInterval))
        // 歩幅
        self.StepLength = (coder.decodeInteger(forKey: WatchConst.WatchSettingInfoRegistData.StepLength))
    }
    
    func encode(with coder: NSCoder) {
        // ウォッチ設定中かどうか
        coder.encode(self.IsWatchSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsWatchSettings)
        // デバイス名
        coder.encode(self.WatchDeviceName, forKey: WatchConst.WatchSettingInfoRegistData.WatchDeviceName)
        // MACアドレス
        coder.encode(self.WatchMacAddress, forKey: WatchConst.WatchSettingInfoRegistData.WatchMacAddress)
        // 電話が通知設定中かどうか
        coder.encode(self.IsCallNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsCallNotificationSettings)
        // SMSが通知設定中かどうか
        coder.encode(self.IsSmsNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsSmsNotificationSettings)
        // LINEが通知設定中かどうか
        coder.encode(self.IsLineNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsLineNotificationSettings)
        // qqが通知設定中かどうか
        coder.encode(self.IsQqNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsQqNotificationSettings)
        // weChatが通知設定中かどうか
        coder.encode(self.IsWeChatNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsWeChatNotificationSettings)
        // faceBookが通知設定中かどうか
        coder.encode(self.IsFaceBookNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsFaceBookNotificationSettings)
        // twitterが通知設定中かどうか
        coder.encode(self.IsTwitterNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsTwitterNotificationSettings)
        // skypeが通知設定中かどうか
        coder.encode(self.IsSkypeNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsSkypeNotificationSettings)
        //instagramが通知設定中かどうか
        coder.encode(self.IsInstagramNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsInstagramNotificationSettings)
        //whatsAppが通知設定中かどうか
        coder.encode(self.IsWhatsAppNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsWhatsAppNotificationSettings)
        //kakaoTalkが通知設定中かどうか
        coder.encode(self.IsKakaoTalkNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsKakaoTalkNotificationSettings)
        //gmailが通知設定中かどうか
        coder.encode(self.IsGmailNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsGmailNotificationSettings)
        //messengerが通知設定中かどうか
        coder.encode(self.IsMessengerNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsMessengerNotificationSettings)
        //othersが通知設定中かどうか
        coder.encode(self.IsOthersNotificationSettings, forKey: WatchConst.WatchSettingInfoRegistData.IsOthersNotificationSettings)
        // 血圧測定するかどうか
        coder.encode(self.BloodPressureMeasure, forKey: WatchConst.WatchSettingInfoRegistData.BloodPressureMeasure)
        // SpO2測定するかどうか
        coder.encode(self.SpO2Measure, forKey: WatchConst.WatchSettingInfoRegistData.SpO2Measure)
        // 自動測定 自動計測
        coder.encode(self.MeasurementInterval, forKey: WatchConst.WatchSettingInfoRegistData.MeasurementInterval)
        // 歩数測定 送信計測
        coder.encode(self.StepSendInterval, forKey: WatchConst.WatchSettingInfoRegistData.StepSendInterval)
        // 歩幅
        coder.encode(self.StepLength, forKey: WatchConst.WatchSettingInfoRegistData.StepLength)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "WatchInfoSettingData" , functionName: #function , message: "")
    }
}
