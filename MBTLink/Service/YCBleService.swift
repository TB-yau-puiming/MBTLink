//
// YCBleService.swift
// YCBle関連サービス
//
// MBTLink
//

import Foundation
import CoreBluetooth

// MARK: - プロトコル
protocol YCBleDelegate {
    /// ウォッチスキャン成功
    func successToScanWatch(deviceName : String?, peripherals : [CBPeripheral])
    /// ウォッチ接続成功
    func successToWatchConnect(deviceName : String)
    /// 履歴データ取得完了
    func syncHistoryDataComplete(deviceName : String, historyType : Int, rows : [[String:Any]])
    /// MACアドレス取得完了
    func getMacAddressComplete(deviceName : String, macAddress : String)
    /// 脈拍監視モード設定完了
    func settingHeartModeComplete(deviceName : String, code : Error_Code)
}

final class YCBleService: NSObject {
    
    // MARK: - デリゲート
    var delegate : YCBleDelegate?
    
    // MARK: - enum
    /// 履歴データ同期・履歴タイプ
    enum SyncDataHistoryType : Int{
        /// 歩数
        case Step = 0x02
        /// 脈拍
        case Heart = 0x06
        /// 血圧
        case Blood = 0x08
        /// 総合
        case Combined = 0x09
    }
    /// 履歴データ削除・履歴タイプ
    enum DeleteDataHistoryType : Int{
        /// 歩数
        case Step = 0x40
        /// 脈拍
        case Heart = 0x42
        /// 血圧
        case Blood = 0x43
        /// 総合
        case Combined = 0x44
    }
    
    /// 脈拍監視モード
    enum HeartMode : Int{
        /// 手動モード
        case Manual = 0x00
        /// 自動モード
        case Auto = 0x01
    }
    
