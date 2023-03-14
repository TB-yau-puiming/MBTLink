//
// EnvSensorService.swift
// オムロン 環境センサ 2JCIE-BL01関連サービス
//
//  MBTLink
//

import Foundation

class EnvSensorService : MeasuringInstrumentBaseService{
    /// クラス名
    private let className = String(String(describing: ( EnvSensorService.self)).split(separator: "-")[0])
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
    }
    
    /// センサ最新値取得
    func GetLatestData(data : Data) -> EnvSensorLatestDataDto{
        
        var latestData = EnvSensorLatestDataDto()
        
        // 温度
        latestData.Temperature = self.latestDataConvert(data1: data[1], data2: data[2], unit: 0.01)
        // 相対湿度
        latestData.RelativeHumidity = self.latestDataConvert(data1: data[3], data2: data[4], unit: 0.01)
        // 照度
        latestData.AmbientLight = self.latestDataConvert(data1: data[5], data2: data[6], unit: 1)
        // UV Index
        latestData.UvIndex = self.latestDataConvert(data1: data[7], data2: data[8], unit: 0.01)
        // 気圧
        latestData.Pressure = self.latestDataConvert(data1: data[9], data2: data[10], unit: 0.1)
        // 騒音
        latestData.SoundNoise = self.latestDataConvert(data1: data[11], data2: data[12], unit: 0.01)
        // 不快指数
        latestData.DiscomfortIndex = self.latestDataConvert(data1: data[13], data2: data[14], unit: 0.01)
        // 熱中症危険度
        latestData.FeatStroke = self.latestDataConvert(data1: data[15], data2: data[16], unit: 0.01)
        // 電池電圧
        latestData.SupplyVoltage = self.getSupplyVoltage(data: data)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return latestData
    }
    
    /// センサ最新値カンマ区切り取得
    func GetLatestDataComma(data : Data) -> String{
        
        var ret : String = ""
        let latestData = self.GetLatestData(data: data)
        
        // 温度
        ret.append(latestData.Temperature)
        ret.append(",")
         // 相対湿度
        ret.append(latestData.RelativeHumidity)
        ret.append(",")
        // 照度
        ret.append(latestData.AmbientLight)
        ret.append(",")
         // UV Index
        ret.append(latestData.UvIndex)
        ret.append(",")
         // 気圧
        ret.append(latestData.Pressure)
        ret.append(",")
        // 騒音
        ret.append(latestData.SoundNoise)
        ret.append(",")
        // 不快指数
        ret.append(latestData.DiscomfortIndex)
        ret.append(",")
        // 熱中症危険度
        ret.append(latestData.FeatStroke)
        ret.append(",")
        // 電池電圧
        ret.append(latestData.SupplyVoltage)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// CSV出力
    func CsvOutput(data : Data){
        // CSVファイル名
        let csvFileNameStr : String = "EnvSensor_"
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
        
        writeData = dateString +  "," + self.GetLatestDataComma(data: data)
        
        if csvWriteData == "" {
            csvWriteData = EnvSensorConst.CsvFileHeader
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
    /// センサ最新値変換
    private func latestDataConvert(data1 : UInt8 , data2 :UInt8 , unit : Double) -> String{
        
        var floorUnit : Int
        var ret : String!
        
        switch unit {
        case 1:
            floorUnit = 1
        case 0.1:
            floorUnit = 10
        case 0.01:
            floorUnit = 100
        default:
            floorUnit = 1
        }
        
        if floorUnit == 1{
            ret = String(Int(ConvertUtil.HexadecimalJoin(uint1: data1, uint2: data2))! * Int(unit))
        }
        else
        {
            ret = String(floor(Double(ConvertUtil.HexadecimalJoin(uint1: data1, uint2: data2))! * unit * Double(floorUnit)) / Double(floorUnit))
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// デバイス情報JSON作成
    internal override func createDeviceInfoJson(deviceAddress : String, batteryLevel: String, rssi: String,sendDataType : Int)->Data{
        // デバイス情報JSON作成
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: EnvSensorConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.EnvSensor.rawValue, sendDataType: sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    
    /// データJSON作成
    override internal func createDataJson(data : Data)->Data{
        
        let latestData = self.GetLatestData(data: data)
        
        var codable = EnvSensorCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        
        // 温度
        deviceData.DATA = latestData.Temperature
        codable.DEVICE.append(deviceData)
        // 湿度
        deviceData.DATA = latestData.RelativeHumidity
        codable.DEVICE.append(deviceData)
        // 輝度
        deviceData.DATA = latestData.AmbientLight
        codable.DEVICE.append(deviceData)
        // 騒音
        deviceData.DATA = latestData.SoundNoise
        codable.DEVICE.append(deviceData)
        // 気圧
        deviceData.DATA = latestData.Pressure
        codable.DEVICE.append(deviceData)
        // 不快指数
        deviceData.DATA = latestData.DiscomfortIndex
        codable.DEVICE.append(deviceData)
        // 熱中症警戒度
        deviceData.DATA = latestData.FeatStroke
        codable.DEVICE.append(deviceData)
        // UV Index (BAG型環境センサ[2JCIE-BL01])
        deviceData.DATA = latestData.UvIndex
        codable.DEVICE.append(deviceData)
        print(latestData.SupplyVoltage)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.EnvSensorCodable()
//        /// データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
//        ///温度
//        codable.TEMP = latestData.Temperature
//        ///湿度
//        codable.HUMD = latestData.RelativeHumidity
//        ///輝度
//        codable.BRIT  = latestData.AmbientLight
//        ///騒音
//        codable.NOIS  = latestData.SoundNoise
//        ///UV Index (BAG型環境センサ[2JCIE-BL01])
//        codable.UV  = latestData.UvIndex
//        ///気圧
//        codable.ATMS  = latestData.Pressure
//        ///VOCガス (USB型環境センサ[2JCIE-BU01])
//        codable.VOC  = ""
//        ///不快指数
//        codable.O_RSRV1  = latestData.DiscomfortIndex
//        ///熱中症警戒度
//        codable.O_RSRV2  = latestData.FeatStroke
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
    
    // 計測データから電池電圧を取得する
    func getSupplyVoltage(data: Data)->String{
        let supplyVoltage:String = self.latestDataConvert(data1: data[17], data2: data[18], unit: 1)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return supplyVoltage
    }
    
    // 電池電圧を元にバッテリーレベルを取得する
    func GetBatteryLevel(data: Data)->String{
        let supplyVoltage:Int! = Int(self.getSupplyVoltage(data: data))
        let val = (supplyVoltage-2000) / 10
        if (val > 100) {
            return "100"
        } else if (val < 0) {
            return "0"
        } else {
            return String(val)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
