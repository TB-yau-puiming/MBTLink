//
// BleService.swift
// BLE関連サービス
//
// MBTLink
//

import Foundation
import CoreBluetooth

// MARK: - プロトコル
protocol BleDelegate {
    /// BLE検出可能
    func blePowerOn(deviceName: String)
    /// デバイススキャン成功
    func successToScanDevice(peripheral : CBPeripheral, deviceName : String)
    /// デバイス接続成功
    func successToDeviceConnect(peripheral : CBPeripheral, deviceName: String)
    /// デバイス接続失敗
    func failToDeviceConnect(deviceName: String)
    /// デバイス接続切断
    func deviceDisconnect(deviceName: String)
    /// データ読み取り完了
    func complete(peripheral: CBPeripheral, deviceName: String, data : Data)
}
class serviceType{
    ///サービスUUID
    var serviceUUID : CBUUID
    ///キャラクタリスティックUUID
    var characteristicUUID : [CBUUID]
    /// プロパティ
    var properties : Int
    /// 処理待ちフラグ
    var isProcessPending : Bool
    
    // MARK: - Public Methods
    /// イニシャライザ
    init() {
        self.serviceUUID = CBUUID()
        self.characteristicUUID = [CBUUID()]
        self.properties = 0
        self.isProcessPending = false
    }

    /// サービスUUIDの取得
    func GetServiceUUID()->CBUUID?{
        return self.serviceUUID
    }
    
    func loggingServiceType(){
        CommonUtil.Print(className: "serviceType", message:"                サービスUUID:\(self.serviceUUID.uuidString)")
        for characteristicUUID in self.characteristicUUID{
            CommonUtil.Print(className: "serviceType", message:"                キャラクタリスティックUUID:\(characteristicUUID.uuidString)")
        }
        CommonUtil.Print(className: "serviceType", message:"                プロパティ:\(String(self.properties))")
        CommonUtil.Print(className: "serviceType", message:"                処理待ちフラグ:\(String(self.properties))")
    }
}

final class BleService: NSObject {
    // MARK: - デリゲート
    var delegate : BleDelegate?
    
