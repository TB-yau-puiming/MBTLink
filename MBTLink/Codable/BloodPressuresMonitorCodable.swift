//
// BloodPressuresMonitorCodable.swift
// 血圧計Codable
//
// MBTLink
//

import Foundation

struct BloodPressuresMonitorCodable : Codable {
    ///デバイスデータ取得日時(YYYYMMDDhhmmss)
    var GET_DATE : String
    ///デバイスデータ配列
    var DEVICE : [CommonCodable.Data]
    
    /// イニシャライザ
    init(){
        ///デバイスデータ取得日時(YYYYMMDDhhmmss)
        GET_DATE = ""
        ///デバイスデータ配列
        DEVICE = [CommonCodable.Data]()
    }
}
