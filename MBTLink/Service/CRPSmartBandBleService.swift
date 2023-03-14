//
// CRPSmartBandBleService.swift
// CRPSmartBandBle関連サービス
//
// MBTLink
//

import Foundation
import CRPSmartBand

// MARK: - プロトコル
protocol CRPSmartBandBleDelegate {
    /// BLE検出可能
    func blePowerOn()
    /// ウォッチスキャン成功
    func successToScanWatch(deviceNameKey: String?, discoverys : [CRPDiscovery])
    /// ウォッチ接続成功
    func successToWatchConnect(discovery : CRPDiscovery)
    /// 心拍数データ取得完了
    func getHeartRateDataComplete(deviceNameKey : String, heartRate: Int)
    /// 血圧データ取得完了
    func getBloodDataComplete(deviceNameKey : String, heartRate: Int, sbp: Int, dbp: Int)
    /// SPO2データ取得完了
    func getSpo2DataComplete(deviceNameKey : String, o2: Int)
    /// データ取得完了
    func getDataCycleComplete(deviceNameKey : String)
}

final class CRPSmartBandBleService: NSObject {
    
    // MARK: - デリゲート
    var delegate : CRPSmartBandBleDelegate?

    // MARK: - Public変数
    /// 血圧自動測定判断フラグ
    public static var BloodPressureMeasure : Bool = true
    /// SpO2自動測定判断フラグ
    public static var SpO2Measure : Bool = true
    /// 心拍数測定フラグ
    public static var HrFlag : Bool = false
    /// 血圧測定フラグ
    public static var BpFlag : Bool = false
    /// Sp02測定フラグ
    public static var SpO2Flag : Bool = false
    /// 血圧測定タイマー
    public var BpTimer : Timer!
    /// SpO2測定タイマー
    public var SpO2Timer : Timer!
    /// データ送信タイマー
    public var SendDataTimer : Timer!
    
    // MARK: - Private変数
    /// ウォッチ設定TableView
    private var watchSettingTvc : WatchSettingCRPSmartBandTableViewController!
    /// メソッド実行数カウント
    private var getDeviceNameKeyCount : Int = 30
    private var getConnectDiscoveryCount : Int = 10
    /// クラス名
    private let className = String(String(describing: ( CRPSmartBandBleService.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// CRPSmartBandSDK
    private var crpSmartBand : CRPSmartBandSDK!
    ///デバイス名
    private var deviceName : String?
    ///MACアドレス
    private var macAddress : String?
    /// 接続先の機器
    private var connectDiscovery: CRPDiscovery?
    /// ウォッチ設定中かどうか
    private var isWatchSetting : Bool = false
    /// ファームウェアバージョン
    private var firmwareVersion : String = ""
    /// ウォッチのバッテリーレベル
    private var batteryLevel : String = ""
    /// 24時間心拍数データ
    private var heartRate24 : [Int] = []
    /// 昨日の24時間心拍数データ
    private var yesterdayHeartRate24 : [Int] = []
    /// 24時間歩数データ
    private var step24 : [Int] = []
    /// 昨日の24時間歩数データ
    private var yesterdayStep24 : [Int] = []
    /// 今日の睡眠データ
    private var todaySleep : [[String : String]] = []
    /// 昨日の睡眠履歴データ
    private var yesterdaySleep : [SleepModel] = []
    /// データコミュニケーションサービス
    private let dcService = DataCommunicationService()
    
    /// 再接続検知用フラグ
    private var reconnectFlg : Bool = false
    


    
    // MARK: - enum
    /// 接続ステータス  ログ送信 20220713対応中
    enum ConnectStatus : String{
        case Connected = "Connected"
        case Disconnect = "Disconnect"
    }
    
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
        self.crpSmartBand = CRPSmartBandSDK.sharedInstance
    }
    
    ///デイニシャライザ
    deinit {
    }
    /// デバイス名設定
    func SetDeviceName(value : String?){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.deviceName = value
    }
    /// デバイス名取得
    func GetDeviceName() -> String?{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.deviceName
    }
    /// MACアドレス設定
    func SetMacAddress(value : String?){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.macAddress = value
    }
    /// MACアドレス取得
    func GetMacAddress() -> String?{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.macAddress
    }
    /// デバイス名キー取得
    func GetDeviceNameKey()-> String?{
        if getDeviceNameKeyCount == 30{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            getDeviceNameKeyCount = 0
        }else{
            getDeviceNameKeyCount += 1
        }
        if let name = self.deviceName,let macAddress = self.macAddress{
            return "\(name) \(macAddress)"
        }
        
        return ""
    }
    /// ウォッチ設定状態設定
    func IsWatchSetting(bool : Bool){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.isWatchSetting = bool
    }
    /// 接続先の機器設定
    func SetConnectDiscovery(discovery :CRPDiscovery?){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.connectDiscovery = discovery
    }
    /// 接続先の機器取得
    func GetConnectDiscovery()->CRPDiscovery?{
        if getConnectDiscoveryCount == 10{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            getConnectDiscoveryCount = 0
        }else{
            getConnectDiscoveryCount += 1
        }
        return self.connectDiscovery
    }
    /// BLE接続のセットアップ
    func SetupBluetoothService() {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.crpSmartBand.delegate = self
    }
    /// ファームウェアバージョン設定
    func ResetFirmwareVersion() {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.firmwareVersion = ""
    }
    /// ファームウェアバージョン取得
    func GetFirmwareVersion() -> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.firmwareVersion
    }
    /// バッテリーレベル取得
    func GetBatteryLevel() -> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.batteryLevel
    }
    /// 24時間心拍数取得
    func Get24HeartRate() -> [Int]{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.heartRate24
    }
    