    // MARK: - enum
    /// プロパティ
    enum Properties : Int{
        case Read = 1
        case Write = 2
        case Notify = 3
        case Indicate = 4
    }
    /// ステータス
    enum Status : Int{
        case Prossesing = 1
        case Success = 2
    }
    /// 接続ステータス  ログ送信 20220713対応中
    enum ConnectStatus : String{
        case Connected = "Connected"
        case Disconnect = "Disconnect"
    }
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( BleService.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    /// セントラルマネジャー
    private var centralManager : CBCentralManager
    /// ペリフェラルマネジャー
    private var peripheralManager : CBPeripheralManager
    /// 接続先の機器
    private var connectPeripheral: CBPeripheral?
    /// 対象のキャラクタリスティック
    private var writeCharacteristic: CBCharacteristic?
    ///デバイス名
    private var deviceName : String!
    ///スキャニングサービスUUID
    private var scaningServiceUUID : CBUUID!
    /// デバイスインフォメーションサービス
    private var deviceInfoService : serviceType
    /// 計測データ取得サービス
    private var instrumentationService : serviceType
    /// バッテリーサービス
    private var batteryService : serviceType
    /// 書き込みサービス
    private var writeService : serviceType
    /// 読み込みデータ
    private var readData : Data!
    /// 書き込みデータ
    private var writeData : Data!
    /// ステータス
    private var status : Int = Status.Prossesing.rawValue
    /// RSSI
    private var rssi : Int?
    /// 接続中デバイス名
    private var deviceNamePairing : String
    /// 接続中デバイスの有無
    private var pairingStatus : Bool = false
    /// バッテリーレベル
    private var batteryLevel : String
    /// 書き込みサービスreturnフラグ
    private var writeServiceReturnFlg : Bool
    

    // MARK: - Public Methods
    /// イニシャライザ
    init(deviceName : String, writeData :Data!, deviceNamePairing : String,pairingStatus : Bool,writeServiceReturnFlg : Bool) {
        self.centralManager = CBCentralManager()
        self.peripheralManager = CBPeripheralManager()
        self.deviceName = deviceName
        
        self.writeData = writeData
        
        self.deviceNamePairing = (deviceNamePairing == "" ? deviceName : deviceNamePairing)
        self.pairingStatus = pairingStatus
        
        self.scaningServiceUUID = nil
        self.deviceInfoService = serviceType()
        self.instrumentationService = serviceType()
        self.batteryService = serviceType()
        self.writeService = serviceType()
        
        self.batteryLevel = ""
        self.writeServiceReturnFlg = writeServiceReturnFlg
    }

    /// BLE接続のセットアップ
    func SetupBluetoothService() {
        // 接続中機器がないときのみ初期化する
        if self.connectPeripheral == nil {
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
            //self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    /// BleServiceをコピーする
    func copy()->BleService{
        let instance = BleService(deviceName: self.deviceName, writeData: self.writeData, deviceNamePairing: self.deviceNamePairing, pairingStatus: self.pairingStatus, writeServiceReturnFlg: self.writeServiceReturnFlg)
        
        instance.centralManager = self.centralManager
        instance.peripheralManager = self.peripheralManager
        
        instance.scaningServiceUUID = self.scaningServiceUUID
        instance.deviceInfoService = self.deviceInfoService
        instance.instrumentationService = self.instrumentationService
        instance.batteryService = self.batteryService
        instance.writeService = self.writeService
        
        instance.batteryLevel = self.batteryLevel

        instance.connectPeripheral = self.connectPeripheral
        instance.writeCharacteristic = self.writeCharacteristic
        instance.readData = self.readData
        instance.status = self.status
        instance.rssi = self.rssi
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return instance
    }
    
    /// BleServiceの値をコンソールに出力するテスト用ファンクション
    func loggingBleServiceContents(){
        CommonUtil.Print(className: self.className, message:"          ===BleService ログ出力開始===")
        CommonUtil.Print(className: self.className, message:"            デバイス名:\(String(self.deviceName))")
        CommonUtil.Print(className: self.className, message:"            セントラルマネジャー:\(self.centralManager)")
        CommonUtil.Print(className: self.className, message:"            ペリフェラルマネジャー:\(self.peripheralManager)")
        CommonUtil.Print(className: self.className, message:"            読み込みデータ:\(self.readData)")
        CommonUtil.Print(className: self.className, message:"            書き込みデータ:\(self.writeData)")
        CommonUtil.Print(className: self.className, message:"            ステータス:\(String(self.status))")
        CommonUtil.Print(className: self.className, message:"            RSSI:\(self.rssi)")
        CommonUtil.Print(className: self.className, message:"            接続中デバイス名:\(self.deviceNamePairing)")
        CommonUtil.Print(className: self.className, message:"            接続中デバイスの有無:\(self.pairingStatus)")
        CommonUtil.Print(className: self.className, message:"            バッテリーレベル:\(self.batteryLevel)")
        CommonUtil.Print(className: self.className, message:"            書き込みサービスreturnフラグ:\(self.writeServiceReturnFlg)")
        CommonUtil.Print(className: self.className, message:"            スキャニングサービスUUID:\(self.scaningServiceUUID.uuidString)")
        
        CommonUtil.Print(className: self.className, message:"            [デバイスインフォメーションサービス]")
        self.deviceInfoService.loggingServiceType()
        
        CommonUtil.Print(className: self.className, message:"            [計測データ取得サービス]")
        self.instrumentationService.loggingServiceType()
        
        CommonUtil.Print(className: self.className, message:"            [バッテリーサービス]")
        self.batteryService.loggingServiceType()
        
        CommonUtil.Print(className: self.className, message:"            [書き込みサービス]")
        self.writeService.loggingServiceType()
        
        CommonUtil.Print(className: self.className, message:"          ===BleService ログ出力終了===")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ログ出力
    func LogOutput(timing : String){
        
        let fileUtil = FileUtil()
        var logStr : String = ""

        // ログファイル名
        let logFileNameStr : String = "EnvSensor_Log_"
        let logFileName : String = logFileNameStr + DateUtil.GetDateFormatConvert(format: "yyyyMMdd") + ".txt"
        let receiveFileName : String = CommonConst.ReceiveDir + "/" + logFileName
        
        // ファイル書き込みデータ
        var logWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            logWriteData = fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData.append("          ===BleService ログ出力開始===")
        writeData.append("\n")
        writeData.append("          [" + timing + "]" + dateString)
        writeData.append("\n")
        writeData.append("            デバイス名:\(String(self.deviceName))")
        writeData.append("\n")
        writeData.append("            セントラルマネジャー:\(self.centralManager)")
        writeData.append("\n")
        writeData.append("            ペリフェラルマネジャー:\(self.peripheralManager)")
        writeData.append("\n")
        writeData.append("            読み込みデータ:\(self.readData)")
        writeData.append("\n")
        writeData.append("            書き込みデータ:\(self.writeData)")
        writeData.append("\n")
        writeData.append("            ステータス:\(String(self.status))")
        writeData.append("\n")
        writeData.append("            RSSI:\(self.rssi)")
        writeData.append("\n")
        writeData.append("            接続中デバイス名:\(self.deviceNamePairing)")
        writeData.append("\n")
        writeData.append("            接続中デバイスの有無:\(self.pairingStatus)")
        writeData.append("\n")
        writeData.append("            バッテリーレベル:\(self.batteryLevel)")
        writeData.append("\n")
        writeData.append("            書き込みサービスreturnフラグ:\(self.writeServiceReturnFlg)")
        writeData.append("\n")
        writeData.append("            スキャニングサービスUUID:\(self.scaningServiceUUID.uuidString)")
        writeData.append("\n")
        writeData.append("          ===BleService ログ出力終了===")

        logWriteData.append("\n")
        logWriteData.append(writeData)
    
        // ファイル書き込み
        fileUtil.WritingToFile(text: logWriteData,fileName: receiveFileName)
        
        //ファイル削除
        //fileUtil.fileDel(csvFileNameStr: logFileNameStr, targetFile: logFileNameStr)
        // 現在日付 - 2日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = logFileNameStr.utf8.count
        let endIndexPoint = -5
            
        for file in allFiles{
            // 2日前以前のログファイルを削除する
            if file.contains("EnvSensor_Log") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: timing)
    }

    /// スキャン開始
    func StartBleScan() {
        //CommonUtil.Print(className: self.className, message: "スキャン開始 デバイス名：\(self.deviceName!)")
        
        // 機器を検出
        if self.centralManager.isScanning == false {
            /// 処理中
            self.status = Status.Prossesing.rawValue

            if self.connectPeripheral == nil {
                var service : [CBUUID]? = nil

                if self.pairingStatus {
                    if self.scaningServiceUUID != nil{
                        let serviceUUIDstr : String =
                        self.scaningServiceUUID.uuidString
                        let cbuuid = CBUUID(string: serviceUUIDstr)
                        service = [cbuuid]
                    }
                }
                self.centralManager.scanForPeripherals(withServices: service, options: nil)
//                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
            else{
                
                self.ConnectPeripheral()
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    /// スキャン停止
    func StopBleScan() {
        self.centralManager.stopScan()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }

    /// 機器に接続
    func ConnectPeripheral() {
        
        guard let connectPeripheral = self.connectPeripheral else {
            // 失敗処理
            return
        }
        /// 処理中
        self.status = Status.Prossesing.rawValue
        self.centralManager.connect(connectPeripheral, options: nil)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    /// 機器から切断
    func DisconnectPeripheral(){
        //CommonUtil.Print(className: self.className, message: "機器から切断 デバイス名：\(self.deviceName!)")
        
        if self.connectPeripheral != nil{
            
            self.centralManager.cancelPeripheralConnection(self.connectPeripheral!)
            self.connectPeripheral = nil
            //CommonUtil.Print(className: self.className, message: "機器から切断完了 デバイス名：\(self.deviceName!)")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    /// 再接続処理
    func reConnectPeripheral(){
        //CommonUtil.Print(className: self.className, message: "機器と再接続開始 デバイス名：\(self.deviceName!)")
        
        guard let connectPeripheral = self.connectPeripheral else {
            // 失敗処理
            return
        }
        // 切断
        self.centralManager.cancelPeripheralConnection(connectPeripheral)
        
        // 接続
        self.centralManager.connect(connectPeripheral, options: nil)
        
        //CommonUtil.Print(className: self.className, message: "機器と再接続完了 デバイス名：\(self.deviceName!)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        //システムログ作成、送信
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    /// スキャニング用サービスUUID
    func SetScaningServiceUUID(uuid : CBUUID){
        self.scaningServiceUUID = uuid
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// デバイスインフォメーションサービスの設定
    func SetDeviceInfoService(serviceUUID : CBUUID, characteristicUUID : [CBUUID], properties : Int){
        self.deviceInfoService.serviceUUID = serviceUUID
        self.deviceInfoService.characteristicUUID = characteristicUUID
        self.deviceInfoService.properties = properties
        self.deviceInfoService.isProcessPending = true
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 計測データ取得サービスの設定
    func SetInstrumentationService(serviceUUID : CBUUID, characteristicUUID : [CBUUID], properties : Int){
        self.instrumentationService.serviceUUID = serviceUUID
        self.instrumentationService.characteristicUUID = characteristicUUID
        self.instrumentationService.properties = properties
        self.instrumentationService.isProcessPending = true
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// バッテリーサービスの設定
    func SetBatteryService(serviceUUID : CBUUID, characteristicUUID : [CBUUID], properties : Int){
        self.batteryService.serviceUUID = serviceUUID
        self.batteryService.characteristicUUID = characteristicUUID
        self.batteryService.properties = properties
        self.batteryService.isProcessPending = true
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 書き込みサービスの設定
    func SetWriteService(serviceUUID : CBUUID, characteristicUUID : [CBUUID], properties : Int){
        self.writeService.serviceUUID = serviceUUID
        self.writeService.characteristicUUID = characteristicUUID
        self.writeService.properties = properties
        self.writeService.isProcessPending = true
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // サービス関係の初期化処理
    func clearService(){
        // スキャン用サービスUUIDの初期化
        self.scaningServiceUUID = CBUUID()
        // 各サービスの初期化
        self.deviceInfoService = serviceType()
        self.instrumentationService = serviceType()
        self.batteryService = serviceType()
        self.writeService = serviceType()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイスインフォメーションサービス取得
    func GetDeviceInfoService() -> serviceType{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.deviceInfoService
    }
    /// 計測データ取得サービス取得
    func GetInstrumentationService() -> serviceType{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.instrumentationService
    }
    /// バッテリーサービス取得
    func GetBatteryService() -> serviceType{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.batteryService
    }
    /// 書き込みサービス取得
    func GetWriteService() -> serviceType{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.writeService
    }

    /// 書込データ
    func SetWriteData(writeData : Data){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.writeData = writeData
    }
    /// 読込データ
    func GetReadData() -> Data!{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.readData
    }
    /// ステータス
    func GetStatus() -> Int!{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.status
    }
    /// ステータス
    func SetStatus(status : Int){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.status = status
    }
    
    /// 接続先の機器設定
    func SetConnectPeripheral(peripheral :CBPeripheral?){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.connectPeripheral = peripheral
    }
    /// 接続先の機器取得
    func GetConnectPeripheral()->CBPeripheral?{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.connectPeripheral
    }
    /// RSSIの取得
    func GetRssi()->Int?{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.rssi
    }
    
    /// 接続中デバイス名設定
    func SetDeviceNamePairing(deviceNamePairing : String){
        self.deviceNamePairing = deviceNamePairing
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 接続中デバイスの有無
    func SetPairingStatus(bool : Bool){
        self.pairingStatus = bool
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// バッテリーレベルの取得
    func GetBatteryLevel()->String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.batteryLevel
    }
    /// バッテリーレベルの設定
    func SetBatteryLevel(batteryLevel : String){
        self.batteryLevel = batteryLevel
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // 書き込みサービスreturnフラグの取得
    func GetWriteServiceReturnFlg()->Bool{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.writeServiceReturnFlg
    }
    
    // 書き込みサービスreturnフラグの設定
    func SetWriteServiceReturnFlg(writeServiceReturnFlg : Bool){
        self.writeServiceReturnFlg = writeServiceReturnFlg
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}

// MARK: - CentralManager関連イベント
extension BleService:CBCentralManagerDelegate{

        /// Bluetoothのステータスを取得する(CBCentralManagerの状態が変わる度に呼び出される)
        ///
        /// - Parameter central: CBCentralManager
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            //CommonUtil.Print(className: self.className, message: "*****central状態更新：\(#function):\(#line)")
            
            switch central.state {
            case .poweredOff:
                //CommonUtil.Print(className: self.className, message: "Bluetooth PoweredOff")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth PoweredOff")
                break
            case .poweredOn:
                //CommonUtil.Print(className: self.className, message: "Bluetooth poweredOn")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Bluetooth poweredOn")
                self.delegate?.blePowerOn(deviceName: self.deviceName)
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

        /// スキャン結果取得
        ///
        /// - Parameters:
        ///   - central: CBCentralManager
        ///   - peripheral: CBPeripheral
        ///   - advertisementData: アドバタイズしたデータを含む辞書型
        ///   - RSSI: 周辺機器の現在の受信信号強度インジケータ（RSSI）（デシベル単位）
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            CommonUtil.Print(className: self.className, message: "*****スキャン取得結果：\(#function):\(#line)")
            
            let name : String = String(peripheral.name ?? "")
            CommonUtil.Print(className: self.className, message: "ペリフェラルの機器名：\(name)")
            CommonUtil.Print(className: self.className, message: "BLEサービスの機器名：\(self.deviceNamePairing)")

            if name.contains(self.deviceNamePairing) {
//                if name.contains(self.deviceName) {
                
                print("peripheral.name: \(String(describing: peripheral.name))")
                print("advertisementData:\(advertisementData)")
                print("RSSI: \(RSSI)")
                print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)\n")
                
                self.centralManager.stopScan()
                // 対象機器のみ保持する
                self.connectPeripheral = peripheral
                self.rssi = Int(truncating: RSSI)
                
                self.delegate?.successToScanDevice(peripheral: peripheral, deviceName: self.deviceName)
                // 機器に接続
                //CommonUtil.Print(className: self.className, message: "機器に接続：\(String(describing: peripheral.name))")
                //self.centralManager.connect(peripheral, options: nil)
            }
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            // ログ出力処理
            self.LogOutput(timing: "スキャン成功時")
            
        }

        /// 接続成功時
        ///
        /// - Parameters:
        ///   - central: CBCentralManager
        ///   - peripheral: CBPeripheral
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            var discoverServices:[CBUUID] = []

            //CommonUtil.Print(className: self.className, message: "接続成功 デバイス名：\(self.deviceName!)")
            
            self.connectPeripheral = peripheral
            self.connectPeripheral?.delegate = self

            // 指定のサービスを探索
            if let peripheral = self.connectPeripheral {
                // バッテリーサービスが存在する場合は追加
                if(!self.batteryService.serviceUUID.uuidString.isEmpty ){
                    discoverServices.append(self.batteryService.serviceUUID)
                }
                // デバイスインフォメーションサービスが存在する場合は追加
                if(!self.deviceInfoService.serviceUUID.uuidString.isEmpty ){
                    discoverServices.append(self.deviceInfoService.serviceUUID)
                }
                // 計測データ取得サービスが存在する場合は追加
                if(!self.instrumentationService.serviceUUID.uuidString.isEmpty){
                    discoverServices.append(self.instrumentationService.serviceUUID)
                }
                // 書き込みサービスが存在する場合は追加
                if(!self.writeService.serviceUUID.uuidString.isEmpty){
                    discoverServices.append(self.writeService.serviceUUID)
                }
                
                if (discoverServices.count > 0) {
                    peripheral.discoverServices(discoverServices)
                }
            }
            // スキャン停止処理
            self.StopBleScan()
            
            self.LogOutput(timing: "接続成功時")
            
            self.delegate?.successToDeviceConnect(peripheral : peripheral, deviceName: self.deviceName)
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
                        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
        }

        /// 接続失敗時
        ///
        /// - Parameters:
        ///   - central: CBCentralManager
        ///   - peripheral: CBPeripheral
        ///   - error: Error
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            //CommonUtil.Print(className: self.className, message: "接続失敗：error -> \(String(describing: error)) デバイス名：\(self.deviceName!)")
            
            self.LogOutput(timing: "接続失敗時")
            
            self.connectPeripheral = nil
            self.delegate?.failToDeviceConnect(deviceName: self.deviceName)
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
            //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
        }

        /// 接続切断時
        ///
        /// - Parameters:
        ///   - central: CBCentralManager
        ///   - peripheral: CBPeripheral
        ///   - error: Error
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            //CommonUtil.Print(className: self.className, message: "接続切断：error -> \(String(describing: error)) デバイス名：\(self.deviceName!)")
            
            // ログ出力処理
            self.LogOutput(timing: "接続切断時")

            self.delegate?.deviceDisconnect(deviceName: self.deviceName)
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
            //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
        }
}

// MARK: - Peripheral関連イベント
extension BleService: CBPeripheralDelegate {
    /// キャラクタリスティック探索時(機器接続直後に呼ばれる)
    ///
    /// - Parameters:
    ///   - peripheral: CBPeripheral
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        CommonUtil.Print(className: self.className, message: "*****：\(#function):\(#line)")
        
        guard error == nil else {
            // スキャン停止処理
            self.StopBleScan()
            // 失敗処理
            return
        }

        if let peripheralServices = peripheral.services {

            for service in peripheralServices {
                var characteristicUUIDArray: [CBUUID] = []

                // バッテリーサービスの場合
                if(self.batteryService.serviceUUID.uuidString.count > 0
                   && service.uuid == self.batteryService.serviceUUID){
                    characteristicUUIDArray = self.batteryService.characteristicUUID
                // デバイスインフォメーションサービスの場合
                } else if (
                    self.deviceInfoService.serviceUUID.uuidString.count > 0
                    && service.uuid == self.deviceInfoService.serviceUUID) {
                    characteristicUUIDArray = self.deviceInfoService.characteristicUUID
                // 計測データ取得サービスの場合
                } else if (
                    self.instrumentationService.serviceUUID.uuidString.count > 0
                    && service.uuid == self.instrumentationService.serviceUUID) {
                    characteristicUUIDArray = self.instrumentationService.characteristicUUID
                    
                    // 書き込みサービスが設定されている場合、キャラクタリスティックを追加する
                    // (補足)サービスUUIDが同じである計測データサービスと書き込みサービス双方のキャラクタリスティックを格納するため
                    if(self.writeService.serviceUUID.uuidString.count > 0 && service.uuid == self.writeService.serviceUUID){
                        characteristicUUIDArray.append(self.writeService.characteristicUUID[0])
                    }
                    
                // 書き込みサービスの場合
                } else if (
                    self.writeService.serviceUUID.uuidString.count > 0
                    && service.uuid == self.writeService.serviceUUID) {
                    characteristicUUIDArray = self.writeService.characteristicUUID
                }
                
                if(characteristicUUIDArray.count > 0){
                    CommonUtil.Print(className: self.className, message: "キャラクタリスティック探索 デバイス名：\(self.deviceName!)")
                    // キャラクタリスティック探索開始
                    peripheral.discoverCharacteristics(characteristicUUIDArray, for: service)
                }
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "search characteristic")
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
    
    /// RSSIの取得が成功した時
    ///
    /// - Parameters:
    ///   - peripheral: CBPeripheral
    ///   - didReadRSSI: RSSI
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        CommonUtil.Print(className: self.className, message: "*****RSSIの取得が成功：\(#function):\(#line)")
        
        guard error == nil else {
            // 失敗処理
            return
        }
        
        self.rssi = Int(truncating: RSSI)
        CommonUtil.Print(className: self.className, message: "RSSI:\(RSSI)  デバイス名：\(self.deviceName!)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "succeed in getting RSSI")
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
    }
}

// MARK: - PeripheralManager関連イベント
extension BleService: CBPeripheralManagerDelegate {
    /// 端末のBluetooth設定を取得
    /// (WearBluetoothServiceの使用開始時、端末のBluetooth設定変更時に呼ばれる)
    ///
    /// - Parameter peripheral: CBPeripheralManager
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        CommonUtil.Print(className: self.className, message: "*****peripheral状態更新：\(#function):\(#line)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "peripheral state update")
        switch peripheral.state {
            case .poweredOn:
                // サービスを登録
                CommonUtil.Print(className: self.className, message: "サービス登録 デバイス名：\(self.deviceName!)")
            
                // バッテリーサービスが存在する場合は追加
                if(!self.batteryService.serviceUUID.uuidString.isEmpty ){
                    let service = CBMutableService(type: self.batteryService.serviceUUID, primary: true)
                    self.peripheralManager.add(service)
                }
                // デバイスインフォメーションサービスが存在する場合は追加
                if(!self.deviceInfoService.serviceUUID.uuidString.isEmpty ){
                    let service = CBMutableService(type: self.deviceInfoService.serviceUUID, primary: true)
                    self.peripheralManager.add(service)
                }
                // 計測データ取得サービスが存在する場合は追加
                if(!self.instrumentationService.serviceUUID.uuidString.isEmpty){
                    let service = CBMutableService(type: self.instrumentationService.serviceUUID, primary: true)
                    self.peripheralManager.add(service)
                }
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "adding service device name: \(self.deviceName!)")
                break
            case .unknown:
                //CommonUtil.Print(className: self.className, message: "bluetooth unknown")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "bluetooth unknown")
                break
            case .resetting:
                //CommonUtil.Print(className: self.className, message: "bluetooth resetting")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "bluetooth resetting")
                break
            case .unsupported:
                //CommonUtil.Print(className: self.className, message: "bluetooth unsupported")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "bluetooth unsupported")
                break
            case .unauthorized:
                //CommonUtil.Print(className: self.className, message: "bluetooth unauthorized")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "bluetooth unauthorized")
                break
            case .poweredOff:
                //CommonUtil.Print(className: self.className, message: "bluetooth poweredOff")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "bluetooth poweredOff")
                break
            @unknown default:
                //CommonUtil.Print(className: self.className, message: "bluetooth error")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "bluetooth error")
                break
        }
    }

    /// キャラクタリスティック発見時(機器接続直後に呼ばれる)
    ///
    /// - Parameters:
    ///   - peripheral: CBPeripheral
    ///   - service: CBService
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard error == nil else {
            // スキャン停止処理
            self.StopBleScan()
            //CommonUtil.Print(className: self.className, message: "キャラクタリスティック発見時：\(String(describing: error)) デバイス名：\(self.deviceName!)")
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "characteristic is found：\(String(describing: error)) device name：\(self.deviceName!)")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "characteristic is found：\(String(describing: error)) device name：\(self.deviceName!)")
            // エラー処理
            return
        }
        guard let serviceCharacteristics = service.characteristics else {
            // エラー処理
            return
        }
        // キャラクタリスティック別の処理
        //CommonUtil.Print(className: self.className, message: "キャラクタリスティック別処理 デバイス名：\(self.deviceName!)")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "characteristic process device name：\(self.deviceName!)")
        for characreristic in serviceCharacteristics {
            var properties: Int = 0
            
            // バッテリーサービスの場合
            if (characreristic.service?.uuid == self.batteryService.serviceUUID) {
                properties = self.batteryService.properties
            // デバイスインフォメーションサービスの場合
            } else if (characreristic.service?.uuid == self.deviceInfoService.serviceUUID) {
                properties = self.deviceInfoService.properties
            // 計測機器データ取得サービスの場合
            } else if (characreristic.service?.uuid == self.instrumentationService.serviceUUID
                       && characreristic.uuid == self.instrumentationService.characteristicUUID[0]) {
                properties = self.instrumentationService.properties
            // 書き込みサービスの場合
            } else if (characreristic.service?.uuid == self.writeService.serviceUUID
                       && characreristic.uuid == self.writeService.characteristicUUID[0]) {
                properties = self.writeService.properties
            }
            
            switch properties {
            case  Properties.Notify.rawValue:
                //CommonUtil.Print(className: self.className, message: "キャラクタリスティック通知開始 デバイス名：\(self.deviceName!)")
                
                peripheral.setNotifyValue(true, for: characreristic)
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start characreristic notify device name：\(self.deviceName!)")
                break
            case  Properties.Read.rawValue :
                // 読込開始
                //CommonUtil.Print(className: self.className, message: "キャラクタリスティック読込開始")
                
                peripheral.readValue(for: characreristic)
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start to load characreristic")
                break
            
            case Properties.Write.rawValue:
                // 書込開始
                //CommonUtil.Print(className: self.className, message: "キャラクタリスティック書込開始")
                
                // 日時データの書き込み
                if(self.writeData != nil){
                    peripheral.writeValue(self.writeData, for: characreristic, type: CBCharacteristicWriteType.withResponse)
                }
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start to write characreristic")
                break

            default :
                break
            }
        }
    }

    /// キャラクタリスティックにデータ書き込み時(コマンド送信時に呼ばれる)
    ///
    /// - Parameters:
    ///   - peripheral: CBPeripheral
    ///   - characteristic: CBCharacteristic
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            //CommonUtil.Print(className: self.className, message: "キャラクタリスティックデータ書き込み時エラー：\(String(describing: error)) デバイス名：\(self.deviceName!)")
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Error during writeing characteristic data：\(String(describing: error)) device name：\(self.deviceName!)")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Error during writeing characteristic data：\(String(describing: error)) device name：\(self.deviceName!)")
            // 失敗処理
            return
        }
        // 読み込み開始
        peripheral.readValue(for: characteristic)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "loading value")
    }

    /// キャラクタリスティック値取得・変更時(コマンド送信後、受信時に呼ばれる)
    ///
    /// - Parameters:
    ///   - peripheral: CBPeripheral
    ///   - characteristic: CBCharacteristic
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            //CommonUtil.Print(className: self.className, message: "キャラクタリスティック値取得・変更時エラー：\(String(describing: error)) デバイス名：\(self.deviceName!)")
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "error in getting or changing characteristic value：\(String(describing: error)) device name：\(self.deviceName!)")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "error in getting or changing characteristic value：\(String(describing: error)) device name：\(self.deviceName!)")
            // 失敗処理
            return
        }
        guard let data = characteristic.value else {
            // 失敗処理
            return
        }
        
        // RSSI取得
        peripheral.readRSSI()
        // データが渡ってくる
        CommonUtil.Print(className: self.className, message: "キャラクタリスティックデータ取得成功 デバイス名：\(self.deviceName!)")
        
        // バッテリーサービスの場合
        if (self.batteryService.serviceUUID.uuidString.count > 0
            && characteristic.service?.uuid == self.batteryService.serviceUUID) {
            // バッテリーレベルを保存
            self.batteryLevel = String(Int(ConvertUtil.HexadecimalZeroPadding(uint:data[0]),radix: 16)!)
            // 処理待ちフラグをfalseにする
            self.batteryService.isProcessPending = false
            
            return
        }
        // デバイスインフォメーションサービスの場合
        if(self.deviceInfoService.serviceUUID.uuidString.count > 0
                  && characteristic.service?.uuid == self.deviceInfoService.serviceUUID){
            // 処理待ちフラグをfalseにする
            self.deviceInfoService.isProcessPending = false
        }
        // 書き込みサービスの場合
        if(self.writeService.serviceUUID.uuidString.count > 0 && characteristic.service?.uuid == self.writeService.serviceUUID && characteristic.uuid == self.writeService.characteristicUUID[0]){
            
            // 処理待ちフラグをfalseにする
            self.writeService.isProcessPending = false
            
            // 書き込みサービスがcomplete処理を行う必要がない場合、処理を終了する
            if (writeServiceReturnFlg){
                return
            }
        }

        self.readData = data

        /// 処理完了
        self.status = Status.Success.rawValue
        
        // ログ出力処理
        self.LogOutput(timing: "キャラクタリスティック値取得・変更時")
        
        self.delegate?.complete(peripheral: peripheral, deviceName: self.deviceName, data: data)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
