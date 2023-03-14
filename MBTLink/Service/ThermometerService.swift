//
// ThermometerService.swift
// A&D 体温計 UT-201BLE関連サービス
//
// MBTLink
//

import Foundation

final class ThermometerService : MeasuringInstrumentBaseService {
    /// クラス名
    private let className = String(String(describing: ( ThermometerService.self)).split(separator: "-")[0])
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
    }
    
    /// 体温データ取得
    func GetBodyTemperatureData(data : Data) -> ThermometerDto{
        
        var bodyTemperatureData = ThermometerDto()
        
        //Flags
        bodyTemperatureData.Flags = ConvertUtil.BinaryNumberZeroPadding(uint: data[0])
        //体温
        bodyTemperatureData.Temperature = self.bodyTemperatureataConvert(data1: data[1], data2: data[2], data3: data[4])
        
        let timeStampFlag = StringUtil.SubString(text:bodyTemperatureData.Flags, from:6,length:1)
        
        if timeStampFlag == "1"{
            let year = ConvertUtil.HexadecimalJoin(uint1: data[5], uint2: data[6])
            let month = ConvertUtil.ZeroPadding(str: String(data[7]))
            let day = ConvertUtil.ZeroPadding(str:String(data[8]))
            let hour = ConvertUtil.ZeroPadding(str:String(data[9]))
            let minutes = ConvertUtil.ZeroPadding(str:String(data[10]))
            let seconds = ConvertUtil.ZeroPadding(str:String(data[11]))
            
            //タイムスタンプ
            bodyTemperatureData.TimeStamp = String(format: "%@-%@-%@ %@:%@:%@"
                ,year,month,day,hour,minutes,seconds)
            //タイムスタンプ(YYYYMMDDhhmmss)
            bodyTemperatureData.TimeStampYMDhms = String(format: "%@%@%@%@%@%@"
                ,year,month,day,hour,minutes,seconds)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return bodyTemperatureData
    }
    
    /// 体温データカンマ区切り取得
    func GetBodyTemperatureDataComma(data : Data) -> String{
        
        var ret : String = ""
        let bodyTemperatureData = self.GetBodyTemperatureData(data: data)
        
        // 体温
        ret.append(bodyTemperatureData.Temperature)
        ret.append(",")
        // タイムスタンプ
        ret.append(bodyTemperatureData.TimeStamp)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// CSV出力
    func CsvOutput(data : Data){
        // CSVファイル名
        let csvFileNameStr : String = "Thermometer_"
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
        
        writeData = dateString +  "," + self.GetBodyTemperatureDataComma(data: data)
        
        if csvWriteData == "" {
            csvWriteData = ThermometerConst.CsvFileHeader
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
    /// 体温データ変換
    private func bodyTemperatureataConvert(data1 : UInt8 , data2 :UInt8, data3 :UInt8 ) -> String{
        
        var ret : String!
        var unit : Double
        var floorUnit : Int
        
        let convData3 : String = ConvertUtil.HexadecimalZeroPadding(uint: data3)
        
        switch convData3 {
        case "ff":
            unit = 0.1
            floorUnit = 10
        case "fe":
            unit = 0.01
            floorUnit = 100
        default:
            unit = 1
            floorUnit = 1
        }
        
        ret = String(floor(Double(ConvertUtil.HexadecimalJoin(uint1: data1, uint2: data2))! * unit * Double(floorUnit)) / Double(floorUnit))
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    /// デバイス情報JSON作成
    internal override func createDeviceInfoJson(deviceAddress : String, batteryLevel: String, rssi: String, sendDataType : Int)->Data{
        
        // デバイス情報JSON作成
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: ThermometerConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.Thermometer.rawValue, sendDataType: sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    /// データJSON作成
    internal override func createDataJson(data : Data)->Data{
        
        let bodyTemperatureData = self.GetBodyTemperatureData(data: data)
        
        var codable = ThermometerCodable()
        var deviceData = CommonCodable.Data()
        
        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        if bodyTemperatureData.TimeStampYMDhms == "" {
            codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        }
        else{
            codable.GET_DATE = bodyTemperatureData.TimeStampYMDhms
        }
        
        //体温
        deviceData.DATA = bodyTemperatureData.Temperature
        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.ThermometerCodable()
//        /// データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = bodyTemperatureData.TimeStampYMDhms
//        ///体温
//        codable.BT = bodyTemperatureData.Temperature
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
        let temperature = Double(self.bodyTemperatureataConvert(data1: data[1], data2: data[2], data3: data[4]))

        if(temperature == ThermometerConst.measurementErrorData){
            errorFlg = true
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return errorFlg
    }
}
