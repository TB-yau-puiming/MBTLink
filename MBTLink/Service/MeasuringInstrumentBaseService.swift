//
// MeasuringInstrumentBaseService.swift
// 測定機器関連ベースクラスサービス
//
//  MBTLink
//

import Foundation

class MeasuringInstrumentBaseService {
    // MARK: - Private変数
    /// ファイル操作クラス
    let fileUtil = FileUtil()
    /// クラス名
    private let className = String(String(describing: ( MeasuringInstrumentBaseService.self)).split(separator: "-")[0])
    // MARK: - Public Methods
    /// イニシャライザ
    init(){
    }
    
    /// シリアルナンバー取得
    func GetSerialNumber(data : Data) -> String{
    
        let ret : String = String(bytes: data, encoding: .utf8)!
        
        return ret
    }
    
    /// BDアドレス取得
    func GetBDAddress(data : Data) -> String{
    
        let ret : String = String(format: "%@%@%@%@%@%@"
                                  ,ConvertUtil.HexadecimalZeroPadding(uint: data[7])
                                  ,ConvertUtil.HexadecimalZeroPadding(uint: data[6])
                                  ,ConvertUtil.HexadecimalZeroPadding(uint: data[5])
                                  ,ConvertUtil.HexadecimalZeroPadding(uint: data[2])
                                  ,ConvertUtil.HexadecimalZeroPadding(uint: data[1])
                                  ,ConvertUtil.HexadecimalZeroPadding(uint: data[0])
        ).uppercased()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return ret
    }
    
    /// JSON作成
    func CreateSendDataJson(data : Data, deviceAddress : String, batteryLevel: String, rssi: String,sendDataType : Int) -> Data{
        // デバイス情報JSON作成
        let deviceInfoJson = self.createDeviceInfoJson(deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, sendDataType : sendDataType)
    
        // データJSON作成
        let dataJson = self.createDataJson(data: data)
        // JSON結合
        let jsonValue = CommonUtil.JsonJoin(json1: deviceInfoJson, Json2: dataJson)
        
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    func CreatePairingDataJson(deviceId : String, deviceAddress : String, batteryLevel: String, rssi: String,sendDataType : Int, deviceType: Int) -> Data{
        let deviceInfoJson = CommonUtil.CreateDeviceInfoJson(deviceId: deviceId, deviceAddress: deviceAddress, batteryLevel: batteryLevel, rssi: rssi, deviceType: deviceType, sendDataType: sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    
    // MARK: - Private Methods
    /// デバイス情報JSON作成
    internal func createDeviceInfoJson(deviceAddress : String, batteryLevel: String, rssi: String, sendDataType : Int)->Data{
        // 継承先で実装
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return Data()
    }
    /// データJSON作成
    internal func createDataJson(data : Data)->Data{
        // 継承先で実装
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return Data()
    }
}
