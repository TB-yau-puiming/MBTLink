//
// WatchDeviceData.swift
// ウォッチデバイス登録データ関連
//
// MBTLink
//

import Foundation.NSObject

class WatchDeviceData: NSObject, NSCoding {

    /// デバイスArray
    var WatchDeviceArray : [String]
    
    init(watchDeviceArray: [String]) {
        self.WatchDeviceArray = watchDeviceArray
    }
    
    required init?(coder: NSCoder) {
        
        // デバイスArray
        self.WatchDeviceArray = (coder.decodeObject(forKey: WatchConst.WatchDeviceRegistData.WatchDeviceArray) as? [String]) ?? []
    }
    
    func encode(with coder: NSCoder) {
        // デバイスArray
        coder.encode(self.WatchDeviceArray, forKey: WatchConst.WatchDeviceRegistData.WatchDeviceArray)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "WatchDeviceData" , functionName: #function , message: "")
    }
}

