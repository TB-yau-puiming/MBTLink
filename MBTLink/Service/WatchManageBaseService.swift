//
// WatchManageBaseService.swift
// ウォッチ管理ベースクラスサービス
//
//  MBTLink
//

import Foundation

class WatchManageBaseService : NSObject{
    // MARK: - Public変数
    /// ウォッチ スキャンデバイスタイマー
    public var WatchScanDeviceTimer : Timer!
    /// ウォッチ設定情報
    public var WatchSettingInfo : WatchDto.WatchSettingInfo
    
    // MARK: - Private変数
    /// クラス名
    //internal var className = ""
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    /// クラス名
    private let className = String(String(describing: ( WatchManageBaseService.self)).split(separator: "-")[0])
    
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        self.WatchSettingInfo = WatchDto.WatchSettingInfo()
    }
    
    /// デバイスがLANCEBANDかどうか
    func IsLanceband() -> Bool{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        if WatchConst.WatchDeviceName.Lanceband2.contains( WatchSettingInfo.WatchDeviceName!){
            return true
        }
        else if WatchConst.WatchDeviceName.Lanceband3.contains( WatchSettingInfo.WatchDeviceName!){
            return true
        }
     
        return false
    }
    /// ウォッチスキャンデバイスタイマーStart
    func StartWatchScanDeviceTimer(){
        let message = "watch scan device timer"
        //let message = "ウォッチ スキャンデバイスタイマー"
        //CommonUtil.Print(className: self.className, message: message + "Start")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: message + "Start")
        if self.WatchScanDeviceTimer == nil {
            // タイマー設定
            self.WatchScanDeviceTimer = Timer.scheduledTimer(timeInterval: WatchConst.TimeInterval.WatchScanDevice, target: self, selector: #selector(watchScanDevice), userInfo: nil, repeats: true)
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: message + "Setted")
            //CommonUtil.Print(className: self.className, message: message + "Setted")
            
            // タイマーStart
            self.WatchScanDeviceTimer.fire()
        }
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }

    /// ウォッチスキャンデバイスタイマーStop
    func StopWatchScanDeviceTimer(){
        let message = "watch scan device timer"
        //let message = "ウォッチスキャンデバイスタイマー"
        //CommonUtil.Print(className: self.className, message: message +  "Stop")
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: message + "Stop")
        if self.WatchScanDeviceTimer != nil && self.WatchScanDeviceTimer.isValid {
            // タイマーを停止
            self.WatchScanDeviceTimer.invalidate()
            self.WatchScanDeviceTimer = nil
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: message + "Stopped")
            //CommonUtil.Print(className: self.className, message: message +  "Stop完了")
        }
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    // ウォッチ設定情報登録
    func SaveWatchSettingData(deviceNameKey : String) {
        
        let key = "\(WatchConst.WatchSettingInfoRegistData.WatchSettingData)_\(deviceNameKey)"
        
        let watchSettingData = WatchSettingData(
            isWatchSettings: self.WatchSettingInfo.IsWatchSettings,
            watchDeviceName: self.WatchSettingInfo.WatchDeviceName,
            watchMacAddress: self.WatchSettingInfo.WatchMacAddress,
            isCallNotificationSettings:self.WatchSettingInfo.IsCallNotificationSettings,
            isSmsNotificationSettings: self.WatchSettingInfo.IsSmsNotificationSettings,
            isLineNotificationSettings: self.WatchSettingInfo.IsLineNotificationSettings,
            IsQqNotificationSettings: self.WatchSettingInfo.IsQqNotificationSettings,
            IsWeChatNotificationSettings: self.WatchSettingInfo.IsWeChatNotificationSettings,
            IsFaceBookNotificationSettings: self.WatchSettingInfo.IsFaceBookNotificationSettings,
            IsTwitterNotificationSettings: self.WatchSettingInfo.IsTwitterNotificationSettings,
            IsSkypeNotificationSettings: self.WatchSettingInfo.IsSkypeNotificationSettings,
            IsInstagramNotificationSettings: self.WatchSettingInfo.IsInstagramNotificationSettings,
            IsWhatsAppNotificationSettings: self.WatchSettingInfo.IsWhatsAppNotificationSettings,
            IsKakaoTalkNotificationSettings: self.WatchSettingInfo.IsKakaoTalkNotificationSettings,
            IsGmailNotificationSettings: self.WatchSettingInfo.IsGmailNotificationSettings,
            IsMessengerNotificationSettings: self.WatchSettingInfo.IsMessengerNotificationSettings,
            IsOthersNotificationSettings: self.WatchSettingInfo.IsOthersNotificationSettings, BloodPressureMeasure: self.WatchSettingInfo.BloodPressureMeasure, SpO2Measure: self.WatchSettingInfo.SpO2Measure,
            measurementInterval: self.WatchSettingInfo.MeasurementInterval,
            stepSendInterval: self.WatchSettingInfo.StepSendInterval,
            stepLength: self.WatchSettingInfo.StepLength
        )
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: watchSettingData,requiringSecureCoding: false)
            else {
                return
        }
        UserDefaults.standard.set(data, forKey: key)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    // ウォッチ設定情報読み出し
    func LoadWatchSettingData(deviceNameKey : String) {
        let key = "\(WatchConst.WatchSettingInfoRegistData.WatchSettingData)_\(deviceNameKey)"
        
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return
        }
        
        if let settingData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? WatchSettingData {
            
            // ウォッチ設定中かどうか
            self.WatchSettingInfo.IsWatchSettings = settingData.IsWatchSettings
            // デバイス名
            self.WatchSettingInfo.WatchDeviceName = settingData.WatchDeviceName
            // MACアドレス
            self.WatchSettingInfo.WatchMacAddress = settingData.WatchMacAddress
            // 電話が通知設定中かどうか
            self.WatchSettingInfo.IsCallNotificationSettings = settingData.IsCallNotificationSettings
            // SMSが通知設定中かどうか
            self.WatchSettingInfo.IsSmsNotificationSettings = settingData.IsSmsNotificationSettings
            // LINEが通知設定中かどうか
            self.WatchSettingInfo.IsLineNotificationSettings = settingData.IsLineNotificationSettings
            // qqが通知設定中かどうか
            self.WatchSettingInfo.IsQqNotificationSettings = settingData.IsQqNotificationSettings
            // weChatが通知設定中かどうか
            self.WatchSettingInfo.IsWeChatNotificationSettings = settingData.IsWeChatNotificationSettings
            // faceBookが通知設定中かどうか
            self.WatchSettingInfo.IsFaceBookNotificationSettings = settingData.IsFaceBookNotificationSettings
            // twitterが通知設定中かどうか
            self.WatchSettingInfo.IsTwitterNotificationSettings = settingData.IsTwitterNotificationSettings
            // skypeが通知設定中かどうか
            self.WatchSettingInfo.IsSkypeNotificationSettings = settingData.IsSkypeNotificationSettings
            // instagramが通知設定中かどうか
            self.WatchSettingInfo.IsInstagramNotificationSettings = settingData.IsInstagramNotificationSettings
            // whatsAppが通知設定中かどうか
            self.WatchSettingInfo.IsWhatsAppNotificationSettings = settingData.IsWhatsAppNotificationSettings
            // kakaoTalkが通知設定中かどうか
            self.WatchSettingInfo.IsKakaoTalkNotificationSettings = settingData.IsKakaoTalkNotificationSettings
            // gmailが通知設定中かどうか
            self.WatchSettingInfo.IsGmailNotificationSettings = settingData.IsGmailNotificationSettings
            // messengerが通知設定中かどうか
            self.WatchSettingInfo.IsMessengerNotificationSettings = settingData.IsMessengerNotificationSettings
            // othersが通知設定中かどうか
            self.WatchSettingInfo.IsOthersNotificationSettings = settingData.IsOthersNotificationSettings
            /// 血圧測定するかどうか
            self.WatchSettingInfo.BloodPressureMeasure = settingData.BloodPressureMeasure
            /// SpO2測定するかどうか
            self.WatchSettingInfo.SpO2Measure = settingData.SpO2Measure
            // 自動計測 測定間隔
            self.WatchSettingInfo.MeasurementInterval = settingData.MeasurementInterval
            // 歩数計測 送信間隔
            self.WatchSettingInfo.StepSendInterval = settingData.StepSendInterval
            // 歩幅
            self.WatchSettingInfo.StepLength = settingData.StepLength
            /// テスト用ログ出力 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            /*
            CommonUtil.Print(className: self.className, message:"          ===UserDefaults読み出し ログ出力開始===")
            CommonUtil.Print(className: self.className, message:"            ウォッチ設定中かどうか:\(settingData.IsWatchSettings)")
            CommonUtil.Print(className: self.className, message:"            デバイス名:\(String(describing: settingData.WatchDeviceName))")
            CommonUtil.Print(className: self.className, message:"            電話が通知設定中かどうか:\(settingData.IsCallNotificationSettings)")
            CommonUtil.Print(className: self.className, message:"            SMSが通知設定中かどうか:\(settingData.IsSmsNotificationSettings)")
            CommonUtil.Print(className: self.className, message:"            LINEが通知設定中かどうか:\(settingData.IsLineNotificationSettings)")
            CommonUtil.Print(className: self.className, message:"            血圧測定するかどうか:\(settingData.BloodPressureMeasure)")
            CommonUtil.Print(className: self.className, message:"            SpO2測定するかどうか:\(settingData.SpO2Measure)")
            CommonUtil.Print(className: self.className, message:"            自動計測 測定間隔:\(settingData.MeasurementInterval)")
            CommonUtil.Print(className: self.className, message:"            歩数計測 送信間隔:\(settingData.StepSendInterval)")
            CommonUtil.Print(className: self.className, message:"            歩幅:\(settingData.StepLength)")
            CommonUtil.Print(className: self.className, message:"          ===UserDefaults読み出し ログ出力終了===")
             */
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    // ウォッチ設定削除
    func RemoveWatchSettingData() {
        let key = "\(WatchConst.WatchSettingInfoRegistData.WatchSettingData)_\(self.WatchSettingInfo.WatchDeviceName!)"
        
        UserDefaults.standard.removeObject(forKey: key)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    // MARK: - Private Methods
    //ウォッチ スキャンデバイス
    @objc internal func watchScanDevice() {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //継承先で実装
    }
}
