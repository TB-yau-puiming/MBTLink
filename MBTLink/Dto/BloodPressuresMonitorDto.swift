//
// BloodPressuresMonitorDto.swift
// A&D 血圧計 UA-651BLE関連DTO
//
// MBTLink
//

import Foundation

struct BloodPressuresMonitorDto {
    
    /// Flags
    private var flags : String = ""
    /// 最高血圧
    private var systolicPressure : String = ""
    /// 最低血圧
    private var diastolicPressure : String = ""
    /// 平均血圧
    private var meanArterialPressure : String = ""
    /// タイムスタンプ
    private var timeStamp : String = ""
    /// 脈拍
    private var pulseRate : String = ""
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
    /// 最高血圧
    var SystolicPressure : String {
        get{
            return self.systolicPressure
        }
        set{
            self.systolicPressure = newValue
        }
    }
    /// 最低血圧
    var DiastolicPressure : String {
        get{
            return self.diastolicPressure
        }
        set{
            self.diastolicPressure = newValue
        }
    }
    /// 平均血圧
    var MeanArterialPressure : String {
        get{
            return self.meanArterialPressure
        }
        set{
            self.meanArterialPressure = newValue
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
    /// 脈拍
    var PulseRate : String {
        get{
            return self.pulseRate
        }
        set{
            self.pulseRate = newValue
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
