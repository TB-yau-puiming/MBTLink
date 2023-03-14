//
// BloodPressuresMonitorService.swift
// A&D 血圧計 UA-651BLE関連サービス
//
// MBTLink
//

import Foundation

class BloodPressuresMonitorService : MeasuringInstrumentBaseService {
    /// クラス名
    private let className = String(String(describing: ( BloodPressuresMonitorService.self)).split(separator: "-")[0])
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
    }
    
    /// 血圧測定データ取得
    func GetBloodPressureMeasurementData(data : Data) -> BloodPressuresMonitorDto{
        
        var bloodPressureMeasurementData = BloodPressuresMonitorDto()
        
        // Flags
        bloodPressureMeasurementData.Flags = ConvertUtil.BinaryNumberZeroPadding(uint: data[0])
        // 最高血圧
        bloodPressureMeasurementData.SystolicPressure = ConvertUtil.HexadecimalJoin(uint1: data[1], uint2: data[2])
        // 最低血圧
        bloodPressureMeasurementData.DiastolicPressure = ConvertUtil.HexadecimalJoin(uint1: data[3], uint2: data[4])
        // 平均血圧
        bloodPressureMeasurementData.MeanArterialPressure = ConvertUtil.HexadecimalJoin(uint1: data[5], uint2: data[6])
        
        let timeStampFlag = StringUtil.SubString(text:bloodPressureMeasurementData.Flags, from:6,length:1)
        
        if timeStampFlag == "1"{
            let year = ConvertUtil.HexadecimalJoin(uint1: data[7], uint2: data[8])
            let month = ConvertUtil.ZeroPadding(str: String(data[9]))
            let day = ConvertUtil.ZeroPadding(str:String(data[10]))
            let hour = ConvertUtil.ZeroPadding(str:String(data[11]))
            let minutes = ConvertUtil.ZeroPadding(str:String(data[12]))
            let seconds = ConvertUtil.ZeroPadding(str:String(data[13]))
            
            //タイムスタンプ
            bloodPressureMeasurementData.TimeStamp = String(format: "%@-%@-%@ %@:%@:%@"
                ,year,month,day,hour,minutes,seconds)
            //タイムスタンプ(YYYYMMDDhhmmss)
            bloodPressureMeasurementData.TimeStampYMDhms = String(format: "%@%@%@%@%@%@"
                ,year,month,day,hour,minutes,seconds)
            //脈拍
            bloodPressureMeasurementData.PulseRate = ConvertUtil.HexadecimalJoin(uint1: data[14], uint2: data[15])
        
        }
        else{
            //脈拍
            bloodPressureMeasurementData.PulseRate = ConvertUtil.HexadecimalJoin(uint1: data[7], uint2: data[8])
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return bloodPressureMeasurementData
    }
    
    /// 血圧測定データカンマ区切り取得
    func GetBloodPressureMeasurementDataComma(data : Data) -> String{
        
        var ret : String = ""
        let bloodPressureMeasurementData = self.GetBloodPressureMeasurementData(data: data)
        
        //最高血圧
        ret.append(bloodPressureMeasurementData.SystolicPressure)
        ret.append(",")
        //最低血圧
        ret.append(bloodPressureMeasurementData.DiastolicPressure)
        ret.append(",")
        //平均血圧
        ret.append(bloodPressureMeasurementData.MeanArterialPressure)
        ret.append(",")
        //タイムスタンプ
        ret.append(bloodPressureMeasurementData.TimeStamp)
        ret.append(",")
        //脈拍
        ret.append(bloodPressureMeasurementData.PulseRate)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// CSV出力
    func CsvOutput(data : Data){
        // CSVファイル名
        let csvFileNameStr : String = "BloodPressuresMonitor_"
        let csvFileName : String = csvFileNameStr + DateUtil.GetDateFormatConvert(format: "yyyyMMdd") + ".txt"
        let receiveFileName : String = CommonConst.ReceiveDir + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString +  "," + self.GetBloodPressureMeasurementDataComma(data: data)
        
        if csvWriteData == "" {
            csvWriteData = BloodPressuresMonitorConst.CsvFileHeader
        }

        csvWriteData.append("\n")
        csvWriteData.append(writeData)
        
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        //ファイル削除
        self.fileUtil.fileDel(csvFileNameStr: csvFileNameStr, targetFile: csvFileNameStr)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Private Methods
    /// デバイス情報JSON作成
    internal override func createDeviceInfoJson(deviceAddress : String, batteryLevel: String, rssi: String, sendDataType : Int)->Data{
        // デバイス情報JSON作成
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: BloodPressuresMonitorConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.BloodPressuresMonitor.rawValue, sendDataType: sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    /// データJSON作成
    internal override func createDataJson(data : Data)->Data{
        
        let bloodPressureMeasurementData = self.GetBloodPressureMeasurementData(data: data)
        
        var codable = BloodPressuresMonitorCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        if bloodPressureMeasurementData.TimeStampYMDhms == "" {
            codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        }
        else{
            codable.GET_DATE = bloodPressureMeasurementData.TimeStampYMDhms
        }
        //血圧(高)
        deviceData.DATA = bloodPressureMeasurementData.SystolicPressure
        codable.DEVICE.append(deviceData)
        //血圧(低)
        deviceData.DATA = bloodPressureMeasurementData.DiastolicPressure
        codable.DEVICE.append(deviceData)
        //心拍数
        deviceData.DATA = bloodPressureMeasurementData.PulseRate
        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.BloodPressuresMonitorCodable()
//        /// データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = bloodPressureMeasurementData.TimeStampYMDhms
//        ///血圧(高)
//        codable.BP_H = bloodPressureMeasurementData.SystolicPressure
//        ///血圧(低)
//        codable.BP_L = bloodPressureMeasurementData.DiastolicPressure
//        ///心拍数
//        codable.PLS = bloodPressureMeasurementData.PulseRate
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
    
    /// 測定データエラー判定
    func isErrorData(data : Data) -> Bool {
        var errorFlg = false
        //体温
        let systolicPressure = Double(data[1])

        if(systolicPressure == BloodPressuresMonitorConst.measurementErrorData){
            errorFlg = true
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return errorFlg
    }
}
