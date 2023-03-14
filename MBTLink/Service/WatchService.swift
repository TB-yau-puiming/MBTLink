//
// WatchService.swift
// LANCEBAND2,3関連サービス
//
//  MBTLink
//

import Foundation

final class WatchService {
    
    // MARK: - Private変数
    /// ファイル操作クラス
    private let fileUtil = FileUtil()
    /// クラス名
    private let className = String(String(describing: ( WatchService.self)).split(separator: "-")[0])
    
    // MARK: - Public Methods
    /// イニシャライザ
    init(){
    }
    
    /// 履歴データ歩数取得
    func GetHistoryDataStep(row : [String:Any]) -> WatchDto.Step{
        
        var step = WatchDto.Step()
        
        /// テスト開始時間（UNIX時間）
        step.StartTimeUnixTime = String(describing:row["keyStartTime"]!)
        /// テスト開始時間
        step.StartTime = ConvertUtil.UnixTimeToDateString(unixTime: step.StartTimeUnixTime)
        /// テスト終了時間（UNIX時間）
        step.EndTimeUnixTime = String(describing:row["keyEndTime"]!)
        /// テスト終了時間
        step.EndTime = ConvertUtil.UnixTimeToDateString(unixTime: step.EndTimeUnixTime)
        /// 歩数
        step.Step = String(describing:row["keyStep"]!)
        /// カロリー（単位:Kca）
        step.Calories = String(describing:row["keyCalories"]!)
        /// 距離（単位:メートル）
        step.Distance = String(describing:row["keyDistance"]!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return step
    }
    /// 履歴データ歩数カンマ取得
    func GetHistoryDataStepComma(row : [String:Any]) -> String{
        
        var ret : String = ""
        
        let step = self.GetHistoryDataStep(row: row)
        /// テスト開始時間（UNIX時間）
        ret.append(step.StartTimeUnixTime)
        ret.append(",")
        /// テスト終了時間（UNIX時間）
        ret.append(step.EndTimeUnixTime)
        ret.append(",")
        /// テスト開始時間
        ret.append(step.StartTime)
        ret.append(",")
        /// テスト終了時間
        ret.append(step.EndTime)
        ret.append(",")
        /// 歩数
        ret.append(step.Step)
        ret.append(",")
        ///カロリー（単位:Kca）
        ret.append(step.Calories)
        ret.append(",")
        ///距離（単位:メートル）
        ret.append(step.Distance)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    /// 履歴データ歩数CSV出力
    func HistoryDataStepCsvOutput(deviceName : String, rows : [[String:Any]]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileName = "\(deviceName)_WatchHistoryDataStep_\(nowDate).txt"
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
        
        for row in rows {
            
            writeData = dateString +  "," + self.GetHistoryDataStepComma(row: row)
            
            if csvWriteData == "" {
                csvWriteData = WatchConst.CsvFileHeader.Lanceband.HistoryDataStepCsvFileHeader
            }

            csvWriteData.append("\n")
            csvWriteData.append(writeData)
            
            // ファイル書き込み
            self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        }
    }
    
    /// 履歴データ歩数JSON作成
    func CreateHistoryDataStepSendDataJson(rows : [[String:Any]], deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        
        // デバイス情報JSON作成
//        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // @@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: "MBT01", deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createHistoryDataStepDataJson(rows: rows)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 履歴データ心拍数取得
    func GetHistoryDataHeart(row : [String:Any]) -> WatchDto.Heart{
        
        var heart = WatchDto.Heart()
        
        /// テスト開始時間（UNIX時間）
        heart.StartTimeUnixTime = String(describing:row["keyStartTime"]!)
        /// テスト開始時間
        heart.StartTime = ConvertUtil.UnixTimeToDateString(unixTime: heart.StartTimeUnixTime)
        /// 心拍数
        heart.HeartNum = String(describing:row["keyHeartNum"]!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return heart
    }
    
    /// 履歴データ心拍数カンマ取得
    func GetHistoryDataHeartComma(row : [String:Any]) -> String{
        
        var ret : String = ""
        
        let heart = self.GetHistoryDataHeart(row: row)
        /// テスト開始時間（UNIX時間）
        ret.append(heart.StartTimeUnixTime)
        ret.append(",")
        /// テスト開始時間
        ret.append(heart.StartTime)
        ret.append(",")
        /// 心拍数
        ret.append(heart.HeartNum)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    /// 履歴データ心拍数CSV出力
    func HistoryDataHeartCsvOutput(deviceName : String, rows : [[String:Any]]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileName = "\(deviceName)_WatchHistoryDataHeart_\(nowDate).txt"
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
        
        for row in rows {
            
            writeData = dateString +  "," + self.GetHistoryDataHeartComma(row: row)
            
            if csvWriteData == "" {
                csvWriteData = WatchConst.CsvFileHeader.Lanceband.HistoryDataHeartCsvFileHeader
            }

            csvWriteData.append("\n")
            csvWriteData.append(writeData)
            
            // ファイル書き込み
            self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 履歴データ心拍数JSON作成
    func CreateHistoryDataHeartSendDataJson(row : [String:Any], deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String,sendDataType : Int) -> Data{
        
        // デバイス情報JSON作成
//        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // @@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: "MBT01", deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createHistoryDataHeartDataJson(row: row)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 履歴データ血圧取得
    func GetHistoryDataBlood(row : [String:Any]) -> WatchDto.Blood{
        
        var blood = WatchDto.Blood()
        
        /// テスト開始時間（UNIX時間）
        blood.StartTimeUnixTime = String(describing:row["keyStartTime"]!)
        /// テスト開始時間
        blood.StartTime = ConvertUtil.UnixTimeToDateString(unixTime: blood.StartTimeUnixTime)
        /// 収縮期血圧
        blood.Sbp = String(describing:row["keyDBP"]!)
        /// 拡張期血圧
        blood.Dbp = String(describing:row["keySBP"]!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return blood
    }
    
    /// 履歴データ血圧カンマ取得
    func GetHistoryDataBloodComma(row : [String:Any]) -> String{
        
        var ret : String = ""
        
        let blood = self.GetHistoryDataBlood(row: row)
        
        /// テスト開始時間（UNIX時間）
        ret.append(blood.StartTimeUnixTime)
        ret.append(",")
        /// テスト開始時間
        ret.append(blood.StartTime)
        ret.append(",")
        /// 収縮期血圧
        ret.append(blood.Sbp)
        ret.append(",")
        /// 拡張期血圧
        ret.append(blood.Dbp)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// 履歴データ血圧CSV出力
    func HistoryDataBloodCsvOutput(deviceName : String, rows : [[String:Any]]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileName = "\(deviceName)_WatchHistoryDataBlood_\(nowDate).txt"
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
        
        for row in rows {
            
            writeData = dateString +  "," + self.GetHistoryDataBloodComma(row: row)
            
            if csvWriteData == "" {
                csvWriteData = WatchConst.CsvFileHeader.Lanceband.HistoryDataBloodCsvFileHeader
            }

            csvWriteData.append("\n")
            csvWriteData.append(writeData)
            
            // ファイル書き込み
            self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 履歴データ血圧JSON作成
    func CreateHistoryDataBloodSendDataJson(row : [String:Any], deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String,sendDataType : Int) -> Data{
        
        // デバイス情報JSON作成
//        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // @@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: "MBT01", deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createHistoryDataBloodDataJson(row: row)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 履歴データ総合取得
    func GetHistoryDataCombined(row : [String:Any]) -> WatchDto.Combined{
        
        var combined = WatchDto.Combined()
        
        /// テスト開始時間（UNIX時間）
        combined.StartTimeUnixTime = String(describing:row["keyStartTime"]!)
        /// テスト開始時間
        combined.StartTime = ConvertUtil.UnixTimeToDateString(unixTime: combined.StartTimeUnixTime)
        /// 歩数（単位:歩）
        combined.Step = String(describing:row["keyStep"]!)
        /// 心拍数
        combined.HeatRate = String(describing:row["keyHeatRate"]!)
        /// 収縮期血圧
        combined.Sbp = String(describing:row["keyDBP"]!)
        /// 拡張期血圧
        combined.Dbp = String(describing:row["keySBP"]!)
        /// 血中酸素濃度（SPO2）
        combined.Spo2 = String(describing:row["keyOO"]!)
        /// 呼吸数
        combined.RespiratoryRate = String(describing:row["keyRespiratoryRate"]!)
        /// HRV值
        combined.Hrv = String(describing:row["keyHRV"]!)
        /// CVRR值
        combined.Cvrr = String(describing:row["keyCVRR"]!)
        /// 摂氏温度の整数部分
        combined.TmepInt = String(describing:row["keyTmepInt"]!)
        /// 摂氏温度の小数部分
        combined.TmepFloat = String(describing:row["keyTmepFloat"]!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return combined
    }
    
    /// 履歴データSPO2カンマ取得
    func GetHistoryDataSpo2Comma(row : [String:Any]) -> String{
        
        var ret : String = ""
        
        let combined = self.GetHistoryDataCombined(row: row)
        
        /// テスト開始時間（UNIX時間）
        ret.append(combined.StartTimeUnixTime)
        ret.append(",")
        /// テスト開始時間
        ret.append(combined.StartTime)
        ret.append(",")
        /// SPO2
        ret.append(combined.Spo2)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// 履歴データSPO2 CSV出力
    func HistoryDataSpo2CsvOutput(deviceName : String, rows : [[String:Any]]){
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileName = "\(deviceName)_WatchHistoryDataSpo2_\(nowDate).txt"
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
        
        for row in rows {
            
            writeData = dateString +  "," + self.GetHistoryDataSpo2Comma(row: row)
            
            if csvWriteData == "" {
                csvWriteData = WatchConst.CsvFileHeader.Lanceband.HistoryDataSpo2CsvFileHeader
            }

            csvWriteData.append("\n")
            csvWriteData.append(writeData)
            
            // ファイル書き込み
            self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 履歴データ総合JSON作成
    func CreateHistoryDataCombinedSendDataJson(row : [String:Any], deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String, sendDataType : Int) -> Data{
        
        // デバイス情報JSON作成
//        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: "", rssi: "", deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        //@@@旧フォーマット
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: "MBT01", deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.SmartWatch.rawValue, sendDataType: sendDataType)
        
        // データJSON作成
        let dataJson = self.createHistoryDataCombinedDataJson(row: row)
        
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    
    
    // MARK: - Private Methods
    /// 歩数データJSON作成
    private func createHistoryDataStepDataJson(rows : [[String:Any]])->Data{
        
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddhhmmss")

        for row in rows{
            let step = self.GetHistoryDataStep(row: row)
            deviceData.DATA = String(format: "%@,%@,%@",ConvertUtil.UnixTimeToDateString(unixTime: step.EndTimeUnixTime,format: "yyyyMMddhhmmss"), step.Step,step.Calories)
            codable.DEVICE.append(deviceData)
        }

        // @@@旧フォーマット -->
//        var codable = CommonCodable.WatchCodable.Step()
//        var deviceData = CommonCodable.OldData()
//        // データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
//
//        for row in rows{
//            let step = self.GetHistoryDataStep(row: row)
//            let tm = ConvertUtil.UnixTimeToDateString(unixTime: step.EndTimeUnixTime,format: "yyyyMMddHHmmss")
//            ///歩数情報
//            deviceData.DT = "\(tm),\(step.Step)"
//            codable.Step.append(deviceData)
//            ///歩行距離情報
//            deviceData.DT = "\(tm),\(step.Distance)"
//            codable.Dstn.append(deviceData)
//            ///消費カロリー情報
//            deviceData.DT = "\(tm),\(step.Calories)"
//            codable.Cal.append(deviceData)
//        }
        
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
    
    /// 心拍数データJSON作成
    private func createHistoryDataHeartDataJson(row : [String:Any])->Data{
        
        let heart = self.GetHistoryDataHeart(row: row)
        
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = ConvertUtil.UnixTimeToDateString(unixTime: heart.StartTimeUnixTime,format: "yyyyMMddhhmmss")
        //心拍数
        deviceData.DATA = heart.HeartNum
        codable.DEVICE.append(deviceData)
        //血圧(高)
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        //血圧(低)
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        //血中酸素濃度(SpO2)
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.BloodPressuresMonitorCodable()
//        // データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = ConvertUtil.UnixTimeToDateString(unixTime: heart.StartTimeUnixTime,format: "yyyyMMddHHmmss")
//        ///血圧(高)
//        codable.BP_H = ""
//        ///血圧(低)
//        codable.BP_L = ""
//        ///心拍数
//        codable.PLS = heart.HeartNum
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
    private func createHistoryDataBloodDataJson(row : [String:Any])->Data{
        
        let blood = self.GetHistoryDataBlood(row: row)
        
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = ConvertUtil.UnixTimeToDateString(unixTime: blood.StartTimeUnixTime,format: "yyyyMMddhhmmss")
        //心拍数
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        //血圧(高)
        deviceData.DATA = blood.Sbp
        codable.DEVICE.append(deviceData)
        //血圧(低)
        deviceData.DATA = blood.Dbp
        codable.DEVICE.append(deviceData)
        //血中酸素濃度(SpO2)
        deviceData.DATA = ""
        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.BloodPressuresMonitorCodable()
//        // データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = ConvertUtil.UnixTimeToDateString(unixTime: blood.StartTimeUnixTime,format: "yyyyMMddHHmmss")
//        ///血圧(高)
//        codable.BP_H = blood.Sbp
//        ///血圧(低)
//        codable.BP_L = blood.Dbp
//        ///心拍数
//        codable.PLS = ""
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
    private func createHistoryDataCombinedDataJson(row : [String:Any])->Data{
        
        let combined = self.GetHistoryDataCombined(row: row)
        
        var codable = WatchCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = ConvertUtil.UnixTimeToDateString(unixTime: combined.StartTimeUnixTime,format: "yyyyMMddhhmmss")
        //心拍数
        deviceData.DATA = combined.HeatRate
        codable.DEVICE.append(deviceData)
        //血圧(高)
        deviceData.DATA = combined.Dbp
        codable.DEVICE.append(deviceData)
        //血圧(低)
        deviceData.DATA = combined.Sbp
        codable.DEVICE.append(deviceData)
        //血中酸素濃度(SpO2)
        deviceData.DATA = combined.Spo2
        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.WatchCodable.Spo2()
//        /// データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = ConvertUtil.UnixTimeToDateString(unixTime: combined.StartTimeUnixTime,format: "yyyyMMddHHmmss")
//        // SpO2
//        codable.SPO2 = combined.Spo2
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
}
