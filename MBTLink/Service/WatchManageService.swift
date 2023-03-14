//
// WatchManageService.swift
// LANCEBAND2,3管理サービス
//
//  MBTLink
//

import Foundation

final class WatchManageService : WatchManageBaseService {
    
    // MARK: - Public変数
    /// YCBle関連サービス
    public var WatchBleService : YCBleService!
    /// ウォッチ 履歴データ取得・歩数タイマー
    public var WatchSyncHistoryStepTimer: Timer!
    /// ウォッチ 履歴データ取得・脈拍タイマー
    public var WatchSyncHistoryHeartTimer: Timer!
    /// ウォッチ 履歴データ取得・血圧タイマー
    public var WatchSyncHistoryBloodTimer: Timer!
    /// ウォッチ 履歴データ取得・総合タイマー
    public var WatchSyncHistoryCombinedTimer: Timer!
    /// MACアドレス取得タイマー
    public var GetMacAddressTimer : Timer!
    
    /// クラス名
    private let className = String(String(describing: ( WatchManageService.self)).split(separator: "-")[0])
    
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
        self.WatchBleService = YCBleService()
        //self.WatchSettingInfo = WatchDto.WatchSettingInfo()
    }
    
    /// LANCEBAND種類取得
    func GetLancebandType() -> String{
        var ret : String = ""

        if self.WatchSettingInfo.WatchDeviceName!.contains(WatchConst.WatchDeviceName.Lanceband2){
            // LANCEBAND2
            ret = WatchConst.LancebandType.Lanceband2

        }
        else if self.WatchSettingInfo.WatchDeviceName!.contains(WatchConst.WatchDeviceName.Lanceband3){
            // LANCEBAND3
            ret = WatchConst.LancebandType.Lanceband3
        }
        else {
            // その他
            ret = WatchConst.LancebandType.Other
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// ウォッチ歩数履歴データ取得・タイマーStart
    func StartWatchSyncHistoryStepTimer(){
        let message = "ウォッチ歩数履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message + "Start")
        
        if self.WatchSyncHistoryStepTimer == nil{
            // タイマー設定
            self.WatchSyncHistoryStepTimer = Timer.scheduledTimer(timeInterval: WatchConst.TimeInterval.WatchSyncHistoryStep, target: self, selector: #selector(watchSyncHistoryStep), userInfo: nil, repeats: true)
            
            CommonUtil.Print(className: self.className, message: message + "設定完了")
            
            // タイマーStart
            self.WatchSyncHistoryStepTimer.fire()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ウォッチ脈拍履歴データ取得・タイマーStart
    func StartWatchSyncHistoryHeatTimer(){
        let message = "ウォッチ脈拍履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message + "Start")
        
        if self.WatchSyncHistoryHeartTimer == nil{
            // タイマー設定
            self.WatchSyncHistoryHeartTimer = Timer.scheduledTimer(timeInterval: Double(WatchSettingInfo.MeasurementInterval*60), target: self, selector: #selector(watchSyncHistoryHeart), userInfo: nil, repeats: true)
            
            CommonUtil.Print(className: self.className, message: message + "設定完了")
            
            // タイマーStart
            self.WatchSyncHistoryHeartTimer.fire()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ウォッチ血圧履歴データ取得・タイマーStart
    func StartWatchSyncHistoryBloodTimer(){
        let message = "ウォッチ血圧履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message +  "Start")
        
        if self.WatchSyncHistoryBloodTimer == nil{
            // タイマー設定
            self.WatchSyncHistoryBloodTimer = Timer.scheduledTimer(timeInterval: Double(WatchSettingInfo.MeasurementInterval*60), target: self, selector: #selector(watchSyncHistoryBlood), userInfo: nil, repeats: true)
            
            CommonUtil.Print(className: self.className, message: message +  "設定完了")
            
            // タイマーStart
            self.WatchSyncHistoryBloodTimer.fire()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ウォッチ総合履歴データ取得・タイマーStart
    func StartWatchSyncHistoryCombinedTimer(){
        let message = "ウォッチ総合履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message +  "Start")
        
        if self.WatchSyncHistoryCombinedTimer == nil{
            // タイマー設定
            self.WatchSyncHistoryCombinedTimer = Timer.scheduledTimer(timeInterval: Double(WatchSettingInfo.MeasurementInterval*60), target: self, selector: #selector(watchSyncHistoryCombined), userInfo: nil, repeats: true)
            
            CommonUtil.Print(className: self.className, message: message +  "設定完了")
            
            // タイマーStart
            self.WatchSyncHistoryCombinedTimer.fire()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// MACアドレス取得タイマーStart
    func StartGetMacAddressTimer(){
        if self.GetMacAddressTimer == nil{
            // タイマー設定
            self.GetMacAddressTimer = Timer.scheduledTimer(timeInterval: WatchConst.TimeInterval.GetMacAddress, target: self, selector: #selector(getMacAddress), userInfo: nil, repeats: true)
            // タイマーStart
            self.GetMacAddressTimer.fire()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //ウォッチ歩数履歴データ取得・タイマーStop
    func StopWatchSyncHistoryStepTimer(){
        let message = "ウォッチ歩数履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message +  "Stop")
        
        if self.WatchSyncHistoryStepTimer != nil && self.WatchSyncHistoryStepTimer.isValid {
            // タイマーを停止
            self.WatchSyncHistoryStepTimer.invalidate()
            self.WatchSyncHistoryStepTimer = nil
            
            CommonUtil.Print(className: self.className, message: message +  "Stop完了")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //ウォッチ脈拍履歴データ取得・タイマーStop
    func StopWatchSyncHistoryHeatTimer(){
        let message = "ウォッチ脈拍履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message +  "Stop")
        
        if self.WatchSyncHistoryHeartTimer != nil && self.WatchSyncHistoryHeartTimer.isValid {
            // タイマーを停止
            self.WatchSyncHistoryHeartTimer.invalidate()
            self.WatchSyncHistoryHeartTimer = nil
            
            CommonUtil.Print(className: self.className, message: message +  "Stop完了")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //ウォッチ血圧履歴データ取得・タイマーStop
    func StopWatchSyncHistoryBloodTimer(){
        let message = "ウォッチ血圧履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message +  "Stop")
        
        if self.WatchSyncHistoryBloodTimer != nil && self.WatchSyncHistoryBloodTimer.isValid {
            // タイマーを停止
            self.WatchSyncHistoryBloodTimer.invalidate()
            self.WatchSyncHistoryBloodTimer = nil
            
            CommonUtil.Print(className: self.className, message: message +  "Stop完了")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //ウォッチ総合履歴データ取得・タイマーStop
    func StopWatchSyncHistoryCombinedTimer(){
        let message = "ウォッチ総合履歴データ取得タイマー"
        CommonUtil.Print(className: self.className, message: message +  "Stop")
        
        if self.WatchSyncHistoryCombinedTimer != nil && self.WatchSyncHistoryCombinedTimer.isValid {
            // タイマーを停止
            self.WatchSyncHistoryCombinedTimer.invalidate()
            self.WatchSyncHistoryCombinedTimer = nil
            
            CommonUtil.Print(className: self.className, message: message +  "Stop完了")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// MACアドレス取得タイマーStop
    func StopGetMacAddressTimer(){
        if self.GetMacAddressTimer != nil && self.GetMacAddressTimer.isValid {
            // タイマー停止
            self.GetMacAddressTimer.invalidate()
            self.GetMacAddressTimer = nil
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Private Methods
    //ウォッチ スキャンデバイス
    @objc internal override func watchScanDevice() {
        self.WatchBleService.StartBleScan()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // ウォッチ 歩数履歴データ取得
    @objc func watchSyncHistoryStep() {
        // 歩数履歴データ取得
        self.WatchBleService.SyncDataHistroy(historyType: YCBleService.SyncDataHistoryType.Step.rawValue)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // ウォッチ 脈拍履歴データ取得
    @objc func watchSyncHistoryHeart() {
        // 脈拍履歴データ取得
        self.WatchBleService.SyncDataHistroy(historyType: YCBleService.SyncDataHistoryType.Heart.rawValue)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ウォッチ 血圧履歴データ取得
    @objc func watchSyncHistoryBlood() {
        // 血圧履歴データ取得
        self.WatchBleService.SyncDataHistroy(historyType: YCBleService.SyncDataHistoryType.Blood.rawValue)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ウォッチ 総合履歴データ取得
    @objc func watchSyncHistoryCombined() {
        // 総合履歴データ取得
        self.WatchBleService.SyncDataHistroy(historyType: YCBleService.SyncDataHistoryType.Combined.rawValue)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// MACアドレス取得
    @objc func getMacAddress() {
        self.WatchBleService.GetDevMac()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
