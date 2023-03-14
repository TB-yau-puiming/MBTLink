//
//  LocationInfoSettingData.swift
//  MBTLink
//

import Foundation.NSObject

class LocationInfoSettingData: NSObject, NSCoding {

    var IsLocationInfoSend: Bool
    var LocationInfoSendStart: String
    var LocationInfoSendEnd: String
    var ShortestSendInterval: String
    var LocationInfoReceiveLevel: String
    var LocationInfoSendMethodNum: Int
    
    init(_ isLocationInfoSend: Bool, _ locationInfoSendStart: String, _ locationInfoSendEnd: String, _ shortestSendInterval: String, _ locationInfoReceiveLevel : String, _ locationInfoSendMethodNum: Int) {
        
        self.IsLocationInfoSend = isLocationInfoSend
        self.LocationInfoSendStart = locationInfoSendStart
        self.LocationInfoSendEnd = locationInfoSendEnd
        self.ShortestSendInterval = shortestSendInterval
        self.LocationInfoReceiveLevel = locationInfoReceiveLevel
        self.LocationInfoSendMethodNum = locationInfoSendMethodNum
    }

    required init?(coder: NSCoder) {
        IsLocationInfoSend = coder.decodeBool(forKey: "isLocationInfoSend")
        LocationInfoSendStart = (coder.decodeObject(forKey: "locationInfoSendStart") as? String) ?? "09:00"
        LocationInfoSendEnd = (coder.decodeObject(forKey: "locationInfoSendEnd") as? String) ?? "17:00"
        ShortestSendInterval = (coder.decodeObject(forKey: "shortestSendInterval") as? String) ?? "5"
        LocationInfoReceiveLevel = (coder.decodeObject(forKey: "locationInfoReceiveLevel") as? String) ?? StringsConst.LOW
        LocationInfoSendMethodNum = coder.decodeInteger(forKey: "locationInfoSendMethodNum")
    }

    func encode(with coder: NSCoder) {
        coder.encode(IsLocationInfoSend, forKey: "isLocationInfoSend")
        coder.encode(LocationInfoSendStart, forKey: "locationInfoSendStart")
        coder.encode(LocationInfoSendEnd, forKey: "locationInfoSendEnd")
        coder.encode(ShortestSendInterval, forKey: "shortestSendInterval")
        coder.encode(LocationInfoReceiveLevel, forKey: "locationInfoReceiveLevel")
        coder.encode(LocationInfoSendMethodNum, forKey: "locationInfoSendMethodNum")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "LocationInfoSettingData" , functionName: #function , message: "")
    }
}
