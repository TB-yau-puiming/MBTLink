//
// CRPSmartBandService.swift
// CRPSmartBand関連サービス
//
//  MBTLink
//

import Foundation

final class CRPSmartBandService {
    
    /// 歩数モデル保持用Array
    static var SaveStepModelArray = [CommonCodable.H76StepModel]()
    /// 24時間心拍数モデル保持用Array
    static var Save24HeartRateModelArray : Any = []
    // MARK: - Private変数
    /// 心拍と24時間心拍の共通getdate
    public static var heartRateGetDate : String = ""
    /// クラス名
    private let className = String(String(describing: CRPSmartBandService.self).split(separator: "-")[0])
    /// ファイル操作クラス
    private let fileUtil = FileUtil()
    // MARK: - Public Methods
    /// イニシャライザ
    init(){
    }
    
    /// ペアリングデータJSON作成
    func CreatePairingSendDataJson(firmwareVersion : String, deviceId : String, deviceAddress : String, sendDataType : Int) -> Data{
        //デバイスアドレスから「:」を除去
        let deviceADR = deviceAddress.replacingOccurrences(of: ":", with: "")
        // @@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDevicePairingInfoJson(firmwareVersion: firmwareVersion, deviceId: deviceId, deviceAddress: deviceADR, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    
    /// 心拍数データCSV出力
    func HeartRateDataCsvOutput(deviceNameKey : String, heartRate: Int){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_WatchHeartRateData_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + String(heartRate)
            
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.HeartRateDataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
            
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
        // 現在日付 - 2日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
        for file in allFiles{

            // 10日前以前のログファイルを削除する
            if file.contains("WatchHeartRateData") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
}
    
    /// 心拍数データJSON作成
    func CreateHeartRateSendDataJson(heartRate: Int, deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String,sendDataType : Int) -> Data{
        
        // デバイス情報JSON作成
//        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // @@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createHeartRateDataJson(heartRate: heartRate)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 血圧データCSV出力
    func BloodDataCsvOutput(deviceNameKey : String, heartRate: Int, sbp: Int, dbp: Int){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_WatchBloodData_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  ","
        writeData.append(String(heartRate))
        writeData.append(",")
        writeData.append(String(sbp))
        writeData.append(",")
        writeData.append(String(dbp))
        
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.BloodDataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        //print(csvWriteData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
        // 現在日付 - 2日　を取得する
        // MEMO:10日→2日
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
        for file in allFiles{
            // ７日前以前のログファイルを削除する
            if file.contains("WatchBloodData") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 血圧データJSON作成
    func CreateBloodSendDataJson(heartRate: Int, sbp: Int, dbp: Int, deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String,sendDataType : Int) -> Data{
        
        // デバイス情報JSON作成
//        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // @@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createBloodDataJson(heartRate: heartRate, sbp: sbp, dbp: dbp)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// SPO2データ CSV出力
    func Spo2DataCsvOutput(deviceNameKey : String, o2: Int){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_WatchSpo2Data_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + String(o2)
        
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.Spo2DataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
        // 現在日付 - 2日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
        for file in allFiles{
            // ７日前以前のログファイルを削除する
            if file.contains("WatchSpo2Data") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// SPO2データJSON作成
    func CreateSpo2SendDataJson(o2: Int, deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        
        // デバイス情報JSON作成
//        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: "", rssi: "", deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        //@@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createSpo2DataJson(o2: o2)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 歩数データ CSV出力
    func StepDataCsvOutput(deviceNameKey : String, stepData : CommonCodable.H76StepModel){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_WatchStepData_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + String(stepData.step) + "," + String(stepData.calories) + "," + String(stepData.distance) + "," + stepData.getTime
        
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.StepDataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
//         現在日付 - ２日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)

        let logDir = "Receive"

        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}

        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5

        for file in allFiles{
            // ７日前以前のログファイルを削除する
            if file.contains("_WatchStepData") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 歩数データJSON作成
    func CreateStepsSendDataJson(stepsData : CommonCodable.H76StepModel,historyStepData : [Int], deviceId : String, deviceAddress : String, firmwareVersion: String , batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        //デバイスアドレスから「:」を除去
        let deviceADR = deviceAddress.replacingOccurrences(of: ":", with: "")
        
        //
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceADR, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createStepsDataJson(firmwareVersion: firmwareVersion, stepsData: stepsData, historyStepdata: historyStepData)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    /// 24時間心拍数データ CSV出力
    func HeartRate24DataCsvOutput(deviceNameKey : String, heartRate24Data : [Int]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_Watch24HeartRateData_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        let heartRate24DataStr = heartRate24Data.map{String($0)}


        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + heartRate24DataStr.joined(separator: ",")
        
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.HeartRate24DataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
//         現在日付 - ２日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)

        let logDir = "Receive"

        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}

        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5

        for file in allFiles{
            // ７日前以前のログファイルを削除する
            if file.contains("_Watch24HeartRateData") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 24時間心拍数データJSON作成
    func Create24HeartRateSendDataJson(YesterdayHeartRate24Data : [Int], HeartRate24Data : [Int], deviceId : String, deviceAddress : String, firmwareVersion: String , batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        //デバイスアドレスから「:」を除去
        let deviceADR = deviceAddress.replacingOccurrences(of: ":", with: "")
        
        //
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceADR, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.create24HeartRateDataJson(firmwareVersion : firmwareVersion, heartRate24Data: HeartRate24Data, yesterdayHeartRate24Data: YesterdayHeartRate24Data)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    /// 24時間歩数データ CSV出力
    func Step24DataCsvOutput(deviceNameKey : String, step24Data : [Int]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_Watch24StepData_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        let step24DataStr = step24Data.map{String($0)}


        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + step24DataStr.joined(separator: ",")
        
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.Step24DataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
//         現在日付 - ２日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)

        let logDir = "Receive"

        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}

        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5

        for file in allFiles{
            // ７日前以前のログファイルを削除する
            if file.contains("_Watch24StepData") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 24時間歩数データJSON作成
    func Create24StepSendDataJson(YesterDayStep24Data : [Int], Step24Data : [Int], deviceId : String, deviceAddress : String, firmwareVersion: String , batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        //デバイスアドレスから「:」を除去
        let deviceADR = deviceAddress.replacingOccurrences(of: ":", with: "")
        
        //
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceADR, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.create24StepDataJson(firmwareVersion : firmwareVersion,  step24Data: Step24Data, yesterDayStep24Data : YesterDayStep24Data)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 睡眠データ CSV出力
    func SleepDataCsvOutput(deviceNameKey : String, sleepDetail: [[String : String]]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_WatchTodaySleepData_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")

        var awake = 0
        var lightSleep = 0
        var deepSleep = 0
        var sleepTime = "0"
        var sleepType = ""

        for arraySleepData in sleepDetail {
            ///配列からデータ抽出
            for data in arraySleepData {
                if data.key == "total" {
                    print(data.value)
                    sleepTime = data.value
                }
                
                if data.key == "type" {
                    print(data.value)
                    sleepType = data.value
                }
            }
            
            switch sleepType {
                case "0":
                    awake = awake + Int(sleepTime)!
                    break
                case "1":
                    lightSleep = lightSleep + Int(sleepTime)!
                    break
                case "2":
                    deepSleep = deepSleep + Int(sleepTime)!
                    break
                default:
                    break
            }
        }
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + String(awake) + "," + String(lightSleep) + "," + String(deepSleep)
        
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.SleepDataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
//         現在日付 - ２日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)

        let logDir = "Receive"

        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}

        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5

        for file in allFiles{
            // ７日前以前のログファイルを削除する
            if file.contains("_WatchTodaySleepData") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 睡眠履歴データ CSV出力
    func SleepHistoryDataCsvOutput(deviceNameKey : String, sleepHistoryData : [[String : String]]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "\(deviceNameKey.replacingOccurrences(of: ":", with: "-"))_WatchSleepHistoryData_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        let receiveFileName = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        let historySleepDataStr = String(describing:sleepHistoryData)


        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + historySleepDataStr
        
        if csvWriteData == "" {
            csvWriteData = WatchConst.CsvFileHeader.CRPSmartBand.SleepHistoryDataCsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
//         現在日付 - ２日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)

        let logDir = "Receive"

        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}

        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5

        for file in allFiles{
            // ７日前以前のログファイルを削除する
            if file.contains("_WatchSleepHistoryData") {
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
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 睡眠データJSON作成
    func CreateSleepSendDataJson(sleepDetail: [[String : String]], deviceId : String, deviceAddress : String, firmwareVersion: String , batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        //デバイスアドレスから「:」を除去
        let deviceADR = deviceAddress.replacingOccurrences(of: ":", with: "")
        
        //@@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceADR, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createSleepDataJson(firmwareVersion : firmwareVersion, sleepData: sleepDetail)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 睡眠履歴データJSON作成
    func CreateSleepHistorySendDataJson(sleepDetail: [[String : String]],sleepHistoryDetail: [[String : String]], deviceId : String, deviceAddress : String, firmwareVersion: String , batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        //デバイスアドレスから「:」を除去
        let deviceADR = deviceAddress.replacingOccurrences(of: ":", with: "")
        
        //@@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceADR, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createSleepHistoryDataJson(firmwareVersion : firmwareVersion, sleepData: sleepDetail, sleepHistory: sleepHistoryDetail)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    ///心拍、血圧、SPO2 Json作成
    func createCRPSendDateJson(heartRate: Int, sbp: Int, dbp: Int, o2: Int, deviceId : String, deviceAddress : String, firmwareVersion : String, batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        //デバイスアドレスから「:」を除去
        let deviceADR = deviceAddress.replacingOccurrences(of: ":", with: "")
        
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceADR, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        
        // データJSON作成
        let dataJson = self.createCRPDataJson(firmwareVersion : firmwareVersion, heartRate: heartRate, sbp: sbp, dbp: dbp, o2: o2)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    // MARK: - Private Methods
    
    /// 心拍数データJSON作成
    private func createHeartRateDataJson(heartRate: Int)->Data{
        
//        var codable = WatchCodable()
//        var deviceData = CommonCodable.Data()
//
//        // デバイスデータ取得日時(YYYYMMDDhhmmss)
//        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
//        //心拍数
//        deviceData.DATA = String(heartRate)
//        codable.DEVICE.append(deviceData)
//        //血圧(高)
//        deviceData.DATA = ""
//        codable.DEVICE.append(deviceData)
//        //血圧(低)
//        deviceData.DATA = ""
//        codable.DEVICE.append(deviceData)
//        //血中酸素濃度(SpO2)
//        deviceData.DATA = ""
//        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
        var codable = CommonCodable.BloodPressuresMonitorCodable()
        // データ取得日時(YYYYMMDDhhmmss+n)
        codable.TM = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        ///血圧(高)
        codable.BP_H = ""
        ///血圧(低)
        codable.BP_L = ""
        ///心拍数
        codable.PLS = String(heartRate)
        // <--
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 血圧データJSON作成
    private func createBloodDataJson(heartRate: Int, sbp: Int, dbp: Int)->Data{
        
//        var codable = WatchCodable()
//        var deviceData = CommonCodable.Data()
//
//        // デバイスデータ取得日時(YYYYMMDDhhmmss)
//        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
//        //心拍数
//        deviceData.DATA = String(heartRate)
//        codable.DEVICE.append(deviceData)
//        //血圧(高)
//        deviceData.DATA = String(sbp)
//        codable.DEVICE.append(deviceData)
//        //血圧(低)
//        deviceData.DATA = String(dbp)
//        codable.DEVICE.append(deviceData)
//        //血中酸素濃度(SpO2)
//        deviceData.DATA = ""
//        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
        var codable = CommonCodable.BloodPressuresMonitorCodable()
        // データ取得日時(YYYYMMDDhhmmss+n)
        codable.TM = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        ///血圧(高)
        codable.BP_H = String(sbp)
        ///血圧(低)
        codable.BP_L = String(dbp)
        ///心拍数
        codable.PLS = String(heartRate)
        // <--
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    /// SPO2データJSON作成
    private func createSpo2DataJson(o2: Int)->Data{
        
//        var codable = WatchCodable()
//        var deviceData = CommonCodable.Data()
//
//        // デバイスデータ取得日時(YYYYMMDDhhmmss)
//        codable.GET_DATE = ConvertUtil.UnixTimeToDateString(unixTime: combined.StartTimeUnixTime,format: "yyyyMMddhhmmss")
//        //心拍数
//        deviceData.DATA = ""
//        codable.DEVICE.append(deviceData)
//        //血圧(高)
//        deviceData.DATA = ""
//        codable.DEVICE.append(deviceData)
//        //血圧(低)
//        deviceData.DATA = ""
//        codable.DEVICE.append(deviceData)
//        //血中酸素濃度(SpO2)
//        deviceData.DATA = String(o2)
//        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
        var codable = CommonCodable.WatchCodable.Spo2()
        /// データ取得日時(YYYYMMDDhhmmss+n)
        codable.TM = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        // SpO2
        codable.SPO2 = String(o2)
        // <--
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    ///歩数データJSON作成
    private func createStepsDataJson(firmwareVersion: String, stepsData : CommonCodable.H76StepModel, historyStepdata: [Int]) -> Data{
        var codable = HistoryWatchCodable()
        var deviceData = CommonCodable.Data()
        var historyData = CommonCodable.Data()
        let historyStepdataStr = historyStepdata.map{String($0)}

        ///デバイスファームウェアバージョン
        codable.FIRMWARE_VERSION = firmwareVersion
        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        // 歩数履歴
        historyData.DATA = "Today steps=[" + historyStepdataStr.joined(separator: ",") + "]"
        codable.HISTORY.append(historyData)
        deviceData.DATA = stepsData.getTime + "," + String(stepsData.step) + "," + String(stepsData.calories) + "," + String(stepsData.distance)
        codable.DEVICE.append(deviceData)
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }

    ///24時間心拍数データJSON作成
    private func create24HeartRateDataJson(firmwareVersion: String, heartRate24Data : [Int], yesterdayHeartRate24Data : [Int]) -> Data{
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()
        let heartRate24DataStr = heartRate24Data.map{String($0)}
        let yesterdayHeartRate24DataStr = yesterdayHeartRate24Data.map{String($0)}
        
        ///デバイスファームウェアバージョン
        codable.FIRMWARE_VERSION = firmwareVersion
        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = CRPSmartBandService.heartRateGetDate
        if codable.GET_DATE == ""{
            let time = (DateUtil.GetDateFormatConvert(format: "mm"))
            let timeInt = Int(time) ?? 0
            let fixedTime = String(Int(floor(Double(timeInt/5))*5))
            let date = (DateUtil.GetDateFormatConvert(format: "yyyyMMddHH"))
            let getdate = date + fixedTime + "00"
            codable.GET_DATE = getdate
            //codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
            CRPSmartBandService.heartRateGetDate = String(describing:codable.GET_DATE)
        }
        let todayDate = DateUtil.getFormattedDateString(dateString: codable.GET_DATE)
        //var todayDateStr = (todayDate?.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: ""))
        let todayDateStr = String(describing:todayDate)
        
        deviceData.DATA = "Yesterday heart.count=\(yesterdayHeartRate24Data.count), [" + yesterdayHeartRate24DataStr.joined(separator: ",") + "], \(todayDateStr) Today heart.count=\(heartRate24Data.count), [" + heartRate24DataStr.joined(separator: ",") + "]"
        codable.DEVICE.append(deviceData)
        
        CommonUtil.Print(className: self.className, message:"CRPSmartBandService.heartRateGetDate:\(CRPSmartBandService.heartRateGetDate) codable.GET_DATE:\(codable.GET_DATE) todayDate:\(todayDate) todayDateStr:\(todayDateStr)")
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    ///24時間歩数データJSON作成
    private func create24StepDataJson(firmwareVersion: String, step24Data : [Int], yesterDayStep24Data : [Int]) -> Data{
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()
        let step24DataStr = step24Data.map{String($0)}
        let yesterdaystep24DataStr = yesterDayStep24Data.map{String($0)}
        ///デバイスファームウェアバージョン
        codable.FIRMWARE_VERSION = firmwareVersion
        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        
        deviceData.DATA = "Yesterday steps=[" + yesterdaystep24DataStr.joined(separator: ",") + "], Today steps=[" +  step24DataStr.joined(separator: ",") + "]"
        codable.DEVICE.append(deviceData)
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 睡眠データJSON作成
    private func createSleepDataJson(firmwareVersion: String, sleepData: [[String : String]])->Data{
        var codable = HistoryWatchCodable()
        var deviceData = CommonCodable.Data()
        var historyData = CommonCodable.Data()
        var awake = 0
        var lightSleep = 0
        var deepSleep = 0
        var sleepTime = "0"
        var sleepType = ""
        //let historySleepDataStr = String(describing:sleepData).replacingOccurrences(of: "\"", with: "\\\"")
        let historySleepDataStr = String(describing:sleepData)
        //print(sleepData)
        //print(historySleepdataStr)
        ///デバイスファームウェアバージョン
        codable.FIRMWARE_VERSION = firmwareVersion
        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        // 睡眠生データ
        historyData.DATA = (historySleepDataStr)
        codable.HISTORY.append(historyData)
        for arraySleepData in sleepData {
            ///配列からデータ抽出
            for data in arraySleepData {
                if data.key == "total" {
                    print(data.value)
                    sleepTime = data.value
                }
                
                if data.key == "type" {
                    print(data.value)
                    sleepType = data.value
                }
            }
            
            switch sleepType {
                case "0":
                    awake = awake + Int(sleepTime)!
                    break
                case "1":
                    lightSleep = lightSleep + Int(sleepTime)!
                    break
                case "2":
                    deepSleep = deepSleep + Int(sleepTime)!
                    break
                default:
                    break
            }
                
            print(lightSleep)
        }
        deviceData.DATA = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss") + "," + String(awake) + "," + String(lightSleep) + "," + "0" + "," + String(deepSleep)
        codable.DEVICE.append(deviceData)
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 睡眠履歴データJSON作成
    private func createSleepHistoryDataJson(firmwareVersion: String, sleepData: [[String : String]], sleepHistory:[[String : String]])->Data{
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()
        //let historySleepDataStr = String(describing:sleepHistory).replacingOccurrences(of: "\"", with: "\\\"")
        //let todaySleepDataStr = String(describing:sleepData).replacingOccurrences(of: "\"", with: "\\\"")
        let historySleepDataStr = String(describing:sleepHistory)
        let todaySleepDataStr = String(describing:sleepData)
        ///デバイスファームウェアバージョン
        codable.FIRMWARE_VERSION = firmwareVersion
        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        // 睡眠生データ
//        historyData.DATA = (historySleepdataStr)
//        codable.HISTORY.append(historyData)
//        deviceData.DATA = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss") + "," + String(awake) + "," + String(lightSleep) + "," + "0" + "," + String(deepSleep)
        deviceData.DATA = "Yesterday sleep=" + historySleepDataStr + ", Today sleep=" +  todaySleepDataStr
        codable.DEVICE.append(deviceData)
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    func createCRPDataJson(firmwareVersion : String, heartRate: Int, sbp: Int, dbp: Int, o2:Int) -> Data{
        
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()
        ///デバイスファームウェアバージョン
        codable.FIRMWARE_VERSION = firmwareVersion
        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        if CRPSmartBandService.heartRateGetDate == ""{
        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        }else {
            codable.GET_DATE = CRPSmartBandService.heartRateGetDate
        }
        //心拍数
        if heartRate == 0 {
            deviceData.DATA = ""
            codable.DEVICE.append(deviceData)
        }else{
        deviceData.DATA = String(heartRate)
        codable.DEVICE.append(deviceData)
            }
        //血圧(高)
        if sbp == 0 {
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        }else{
            deviceData.DATA = String(sbp)
            codable.DEVICE.append(deviceData)
            }
        //血圧(低)
        if dbp == 0 {
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        }else{
            deviceData.DATA = String(dbp)
            codable.DEVICE.append(deviceData)
            }
        //血中酸素濃度(SpO2)
        if o2 == 0{
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        }else{
            deviceData.DATA = String(o2)
            codable.DEVICE.append(deviceData)
            }
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codable) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
}
