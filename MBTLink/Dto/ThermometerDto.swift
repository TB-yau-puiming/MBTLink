//
// ThermometerDto.swift
// A&D 体温計 UT-201BLE関連DTO
//
// MBTLink
//

import Foundation

struct ThermometerDto {
    
    /// Flags
    private var flags : String = ""
    /// 体温
    private var temperature : String = ""
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
    /// 体温
    var Temperature : String {
        get{
            return self.temperature
        }
        set{
            self.temperature = newValue
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
