//
// WeightScaleService.swift
// A&D 体重計 UC-352BLE関連サービス
//
// MBTLink
//

import Foundation

final class WeightScaleService : MeasuringInstrumentBaseService {
    /// クラス名
    private let className = String(String(describing: ( WeightScaleService.self)).split(separator: "-")[0])
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
    }
    
    /// 体重測定データ取得
    func GetWeightScaleMeasurementData(data : Data) -> WeightScaleDto{
        
        var weightScaleMeasurementData = WeightScaleDto()
        
        // Flags
        weightScaleMeasurementData.Flags = ConvertUtil.BinaryNumberZeroPadding(uint: data[0])
        // 体重
        weightScaleMeasurementData.WeightScale = String(floor(Double(ConvertUtil.HexadecimalJoin(uint1: data[1], uint2: data[2]))! * 0.005 * Double(100)) / Double(100))
        
        let timeStampFlag = StringUtil.SubString(text:weightScaleMeasurementData.Flags, from:6,length:1)
        
        if timeStampFlag == "1"{
            let year = ConvertUtil.HexadecimalJoin(uint1: data[3], uint2: data[4])
            let month = ConvertUtil.ZeroPadding(str: String(data[5]))
            let day = ConvertUtil.ZeroPadding(str:String(data[6]))
            let hour = ConvertUtil.ZeroPadding(str:String(data[7]))
            let minutes = ConvertUtil.ZeroPadding(str:String(data[8]))
            let seconds = ConvertUtil.ZeroPadding(str:String(data[9]))
            
            //タイムスタンプ
            weightScaleMeasurementData.TimeStamp = String(format: "%@-%@-%@ %@:%@:%@"
                ,year,month,day,hour,minutes,seconds)
            //タイムスタンプ(YYYYMMDDhhmmss)
            weightScaleMeasurementData.TimeStampYMDhms = String(format: "%@%@%@%@%@%@"
                ,year,month,day,hour,minutes,seconds)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return weightScaleMeasurementData
    }
    
    /// 体重測定データカンマ区切り取得
    func GetWeightScaleMeasurementDataComma(data : Data) -> String{
        
        var ret : String = ""
        let weightScaleMeasurementData = self.GetWeightScaleMeasurementData(data: data)
        
        //体重
        ret.append(weightScaleMeasurementData.WeightScale)
        ret.append(",")
        //タイムスタンプ
        ret.append(weightScaleMeasurementData.TimeStamp)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    /// CSV出力
    func CsvOutput(data : Data){
        // CSVファイル名
        let csvFileNameStr : String = "WeightScale_"
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
        
        writeData = dateString +  "," + self.GetWeightScaleMeasurementDataComma(data: data)
        
        if csvWriteData == "" {
            csvWriteData = WeightScaleConst.CsvFileHeader
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
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: WeightScaleConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.WeightScale.rawValue, sendDataType: sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    /// データJSON作成
    internal override func createDataJson(data : Data)->Data{
        
        let weightScaleMeasurementData = self.GetWeightScaleMeasurementData(data: data)
        
        var codable = WeightScaleCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        if weightScaleMeasurementData.TimeStampYMDhms == "" {
            codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        }
        else{
            codable.GET_DATE = weightScaleMeasurementData.TimeStampYMDhms
        }

        //体重
        deviceData.DATA = weightScaleMeasurementData.WeightScale
        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.WeightScaleCodable()
//        /// データ取得日時(YYYYMMDDhhmmss+n)
//        codable.TM = weightScaleMeasurementData.TimeStampYMDhms
//        ///体重
//        codable.BW = weightScaleMeasurementData.WeightScale
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
        let WeightScale = Double(ConvertUtil.HexadecimalJoin(uint1: data[1], uint2: data[2]))

        if(WeightScale == WeightScaleConst.measurementErrorData){
            errorFlg = true
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return errorFlg
    }
}
