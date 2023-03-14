//
// WeightScaleDto.swift
// A&D 体重計 UC-352BLE関連DTO
//
// MBTLink
//

import Foundation

struct WeightScaleDto {
    
    /// Flags
    private var flags : String = ""
    /// 体重
    private var weightScale : String = ""
    /// タイムスタンプ
    private var timeStamp : String = ""
    /// タイムスタンプ（YYYYMMDDhhmmss）
    private var timeStampYMDhms : String = ""
    
    /// Flags
    var Flags : String {
        get{
            return self.flags
        }
        set{
            self.flags = newValue
        }
    }
    /// 体重
    var WeightScale : String {
        get{
            return self.weightScale
        }
        set{
            self.weightScale = newValue
        }
    }
    /// タイムスタンプ
    var TimeStamp : String {
        get{
            return self.timeStamp
        }
        set{
            self.timeStamp = newValue
        }
    }
    /// タイムスタンプ（YYYYMMDDhhmmss）
    var TimeStampYMDhms : String {
        get{
            return self.timeStampYMDhms
        }
        set{
            self.timeStampYMDhms = newValue
        }
    }
}
