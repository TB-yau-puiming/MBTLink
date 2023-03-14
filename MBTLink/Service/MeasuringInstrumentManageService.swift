//
// MeasuringInstrumentManage.swift
// 測定機器管理サービス
//
//  MBTLink
//

import Foundation

final class MeasuringInstrumentManageService : NSObject{
    // MARK: - Public変数
    /// BLE関連サービス
    public var BleService : BleService!
    /// 測定機器設定情報
    public var MeasuringInstrumentSettingInfo : MeasuringInstrumentSettingInfoDto
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( MeasuringInstrumentManageService.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    
    // MARK: - Public Methods
    /// イニシャライザ
    init(deviceName : String){
        self.MeasuringInstrumentSettingInfo = MeasuringInstrumentSettingInfoDto()
        self.MeasuringInstrumentSettingInfo.DeviceName = deviceName
    }
    
    // 測定機器設定情報登録
    func SaveMeasuringInstrumentSettingData() {
        
        let key = self.getMeasuringInstrumentSettingDataKey()
        
        let measuringInstrumentSettingData = MeasuringInstrumentSettingData(
            isSettings: self.MeasuringInstrumentSettingInfo.IsSettings,
            deviceName: self.MeasuringInstrumentSettingInfo.DeviceName,
            serialNumber: self.MeasuringInstrumentSettingInfo.SerialNumber,
            uuid: self.MeasuringInstrumentSettingInfo.Uuid,
            measuringInterval: MeasuringInstrumentSettingInfo.MeasuringInterval,
            deviceNamePairing: self.MeasuringInstrumentSettingInfo.DeviceNamePairing)
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: measuringInstrumentSettingData,requiringSecureCoding: false)
            else {
                return
        }
        UserDefaults.standard.set(data, forKey: key)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // 測定機器設定情報読み出し
    func LoadMeasuringInstrumentSettingData()  {
        let key = self.getMeasuringInstrumentSettingDataKey()
        
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return
        }
        
        if let settingData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? MeasuringInstrumentSettingData {
            
            //設定中かどうか
            self.MeasuringInstrumentSettingInfo.IsSettings = settingData.IsSettings
            // デバイス名
            self.MeasuringInstrumentSettingInfo.DeviceName = settingData.DeviceName
            // シリアルナンバー
            self.MeasuringInstrumentSettingInfo.SerialNumber = settingData.SerialNumber
            // UUID
            self.MeasuringInstrumentSettingInfo.Uuid = settingData.Uuid
            // 測定間隔
            self.MeasuringInstrumentSettingInfo.MeasuringInterval = settingData.MeasuringInterval
            // 接続中デバイス名
            self.MeasuringInstrumentSettingInfo.DeviceNamePairing = settingData.deviceNamePairing
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // 測定機器設定削除
    func RemoveMeasuringInstrumentSettingData() {
        let key = self.getMeasuringInstrumentSettingDataKey()
        
        UserDefaults.standard.removeObject(forKey: key)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Private Methods
    //測定機器設定登録キー取得
    private func getMeasuringInstrumentSettingDataKey() -> String {
        var key : String = ""
        
        switch self.MeasuringInstrumentSettingInfo.DeviceName{
        case EnvSensorConst.DeviceName:
            // 環境センサー
            key = EnvSensorConst.MeasuringInstrumentSettingData
            break
        case WeightScaleConst.DeviceName:
            // 体重計
            key = WeightScaleConst.MeasuringInstrumentSettingData
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 血圧計
            key = BloodPressuresMonitorConst.MeasuringInstrumentSettingData
            break
        case ThermometerConst.DeviceName:
            // 体温計
            key = ThermometerConst.MeasuringInstrumentSettingData
            break
        case PulseOximeterConst.DeviceName:
            // パルスオキシメータ
            key = PulseOximeterConst.MeasuringInstrumentSettingData
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "key : \(key)")
        return key
    }
}
