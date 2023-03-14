//
// PulseOximeterService.swift
// A&D パルスオキシメータ TM1121関連サービス
//
// MBTLink
//

import Foundation

final class PulseOximeterService : MeasuringInstrumentBaseService {
    
    /// データ保持用Array(旧フォーマット用の暫定措置)
    public var SaveDataArray = [Data]()
    /// クラス名
    private let className = String(String(describing: ( PulseOximeterService.self)).split(separator: "-")[0])
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
    }

    /// パルスオキシメータデータ取得
    func GetPulseOximeterData(data : Data) -> PulseOximeterDto{
        
        var pulseOximeterData = PulseOximeterDto()
        print(data)
        
        // FLAG(0:タイムスタンプなし 1:タイムスタンプあり)
        pulseOximeterData.Flag = String(data[0])
        // STAT
        pulseOximeterData.Stat = ConvertUtil.BinaryNumberZeroPadding(uint: data[1])
        // SPO2
        pulseOximeterData.Spo2 = ConvertUtil.HexadecimalJoin(uint1: data[2], uint2: data[3])
        // 脈拍数
        pulseOximeterData.PulseRate = ConvertUtil.HexadecimalJoin(uint1: data[4], uint2: data[5])
        
        if pulseOximeterData.Flag == "1"{
            let year = ConvertUtil.HexadecimalJoin(uint1: data[6], uint2: data[7])
            let month = ConvertUtil.ZeroPadding(str: String(data[8]))
            let day = ConvertUtil.ZeroPadding(str:String(data[9]))
            let hour = ConvertUtil.ZeroPadding(str:String(data[10]))
            let minutes = ConvertUtil.ZeroPadding(str:String(data[11]))
            let seconds = ConvertUtil.ZeroPadding(str:String(data[12]))
            
            // タイムスタンプ
            pulseOximeterData.TimeStamp = String(format: "%@-%@-%@ %@:%@:%@"
                ,year,month,day,hour,minutes,seconds)
            //タイムスタンプ(YYYYMMDDhhmmss)
            pulseOximeterData.TimeStampYMDhms = String(format: "%@%@%@%@%@%@"
                ,year,month,day,hour,minutes,seconds)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return pulseOximeterData
    }
    
    /// パルスオキシメータデータカンマ区切り取得
    func GetPulseOximeterDataComma(data : Data) -> String{
        
        var ret : String = ""
        let pulseOximeterData = self.GetPulseOximeterData(data: data)
        
        // FLAG
        ret.append(pulseOximeterData.Flag)
        ret.append(",")
        // STAT
        ret.append(pulseOximeterData.Stat)
        ret.append(",")
        // SPO2
        ret.append(pulseOximeterData.Spo2)
        ret.append(",")
        // 脈拍数
        ret.append(pulseOximeterData.PulseRate)
        ret.append(",")
        // タイムスタンプ
        ret.append(pulseOximeterData.TimeStamp)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// CSV出力
    func CsvOutput(data : Data){
        // CSVファイル名
        let csvFileNameStr : String = "PulseOximeter_"
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
        
        writeData = dateString +  "," + self.GetPulseOximeterDataComma(data: data)
        
        if csvWriteData == "" {
            csvWriteData = PulseOximeterConst.CsvFileHeader
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
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: PulseOximeterConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: DataCommunicationService.DeviceType.PulseOximeter.rawValue, sendDataType: sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    /// データJSON作成
    internal override func createDataJson(data : Data)->Data{
        
        let pulseOximeterData = self.GetPulseOximeterData(data: data)
        
        var codable = PulseOximeterCodable()
        var deviceData = CommonCodable.Data()

        // デバイスデータ取得日時(YYYYMMDDhhmmss)
        if pulseOximeterData.TimeStampYMDhms == "" {
            codable.GET_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        }
        else{
            codable.GET_DATE = pulseOximeterData.TimeStampYMDhms
        }

        // 脈拍数
        deviceData.DATA = pulseOximeterData.PulseRate
//        deviceData.DATA = "50"
        codable.DEVICE.append(deviceData)
        // 血中酸素濃度(SpO2)
        deviceData.DATA = pulseOximeterData.Spo2
//        deviceData.DATA = "60"
        codable.DEVICE.append(deviceData)
        
        // @@@旧フォーマット -->
//        var codable = CommonCodable.PulseOximeterCodable()
//        var deviceData = CommonCodable.OldData()
//        /// データ取得日時(YYYYMMDDhhmmss+n)
//        if pulseOximeterData.TimeStampYMDhms == "" {
//            codable.TM = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
//        }
//        else{
//            codable.TM = pulseOximeterData.TimeStampYMDhms
//        }
//        ///測定モード(1：スポット測定 2：モニタリング測定)
//        codable.MEASURE_MODE = "2"
//        ///パルスオキシメータ情報
//        // 1〜4つ前のデータ
//        for dt in self.SaveDataArray{
//            let previousData = self.GetPulseOximeterData(data: dt)
//            deviceData.DT = previousData.PulseRate +  "," + previousData.Spo2
//            codable.PlsOx.append(deviceData)
//        }
//        // 最新のデータ
//        deviceData.DT = pulseOximeterData.PulseRate +  "," + pulseOximeterData.Spo2
//        codable.PlsOx.append(deviceData)
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
