//
// EnvSensorDto.swift
// オムロン 環境センサ 2JCIE-BL01関連DTO
//
// MBTLink
//

import Foundation

struct EnvSensorLatestDataDto {
    
    /// 温度
    private var temperature: String  = ""
    /// 相対湿度
    private var relativeHumidity : String  = ""
    /// 照度
    private var ambientLight: String  = ""
    /// UV Index
    private var uvIndex: String  = ""
    /// 気圧
    private var pressure: String  = ""
    /// 騒音
    private var soundNoise : String  = ""
    /// 不快指数
    private var discomfortIndex : String  = ""
    /// 熱中症危険度
    private var featStroke: String  = ""
    /// 電源電圧
    private var supplyVoltage: String  = ""
    
    /// 温度
    var Temperature: String {
        get{
            return self.temperature
        }
        set{
            self.temperature = newValue
        }
    }
    /// 相対湿度
    var RelativeHumidity : String {
        get{
            return self.relativeHumidity
        }
        set{
            self.relativeHumidity = newValue
        }
    }
    /// 照度
    var AmbientLight: String {
        get{
            return self.ambientLight
        }
        set{
            self.ambientLight = newValue
        }
    }
    /// UV Index
    var UvIndex: String {
        get{
            return self.uvIndex
        }
        set{
            self.uvIndex = newValue
        }
    }
    /// 気圧
    var Pressure: String {
        get{
            return self.pressure
        }
        set{
            self.pressure = newValue
        }
    }
    /// 騒音
    var SoundNoise : String {
        get{
            return self.soundNoise
        }
        set{
            self.soundNoise = newValue
        }
    }
    /// 不快指数
    var DiscomfortIndex : String {
        get{
            return self.discomfortIndex
        }
        set{
            self.discomfortIndex = newValue
        }
    }
    /// 熱中症危険度
    var FeatStroke: String {
        get{
            return self.featStroke
        }
        set{
            self.featStroke = newValue
        }
    }
    /// 電源電圧
    var SupplyVoltage: String {
        get{
            return self.supplyVoltage
        }
        set{
            self.supplyVoltage = newValue
        }
    }
}
