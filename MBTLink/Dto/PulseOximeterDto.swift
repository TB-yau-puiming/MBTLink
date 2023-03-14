//
// PulseOximeterDto.swift
// A&D パルスオキシメータ TM1121関連DTO
//
// MBTLink
//

import Foundation

struct PulseOximeterDto {
    
    /// FLAG
    private var flag : String = ""
    /// STAT
    private var stat : String = ""
    /// SPO2値
    private var spo2 : String = ""
    /// 脈拍数
    private var pulseRate : String = ""
    /// タイムスタンプ
    private var timeStamp : String = ""
    /// タイムスタンプ（YYYYMMDDhhmmss）
    private var timeStampYMDhms : String = ""
    
    /// FLAG
    var Flag : String {
        get{
            return self.flag
        }
        set{
            self.flag = newValue
        }
    }
    /// STAT
    var Stat : String {
        get{
            return self.stat
        }
        set{
            self.stat = newValue
        }
    }
    /// SPO2値
    var Spo2 : String {
        get{
            return self.spo2
        }
        set{
            self.spo2 = newValue
        }
    }
    /// 脈拍数
    var PulseRate : String {
        get{
            return self.pulseRate
        }
        set{
            self.pulseRate = newValue
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
