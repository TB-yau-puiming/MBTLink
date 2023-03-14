//
// EnvSensorCodable.swift
// 環境センサCodable
//
// MBTLink
//

import Foundation

struct EnvSensorCodable : Codable {

    ///デバイスデータ取得日時(YYYYMMDDhhmmss)
    var GET_DATE : String
    ///デバイスデータ配列
    var DEVICE : [CommonCodable.Data]
    
//    // 旧仕様フォーマット
//    ///温度
//    var TEMP : String
//    ///湿度
//    var HUMD : String
//    ///輝度
//    var BRIT : String
//    ///騒音
//    var NOIS : String
//    ///UV Index (BAG型環境センサ[2JCIE-BL01])
//    var UV : String
//    ///気圧
//    var ATMS : String
//    ///VOCガス (USB型環境センサ[2JCIE-BU01])
//    var VOC : String
//    ///不快指数
//    var O_RSRV1 : String
//    ///熱中症警戒度
//    var O_RSRV2 : String
    
    /// イニシャライザ
    init(){
        ///デバイスデータ取得日時(YYYYMMDDhhmmss)
        GET_DATE = ""
        ///デバイスデータ配列
        DEVICE = [CommonCodable.Data]()
        
//        // 旧仕様フォーマット
//        ///温度
//        TEMP = ""
//        ///湿度
//        HUMD = ""
//        ///輝度
//        BRIT  = ""
//        ///騒音
//        NOIS  = ""
//        ///UV Index (BAG型環境センサ[2JCIE-BL01])
//        UV  = ""
//        ///気圧
//        ATMS  = ""
//        ///VOCガス (USB型環境センサ[2JCIE-BU01])
//        VOC  = ""
//        ///不快指数
//        O_RSRV1  = ""
//        ///熱中症警戒度
//        O_RSRV2  = ""
    }
}
