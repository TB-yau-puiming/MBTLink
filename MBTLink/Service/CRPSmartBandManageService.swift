//
// CRPSmartBandManageService.swift
// CRPSmartBand管理サービス
//
// MBTLink
//

import Foundation

final class CRPSmartBandManageService : WatchManageBaseService{
    // MARK: - enum
    /// ステータス
    enum Status : Int{
        /// 未完
        case Incomplete = 0
        /// 処理中
//        case Prossesing = 1
        /// 完了
        case Complete = 2
    }
    // MARK: - Public変数
    /// CRPSmartBandBle関連サービス
    public var WatchBleService : CRPSmartBandBleService!
    /// ウォッチ 測定結果データ取得タイマー
    public var WatchMeasurementResultDataTimer: Timer!
    /// 測定結果データ取得ステータス
    public var MeasurementResultDataStatus : Status = .Incomplete
    /// 測定結果データ取得・処理中・接続中カウント
    public var ProssesingConnectCount : Int = 0
    /// 測定結果データ取得・処理中・接続中リトライカウント
    public var ProssesingConnectRetryCount : Int = 0
    /// 測定結果データ取得・未完・未接続リトライカウント
    public var IncompleteDisconnectRetryCount : Int = 0
    /// クラス名
    private let className = String(String(describing: ( CRPSmartBandManageService.self)).split(separator: "-")[0])
    
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
        self.WatchBleService = CRPSmartBandBleService()
    }
    
    // ウォッチ 測定結果データ取得
    func WatchMeasurementResultData() {
//        self.MeasurementResultDataStatus = .Prossesing
        // 心拍数測定結果データ取得
        DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 30) {
        self.WatchBleService.SetStartSingleHR()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // DeviceNameKey取得
    func GetDeviceNameKey()-> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return "\(self.WatchSettingInfo.WatchDeviceName ?? "") \(self.WatchSettingInfo.WatchMacAddress ?? "")"
    }

    // MARK: - Private Methods
    //ウォッチ スキャンデバイス
    @objc internal override func watchScanDevice() {
        self.WatchBleService.StartBleScan()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