    /// 血圧監視モード
    enum BloodModeEnable : Int{
        /// オン
        case On = 0x01
        /// オフ
        case Off = 0x00
    }
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( YCBleService.self)).split(separator: "-")[0])
    /// YCBTProduct
    private var ycbProduct : YCBTProduct!
    /// NotificationCenter
    private let notificationCenter = NotificationCenter.default
    /// 接続先の機器
    private var connectPeripheral: CBPeripheral?
    ///デバイス名
    private var deviceName : String?
    ///MACアドレス
    private var macAddress : String?
    /// 履歴データ辞書・歩数
    private var historyDataStepDic = [String : [[String:Any]]]()
    /// 履歴データ辞書・脈拍
    private var historyDataHeartDic = [String : [[String:Any]]]()
    /// 履歴データ辞書・血圧
    private var historyDataBloodDic = [String : [[String:Any]]]()
    /// 履歴データ辞書・総合
    private var historyDataCombinedDic = [String : [[String:Any]]]()
    
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
        self.ycbProduct = YCBTProduct.init()
        
        // イベント通知登録
        // 履歴データ取得
        self.notificationCenter.addObserver(self, selector: #selector(historyDataMsgReceive(ntf:)), name: NSNotification.Name(rawValue: kNtfRecvHistroyData), object: nil)
    }
    
    ///デイニシャライザ
    deinit {
        // イベント通知解除
        // 履歴データ取得
        self.notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: kNtfRecvHistroyData), object: nil)
    }

    /// デバイス名設定
    func SetDeviceName(value : String?){
        self.deviceName = value
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// デバイス名取得
    func GetDeviceName() -> String?{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.deviceName
    }
    /// MACアドレス設定
    func SetMacAddress(value : String?){
        self.macAddress = value
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// MACアドレス取得
    func GetMacAddress() -> String?{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.macAddress
    }
    /// 接続先の機器設定
    func SetConnectPeripheral(peripheral :CBPeripheral?){
        self.connectPeripheral = peripheral
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 接続先の機器取得
    func GetConnectPeripheral()->CBPeripheral?{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.connectPeripheral
    }

    /// スキャン開始
    func StartBleScan() {
        
        if self.ycbProduct!.cbCM().state == CBManagerState.poweredOn{
            CommonUtil.Print(className: self.className, message: "poweredOn")
        }
        
        // 機器を検出
        if self.ycbProduct!.cbCM().isScanning == false {
            
            if self.connectPeripheral == nil {
                CommonUtil.Print(className: self.className, message: "スキャン開始")
                
                self.ycbProduct!.startScanDevice({ (code, result) in
                    
                    if code == Error_Ok{
                        CommonUtil.Print(className: self.className, message: "スキャン成功")
                        
                        let peripherals : [CBPeripheral] = (result as? [CBPeripheral])!
                        
                        CommonUtil.Print(className: self.className, message: "result:\(peripherals)")
                        
                        self.delegate?.successToScanWatch(deviceName: self.deviceName ?? "", peripherals: peripherals)
                    }
                    else{
                        CommonUtil.Print(className: self.className, message: "スキャン終了")
                    }
                })
            }
            else{
                self.ConnectPeripheral()
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// スキャン停止
    func StopBleScan() {
        self.ycbProduct!.cbCM().stopScan()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 機器に接続
    func ConnectPeripheral() {
        guard let connectPeripheral = self.connectPeripheral else {
            // 失敗処理
            return
        }
        
        let name = connectPeripheral.name
        
        self.ycbProduct!.connectDevice(connectPeripheral) { (code) in
            if code == Error_Ok {
                CommonUtil.Print(className: self.className, message: "接続成功  デバイス名：\(name!)")
                self.delegate?.successToWatchConnect(deviceName: name!)
            }
            else{
                CommonUtil.Print(className: self.className, message: "接続失敗  デバイス名：\(name!)")
                self.connectPeripheral = nil
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイス切断
    func ForceDisconnectDevice(){
        CommonUtil.Print(className: self.className, message: "デバイス切断 デバイス名：\(self.deviceName ?? "")")
        
        self.ycbProduct?.forceDisconnectDevice()
        
        // SDKのメソッドで切断できなかった場合
        if let peripheral = self.GetConnectPeripheral(){
            if peripheral.state  == CBPeripheralState.connected{
                self.ycbProduct?.cbCM().cancelPeripheralConnection(peripheral)
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイス登録解除
    func UnbindDevice(){
        CommonUtil.Print(className: self.className, message: "デバイス登録解除 デバイス名：\(self.deviceName ?? "")")
        
        self.ycbProduct?.unBindDevice()
        self.deviceName = ""
        self.macAddress = ""
        self.connectPeripheral = nil
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 通知設定
    func NotificationSetting(isCallSettings : Bool, isSmsSettings : Bool, isLineSettings : Bool){
        var arg1 : [String] = ["0","0","0","0","0","0","0","0"]
        var arg2 : [String] = ["0","0","0","0","0","0","0","0"]
        
        // 電話
        if isCallSettings {
            arg1[0] = "1"
        }
        // SMS
        if isSmsSettings {
            arg1[1] = "1"
        }
        // LINE
        if isLineSettings {
            arg2[5] = "1"
        }
        
        let appArg1 = ConvertUtil.BinaryNumberToDecimal(binaryNumber: arg1.joined())
        let appArg2 = ConvertUtil.BinaryNumberToDecimal(binaryNumber: arg2.joined())
        
        self.ycbProduct?.settingPushSwitch(true, appArg1: appArg1, appArg2: appArg2){ (code, result) in
            if code == Error_Ok {
                CommonUtil.Print(className: self.className, message: "通知設定成功 デバイス名：\(self.deviceName ?? "") 通話：\(String(isCallSettings)) SMS：\(String(isSmsSettings)) LINE：\(String(isLineSettings))")
            }
            else{
                CommonUtil.Print(className: self.className, message: "通知設定失敗 デバイス名：\(self.deviceName ?? "") 通話：\(String(isCallSettings)) SMS：\(String(isSmsSettings)) LINE：\(String(isLineSettings))")
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// 履歴データ取得
    func SyncDataHistroy(historyType : Int){
        CommonUtil.Print(className: self.className, message: "健康履歴データ取得 デバイス名：\(self.deviceName ?? "") HistoryType:\(String(historyType))")

        // 履歴データ辞書初期化
        var rows = [[String:Any]]()
        self.updateHistoryDataDic(historyType: historyType, rows: rows)
        
        self.ycbProduct!.syncDataHistory(historyType) { (code, result) in
            
            if code == Error_Ok {
                CommonUtil.Print(className: self.className, message: "健康履歴データ取得OK デバイス名：\(self.deviceName ?? "") HistoryType:\(String(historyType))")
                
                // 履歴データ辞書データ行取得
                rows = self.getHistoryDataDicRows(historyType: historyType)

                var message = "健康履歴データ取得 デバイス名：\(self.deviceName ?? "") HistoryType:\(String(historyType)) rows:\(rows)"

                if rows.isEmpty == false{
                    message = "(データ有) " + message

                    self.delegate?.syncHistoryDataComplete(deviceName: self.deviceName!, historyType: historyType, rows: rows)
                }
                else{
                    message = "(データ無) " + message
                }

                CommonUtil.Print(className: self.className, message: message)
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 履歴データ削除
    func DeleteHistoryData(historyType : Int){
        CommonUtil.Print(className: self.className, message: "健康履歴データ削除 デバイス名：\(self.deviceName ?? "") HistoryType:\(String(historyType))")
        
        self.ycbProduct?.deleteHistoryData(historyType) { (code, result) in
            if code == Error_Ok {
                CommonUtil.Print(className: self.className, message: "履歴データ削除成功 デバイス名：\(self.deviceName ?? "") HistoryType:\(String(historyType))")
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 脈拍監視モード設定
    func SettingHeartMode(heartMode : Int, time : Int){
        
        self.ycbProduct?.settingHeartMode(heartMode, autoHeartTime: time) { (code, result) in
            if code == Error_Ok {
                CommonUtil.Print(className: self.className, message: "脈拍監視モード設定成功 デバイス名：\(self.deviceName ?? "") 設定時間：\(time)")
            }
            else{
                CommonUtil.Print(className: self.className, message: "脈拍監視モード設定失敗 デバイス名：\(self.deviceName ?? "") 設定時間：\(time)")
            }
            
            self.delegate?.settingHeartModeComplete(deviceName: self.deviceName!, code: code)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 血圧監視モード設定
    func SettingBloodMode(bloodModeEnable : Int, time : Int){
        
        self.ycbProduct?.settingBloodMode(bloodModeEnable, autoBloodTime: time) { (code, result) in
            if code == Error_Ok {
                CommonUtil.Print(className: self.className, message: "血圧監視モード設定成功 デバイス名：\(self.deviceName ?? "") 設定時間：\(time)")
            }
            else{
                CommonUtil.Print(className: self.className, message: "血圧監視モード設定失敗 デバイス名：\(self.deviceName ?? "") 設定時間：\(time)")
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイスのMACアドレス取得
    func GetDevMac(){
        CommonUtil.Print(className: self.className, message: "MACアドレス取得")
        
        self.ycbProduct!.getDevMac({ (code, result) in
                
            if code == Error_Ok{
                CommonUtil.Print(className: self.className, message: "MACアドレス取得成功 デバイス名：\(self.deviceName ?? "")")
                
                if let macAddress = result["keyDevMac"] as? String{
                    self.delegate?.getMacAddressComplete(deviceName: self.deviceName!, macAddress: macAddress)
                }
            }
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Private Methods
    /// 健康履歴データ取得メッセージ受信
    @objc func historyDataMsgReceive(ntf : Notification){
        
        let tUserInfo = ntf.userInfo
        if tUserInfo == nil {
            return
        }
        
        let tHistoryType :Int = tUserInfo!["keyHistoryType"] as! Int
        guard let historyDatas : NSMutableArray = tUserInfo!["keyHistoryData"] as? NSMutableArray else{
            return
        }
        
        let data = try? JSONSerialization.data(withJSONObject: historyDatas as Any, options: .prettyPrinted)
        
        let json = try? JSONSerialization.jsonObject(with: data!)
        
        guard let rows = json as? [[String:Any]] else {
            return
        }
        
        /// 履歴データ辞書更新
        self.updateHistoryDataDic(historyType: tHistoryType, rows: rows)
        
        CommonUtil.Print(className: self.className, message: "健康履歴データ取得成功 デバイス名：\(self.deviceName ?? "") HistoryType:\(String(tHistoryType))　historyDatas:\(historyDatas)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 履歴データ辞書更新
    private func updateHistoryDataDic(historyType : Int, rows : [[String:Any]]){
        
        let key = "\(String(historyType))_\(String(describing: self.deviceName))"
        
        switch historyType {
        case SyncDataHistoryType.Step.rawValue:
            // 歩数
            self.historyDataStepDic.updateValue(rows, forKey: key)
            break
        case SyncDataHistoryType.Heart.rawValue:
            // 脈拍
            self.historyDataHeartDic.updateValue(rows, forKey: key)
            break
        case SyncDataHistoryType.Blood.rawValue:
            // 血圧
            self.historyDataBloodDic.updateValue(rows, forKey: key)
            break
        case SyncDataHistoryType.Combined.rawValue:
            // 総合
            self.historyDataCombinedDic.updateValue(rows, forKey: key)
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 履歴データ辞書データ行取得
    private func getHistoryDataDicRows(historyType : Int) -> [[String:Any]]{
        
        let key = "\(String(historyType))_\(String(describing: self.deviceName))"
        var rows = [[String:Any]]()
        
        switch historyType {
        case SyncDataHistoryType.Step.rawValue:
            // 歩数
            if self.historyDataStepDic.keys.contains(key){
                rows = self.historyDataStepDic[key]!
            }
            break
        case SyncDataHistoryType.Heart.rawValue:
            // 脈拍
            if self.historyDataHeartDic.keys.contains(key){
                rows = self.historyDataHeartDic[key]!
            }
            break
        case SyncDataHistoryType.Blood.rawValue:
            // 血圧
            if self.historyDataBloodDic.keys.contains(key){
                rows = self.historyDataBloodDic[key]!
            }
            break
        case SyncDataHistoryType.Combined.rawValue:
            // 総合
            if self.historyDataCombinedDic.keys.contains(key){
                rows = self.historyDataCombinedDic[key]!
            }
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return rows
    }
}
