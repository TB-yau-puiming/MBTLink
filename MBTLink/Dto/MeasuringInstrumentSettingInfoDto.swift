//
// MeasuringInstrumentSettingInfoDto.swift
// 測定機器設定関連DTO
//
// MBTLink
//

import Foundation

struct MeasuringInstrumentSettingInfoDto{
    /// 測定機器設定中かどうか
    private var isSettings : Bool =  false
    /// デバイス名
    private var deviceName : String? = ""
    /// シリアル番号
    private var serialNumber : String? = ""
    /// UUID
    private var uuid : String? = ""
    /// 測定間隔
    private var measuringInterval : String? = ""
    /// 接続中デバイス名
    private var deviceNamePairing : String? = ""
    
    /// 測定機器設定中かどうか
    var IsSettings : Bool{
        get{
            return self.isSettings
        }
        set{
            self.isSettings = newValue
        }
    }
    /// デバイス名
    var DeviceName : String?{
        get{
            return self.deviceName
        }
        set{
            self.deviceName = newValue
        }
    }
    /// シリアル番号
    var SerialNumber : String?{
        get{
            return self.serialNumber
        }
        set{
            self.serialNumber = newValue
        }
    }
    
    /// UUID
    var Uuid : String?{
        get{
            return self.uuid
        }
        set{
            self.uuid = newValue
        }
    }
    
    /// 測定間隔
    var MeasuringInterval : String?{
        get{
            return NSLocalizedString(self.measuringInterval ?? "", comment: "")
        }
        set{
            self.measuringInterval = newValue
        }
    }
    
    /// 接続中デバイス名
    var DeviceNamePairing : String?{
        get{
            return self.deviceNamePairing
        }
        set{
            self.deviceNamePairing = newValue
        }
    }
}