    /// 24時間心拍数取得
    func GetYesterday24HeartRate() -> [Int]{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.yesterdayHeartRate24
    }
    
    /// 24時間歩数取得
    func Get24Step() -> [Int]{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.step24
    }
    /// 昨日の24時間歩数取得
    func GetYesterday24Step() -> [Int]{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.yesterdayStep24
    }
    /// 今日の睡眠取得
    func GetTodaySleepData() -> [[String : String]]{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.todaySleep
    }
    /// 昨日の睡眠取得
    func GetYesterdaySleepData() -> [SleepModel]{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.yesterdaySleep
    }
    
    /// スキャン開始
    func StartBleScan() {
        
        // 機器を検出
        if self.connectDiscovery == nil {
            
            //CommonUtil.Print(className: self.className, message: "スキャン開始")
            
            self.crpSmartBand.scan(5, progressHandler: { (newDiscoverys) in
                //CommonUtil.Print(className: self.className, message: "スキャン成功")
                
                let discoverys : [CRPDiscovery] = newDiscoverys
                
                self.delegate?.successToScanWatch(deviceNameKey: self.GetDeviceNameKey(), discoverys: discoverys)
                
            }) { (newDiscoverys, err) in
                //CommonUtil.Print(className: self.className, message: "スキャン失敗　error = \(err)")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to scan error = \(err)")
                LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to scan error = \(err)")
            }
        }
        else{
            self.ConnectDiscovery()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // スキャン停止
    func StopBleScan() {
        self.crpSmartBand.interruptScan()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 機器に接続
    func ConnectDiscovery() {
        guard let connectDiscovery = self.connectDiscovery else {
            // 失敗処理
            return
        }
        
        let name : String = (self.connectDiscovery?.localName)!
        let macAddress : String = (self.connectDiscovery?.mac)!
        
        //CommonUtil.Print(className: self.className, message: "デバイス接続 デバイス名：\(name) MACアドレス：\(macAddress)")
        self.SetupBluetoothService()
        self.crpSmartBand.connet(connectDiscovery)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "device connected device name：\(name) MAC address：\(macAddress)")
    }
    /// デバイス切断
    func Disconnect(){
        //CommonUtil.Print(className: self.className, message: "デバイス切断  デバイス：\(self.GetDeviceNameKey()!)")
        
        self.SetupBluetoothService()
        self.crpSmartBand.disConnet()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "device：\(self.GetDeviceNameKey()!)")
    }
    
    /// デバイス再接続
    func ReConnect(){
        //CommonUtil.Print(className: self.className, message: "デバイス再接続  デバイス：\(self.GetDeviceNameKey()!)")
        self.crpSmartBand.reConnet()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "reconnect device device：\(self.GetDeviceNameKey()!)")
    }
    /// デバイス登録解除
    func UnbindDevice(){
        CommonUtil.Print(className: self.className, message: "デバイス登録解除  デバイス：\(self.GetDeviceNameKey()!)")

        /// 通知設定を初期化
        let notificationArray : [NotificationType] = []
        self.crpSmartBand.setNotification(notificationArray)
        
        self.SetupBluetoothService()
        self.crpSmartBand.remove { (state, err) in
            
            CommonUtil.Print(className: self.className, message: "デバイス登録解除成功  デバイス：\(self.GetDeviceNameKey()!)")
            
            self.deviceName = ""
            self.macAddress = ""
            self.connectDiscovery = nil
            self.isWatchSetting = false
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// 心拍数計測データ取得開始
    func SetStartSingleHR(){
        //CommonUtil.Print(className: self.className, message: "心拍数計測データ取得開始  デバイス：\(self.GetDeviceNameKey()!)")
        CRPSmartBandBleService.HrFlag = true
        //        self.SetupBluetoothService()
        //        self.crpSmartBand.setStartSingleHR()
        ///要望で24時間心拍の配列から心拍を抽出して使う
        var getTime : String = ""
        if CRPSmartBandService.heartRateGetDate == ""{
            let time = (DateUtil.GetDateFormatConvert(format: "mm"))
            let timeInt = Int(time) ?? 0
            var fixedTime = String(Int(floor(Double(timeInt/5))*5))
            if fixedTime == "0"{
                fixedTime = "00"
            }
            if fixedTime == "5"{
                fixedTime = "05"
            }
            let date = (DateUtil.GetDateFormatConvert(format: "yyyyMMddHH"))
            let getdate = date + fixedTime + "00"
            getTime = getdate
            //getTime = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        }else {
            getTime = CRPSmartBandService.heartRateGetDate
        }
        let timeInHHmm = DateUtil.getFormattedDateStringHHmm(dateString: getTime)
        let timeInHHmmStr = String(describing:timeInHHmm)
        var arrNum : Int = 0
        var heartRate : Int = 0
        var HeartRate24Data = self.Get24HeartRate()
        //取得時刻が00:00:00~00:04:59かどうかをチェック
        //条件が真の時、配列の最後のデータをとる
        if Int(timeInHHmm) ?? 0 < 5{
            //配列は[0]から始まるのため、arrNum-1
            arrNum = 288-1
            //取得時刻が00:00:00~00:04:59は昨日のデータを使用
            HeartRate24Data = self.GetYesterday24HeartRate()
        }else{
            let timeToMin = (Int(timeInHHmmStr.prefix(2)) ?? 0)*60 + (Int(timeInHHmmStr.suffix(2)) ?? 0)
            //配列は[0]から始まるのため、arrNum-1
            arrNum = Int(floor(Double(timeToMin/5)))-1
        }
        // 配列の[0]から[287]までの範囲以外ははじく
        if arrNum < 0 || arrNum > 287{
            self.delegate?.getHeartRateDataComplete(deviceNameKey: self.GetDeviceNameKey()!, heartRate: heartRate)
        }
        if HeartRate24Data == []{
            if Int(timeInHHmm) ?? 0 < 5{
                GetYesterdayHeartRate()
            }else{
                GetHeartRate()
            }
            DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 5) {
                if Int(timeInHHmm) ?? 0 < 5{
                    HeartRate24Data = self.GetYesterday24HeartRate()
                }else{
                    HeartRate24Data = self.Get24HeartRate()
                }
                heartRate = HeartRate24Data[arrNum]
                self.delegate?.getHeartRateDataComplete(deviceNameKey: self.GetDeviceNameKey()!, heartRate: heartRate)
            }
        }else{
            heartRate = HeartRate24Data[arrNum]
            if heartRate == 0{
                if Int(timeInHHmm) ?? 0 < 5{
                    GetYesterdayHeartRate()
                }else{
                    GetHeartRate()
                }
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 5) {
                    if Int(timeInHHmm) ?? 0 < 5{
                        HeartRate24Data = self.GetYesterday24HeartRate()
                    }else{
                        HeartRate24Data = self.Get24HeartRate()
                    }
                    heartRate = HeartRate24Data[arrNum]
                }
            }
            self.delegate?.getHeartRateDataComplete(deviceNameKey: self.GetDeviceNameKey()!, heartRate: heartRate)
            }
        //GetHeartRate()
        //let getTime = (DateUtil.GetDateFormatConvert(format: "HHmm"))
        //let timeToMin = (Int(getTime.prefix(2)) ?? 0)*60 + (Int(getTime.suffix(2)) ?? 0)
        //let arrNum = Int(floor(Double(timeToMin/5)))
        //DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 5) {
            //let HeartRate24Data = self.Get24HeartRate()
            //let heartRate = HeartRate24Data[arrNum-1]
            //print(HeartRate24Data)
            //print(HeartRate24Data[arrNum-1])
            //self.delegate?.getHeartRateDataComplete(deviceNameKey: self.GetDeviceNameKey()!, heartRate: heartRate)
            //TopViewController().getHeartRateDataComplete(deviceNameKey: self.GetDeviceNameKey()!, heartRate: heartRate)
        //}
        //CommonUtil.Print(className: self.className, message:"CRPSmartBandService.heartRateGetDate:\(CRPSmartBandService.heartRateGetDate) getTime:\(getTime) timeInHHmm:\(timeInHHmm) timeInHHmmStr:\(timeInHHmmStr) heartRate:\(heartRate) arrNum:\(arrNum) HeartRate24Data:\(HeartRate24Data)")
        self.BpTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector (SetStartBlood), userInfo: nil, repeats: false)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "device：\(self.GetDeviceNameKey()!)")
    }
    /// 心拍数計測データ取得停止
    func SetStopSingleHR(){
        //CommonUtil.Print(className: self.className, message: "心拍数計測データ取得停止  デバイス：\(self.GetDeviceNameKey()!)")
        self.SetupBluetoothService()
        self.crpSmartBand.setStopSingleHR()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "device：\(self.GetDeviceNameKey()!)")
    }
    
    /// 血圧計測データ取得開始
    @objc func SetStartBlood(){
        CRPSmartBandBleService.HrFlag = false
        self.SetupBluetoothService()
        SetStopSingleHR()
        if CRPSmartBandBleService.BloodPressureMeasure == true{
            //CommonUtil.Print(className: self.className, message: "血圧計測データ取得開始  デバイス：\(self.GetDeviceNameKey()!)")
            CRPSmartBandBleService.BpFlag = true
            self.crpSmartBand.setStartBlood()
            self.SpO2Timer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector (SetStartSpO2), userInfo: nil, repeats: false)
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Start to measure blood pressure device：\(self.GetDeviceNameKey()!)")
        }else{
            SetStartSpO2()
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "blood pressure measuring setting is off device：\(self.GetDeviceNameKey()!)")
        }
        
    }
    /// 血圧計測データ取得停止
    func SetStopBlood(){
        //CommonUtil.Print(className: self.className, message: "血圧計測データ取得停止  デバイス：\(self.GetDeviceNameKey()!)")
        self.SetupBluetoothService()
        self.crpSmartBand.setStopBlood()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "device：\(self.GetDeviceNameKey()!)")
    }
    /// SPO2計測データ取得開始
    @objc func SetStartSpO2(){
        CRPSmartBandBleService.BpFlag = false
        self.SetupBluetoothService()
        SetStopBlood()
        if CRPSmartBandBleService.SpO2Measure == true{
            //CommonUtil.Print(className: self.className, message: "SPO2計測データ取得開始  デバイス：\(self.GetDeviceNameKey()!)")
            CRPSmartBandBleService.SpO2Flag = true
            self.crpSmartBand.setStartSpO2()
            self.SendDataTimer = Timer.scheduledTimer(timeInterval: 100, target: self, selector: #selector (SendData), userInfo: nil, repeats: false)
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Start to measure SpO2：\(self.GetDeviceNameKey()!)")
        }else{
            SendData()
            //システムログ作成、送信
            //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "SpO2 measuring setting is off device：\(self.GetDeviceNameKey()!)")
            }
    }
    /// SPO2計測データ取得停止
    func SetStopSpO2(){
        //CommonUtil.Print(className: self.className, message: "SPO2計測データ取得停止  デバイス：\(self.GetDeviceNameKey()!)")
        self.SetupBluetoothService()
        self.crpSmartBand.setStopSpO2()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "device：\(self.GetDeviceNameKey()!)")
    }
    
    ///データ送信
    @objc func SendData(){
        CRPSmartBandBleService.SpO2Flag = false
        SetStopSpO2()
        //CommonUtil.Print(className: self.className, message:"データ送信開始 デバイス：\(self.GetDeviceNameKey() ?? "")")
        self.delegate?.getDataCycleComplete(deviceNameKey : self.GetDeviceNameKey()!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// ウォッチのファームウェアバージョン取得
    func GetFirmware(){
        self.crpSmartBand.getSoftver({ (firmware, error) in
            //CommonUtil.Print(className: self.className, message: "ファームウェアバージョン取得成功  デバイス：\(self.GetDeviceNameKey()!)")
            self.firmwareVersion = String(firmware)
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// ウォッチのバッテリー取得
    func GetBattery(){
        self.crpSmartBand.getBattery({ (battery, error) in
            //CommonUtil.Print(className: self.className, message: "バッテリーレベル取得成功  デバイス：\(self.GetDeviceNameKey()!)")
            self.batteryLevel = String(battery)
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // 24時間心拍数データ取得
    func GetHeartRate(){
        let manager = CRPSmartBandSDK.sharedInstance
        manager.get24HourHeartRate({ (hearts, error) in
            //CommonUtil.Print(className: self.className, message: "24時間心拍数データ取得成功  デバイス：\(self.GetDeviceNameKey()!)")
            self.heartRate24 = [Int](hearts)
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "get 24hour heartrate from watch")
    }
    // 昨日の24時間心拍数データ取得
    func GetYesterdayHeartRate(){
        let manager = CRPSmartBandSDK.sharedInstance
        manager.getAgo24HourHeartRate({ (hearts, error) in
            //CommonUtil.Print(className: self.className, message: "24時間心拍数データ取得成功  デバイス：\(self.GetDeviceNameKey()!)")
            self.yesterdayHeartRate24 = [Int](hearts)
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "get yesterday 24hour heartrate from watch")
    }
    
    // 24時間歩数データ取得
    func GetStep(){
        let manager = CRPSmartBandSDK.sharedInstance
        manager.get24HourSteps( { (steps, error) in
            //CommonUtil.Print(className: self.className, message: "24時間歩数データ取得成功  デバイス：\(self.GetDeviceNameKey()!)")
            self.step24 = [Int](steps)
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "get 24hour step from watch")
    }
    // 昨日の24時間歩数データ取得
    func GetYesterdayStep(){
        let manager = CRPSmartBandSDK.sharedInstance
        manager.getAgo24HourSteps( { (steps, error) in
            self.yesterdayStep24 = [Int](steps)
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "get yesterday 24hour step from watch")
    }
    func GetTodaySleep(){
        let manager = CRPSmartBandSDK.sharedInstance
        manager.getSleepData { (model, error) in
            self.todaySleep = model.detail
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "get today sleep from watch")
    }
    
    // 昨日の睡眠データ取得
    // 配列[0]が昨日
    // 配列[1]が2日前
    func GetYesterdaySleep(){
        let manager = CRPSmartBandSDK.sharedInstance
        manager.getAllData ({ StepModel, SleepModel, Error in
            self.yesterdaySleep = SleepModel
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "get yesterday sleep from watch")
    }
}
// MARK: - CRPManager関連イベント
extension CRPSmartBandBleService:CRPManagerDelegate{
    
    /// バンドの現在の接続状態
    func didState(_ state: CRPState) {
        CommonUtil.Print(className: self.className, message:"Connect state: \(state.rawValue)  デバイス：\(self.GetDeviceNameKey()!)")
        var logtext = ""
        
        if state == .connected{
            CommonUtil.Print(className: self.className, message: "接続成功  デバイス：\(self.GetDeviceNameKey()!)")
            
            if let discovery = self.connectDiscovery{
                // ウォッチバッテリー取得処理
                self.GetBattery()
                // ウォッチファームウェアバージョン取得処理
                //self.GetFirmware()
                self.delegate?.successToWatchConnect(discovery : discovery)
                
                
                self.crpSmartBand.checkDFUState { (dfu, err) in
                    CommonUtil.Print(className: self.className, message:"dfu =\(dfu)")
                }
            }
            else{
                // SDKが保持している機器名
                guard let localNameSDK = self.crpSmartBand.currentCRPDiscovery?.localName else {
                    return
                }
                // SDKが保持しているmacアドレス
                guard let macSDK = self.crpSmartBand.currentCRPDiscovery?.mac else {
                    return
                }
                // ペアリング設定中のとき、SDKが保持するディスカバリーを使用して接続する
                if (self.deviceName == localNameSDK
                    && self.macAddress == macSDK
                    && self.isWatchSetting) {
                    self.connectDiscovery = self.crpSmartBand.currentCRPDiscovery
                } else {
                    self.Disconnect()
                }
            }
            
            self.reconnectFlg = true
            //log用テストコード
            logtext = "connected"
        }
        else if state == .disconnected{
            CommonUtil.Print(className: self.className, message: "接続失敗")
            if self.isWatchSetting{
                // ログ送信
                self.dcService.postSendLogMsg(msg: ConnectStatus.Disconnect.rawValue, deviceID: self.deviceName ?? "", deviceAdr: self.macAddress ?? "", deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue)
            }
            
            //self.connectDiscovery = nil
            //log用テストコード
            logtext = "disconnected"
        }
        else if state == .connecting{
            // ログ送信
            if self.reconnectFlg{
                self.dcService.postSendLogMsg(msg: ConnectStatus.Connected.rawValue, deviceID: self.deviceName ?? "", deviceAdr: self.macAddress ?? "", deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue)
            }
            //log用テストコード
            logtext = "connecting"
        }
        else if state == .disconnecting{
            //log用テストコード
            logtext = "disconnecting"
        }
        else if state == .unbind{
            self.reconnectFlg = false
            //log用テストコード
            logtext = "unbind"
        }
        else if state == .syncError{
            //log用テストコード
            logtext = "syncError"
        }
        else if state == .syncSuccess{
            //log用テストコード
            logtext = "syncSuccess"
        }
        else if state == .syncing{
            //log用テストコード
            logtext = "syncing"
        }
        
        //test
        // CSVファイル名
        let fileUtil = FileUtil()
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "WatchStatasLog_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        // ディレクトリの作成
        fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
        let receiveFileName = CommonConst.ReceiveDir + "/" + "Log" + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString + "," + logtext

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
            
        // ファイル書き込み
        fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive/Log"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
        for file in allFiles{

            // 10日前以前のログファイルを削除する
            if file.contains("WatchStatasLog") {
                let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                let YYYYMMdd_HH = file[startIndex...endIndex]
                //print(YYYYMMdd_HH)
                //print(beforeDtStr)
                
                if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                    || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                    let delFile = "\(logDir)/\(file)"
                    fileUtil.RemoveItem(atPath: delFile)
                }
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: logtext)
    }
    
    /// 通知設定
    func NotificationSetting(isCallSettings : Bool, isSmsSettings : Bool, isLineSettings : Bool){
        var notificationArray : [NotificationType] = []
        let manager = CRPSmartBandSDK.sharedInstance
        // 電話
        if isCallSettings {
            notificationArray.append(NotificationType.phone)
        }
        // SMS
        if isSmsSettings {
            notificationArray.append(NotificationType.messages)
        }
        // LINE
        if isLineSettings {
            notificationArray.append(NotificationType.line)
        }
        print(notificationArray)
        self.crpSmartBand.setNotification(notificationArray)
        manager.getNotifications({ (value, error) in
                print(value)
            })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 現在のBluetoothの状態
    func didBluetoothState(_ state: CRPBluetoothState) {

        switch state {
        case .poweredOff:
            //CommonUtil.Print(className: self.className, message: "Bluetooth PoweredOff")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth PoweredOff")
            break
        case .poweredOn:
            //CommonUtil.Print(className: self.className, message: "Bluetooth poweredOn")
            self.delegate?.blePowerOn()
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth poweredOn")
            break
        case .resetting:
            //CommonUtil.Print(className: self.className, message: "Bluetooth resetting")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth resetting")
            break
        case .unauthorized:
            //CommonUtil.Print(className: self.className, message: "Bluetooth unauthorized")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth unauthorized")
            break
        case .unknown:
            //CommonUtil.Print(className: self.className, message: "Bluetooth unknown")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth unknown")
            break
        case .unsupported:
            //CommonUtil.Print(className: self.className, message: "Bluetooth unsupported")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth unsupported")
            break
        @unknown default:
            //CommonUtil.Print(className: self.className, message: "Bluetooth error")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth error")
            break
        }
    }
    /// スポーツのステップデータをリアルタイムに受信
    func receiveSteps(_ model: StepModel) {
        //CommonUtil.Print(className: self.className, message:"Latest steps: \(model.time)")
        var stepModel = CommonCodable.H76StepModel()
        stepModel.step = model.steps
        stepModel.calories = model.calory
        stepModel.distance = model.distance
        stepModel.getTime = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        
        CRPSmartBandService.SaveStepModelArray.append(stepModel)
        //配列の数調整のため削除
        if CRPSmartBandService.SaveStepModelArray.count == 10{
            CRPSmartBandService.SaveStepModelArray.remove(at: 0)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Latest steps: \(model.time)")
    }
    /// 心拍測定の受信（シングル心拍測定）
    func receiveHeartRate(_ heartRate: Int) {
        //CommonUtil.Print(className: self.className, message:"Latest heart rate: \(heartRate) デバイス：\(self.GetDeviceNameKey() ?? "")")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Latest heart rate: \(heartRate) device：\(self.GetDeviceNameKey() ?? "")")
        //self.delegate?.getHeartRateDataComplete(deviceNameKey: self.GetDeviceNameKey()!, heartRate: heartRate)
    }
    /// リアルタイムの心拍数データを受信
    func receiveRealTimeHeartRate(_ heartRate: Int, _ rri: Int) {
        //CommonUtil.Print(className: self.className, message:"heart rate is \(heartRate)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "heart rate is \(heartRate)")
    }
    /// 動的心拍数データの受信
    func receiveHeartRateAll(_ model: HeartModel) {
        CommonUtil.Print(className: self.className, message:"\(model)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "\(model)")
    }
    /// 血圧測定結果の受け取り
    func receiveBloodPressure(_ heartRate: Int, _ sbp: Int, _ dbp: Int) {
        //CommonUtil.Print(className: self.className, message:"BP: \(heartRate), \(sbp), \(dbp)　デバイス：\(self.GetDeviceNameKey()!)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "BP: \(heartRate), \(sbp), \(dbp)　デバイス：\(self.GetDeviceNameKey()!)")
        self.delegate?.getBloodDataComplete(deviceNameKey :self.GetDeviceNameKey()!, heartRate: heartRate, sbp: sbp, dbp: dbp)
    }
    /// 血中酸素濃度の測定結果の受け取り
    func receiveSpO2(_ o2: Int) {
        //CommonUtil.Print(className: self.className, message:"SpO2 = \(o2)　デバイス：\(self.GetDeviceNameKey()!)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "SpO2 = \(o2)　デバイス：\(self.GetDeviceNameKey()!)")
        self.delegate?.getSpo2DataComplete(deviceNameKey : self.GetDeviceNameKey()!, o2: o2)
    }
    /// ファームウェアアップグレードの進捗状況とステータスの受け取り
    func receiveUpgrede(_ state: CRPUpgradeState, _ progress: Int) {
        //CommonUtil.Print(className: self.className, message:"state = \(state.description()), progress = \(progress)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "state = \(state.description()), progress = \(progress)")
    }
    
    func receiveUpgradeScreen(_ state: CRPUpgradeState, _ progress: Int) {
        //CommonUtil.Print(className: self.className, message:"state = \(state.description()), progress = \(progress)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "state = \(state.description()), progress = \(progress)")
    }
    ///フォトリクエストの受信
    func recevieTakePhoto() {
        //CommonUtil.Print(className: self.className, message:"recevieTakePhoto")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "recevieTakePhoto")
    }
    ///ウォッチの時刻を合わせる
    func setRealTime(){
        self.crpSmartBand.setTime()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    ///言語設定
    func setLanguage(lang : Int){
        self.crpSmartBand.setLanguage(lang)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    ///歩幅設定
    func setStepLength(length : Int){
        self.crpSmartBand.setStepLength(length: length)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "length = \(length)")
    }
    /// 24時間心拍数データ記録間隔設定
    func set24HeartRateInterval(interval : Int){
        var intervalStr : String = ""
        self.crpSmartBand.set24HourHeartRate(interval)
        self.crpSmartBand.get24HourHeartRateInterval({ (interval, error) in
             intervalStr = String(interval)
            })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Interval = \(intervalStr)")
    }
}
