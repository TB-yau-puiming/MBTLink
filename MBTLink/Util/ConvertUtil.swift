//
// ConvertUtil.swift
// 各種変換クラス
//
// MBTLink
//

import Foundation

final class ConvertUtil{
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ConvertUtil.self).split(separator: "-")[0])
    ///データ型→String型
    static func DataToString(data : Data) -> String{
        
        let ret = data.reduce(""){$0 + self.HexadecimalZeroPadding(uint: $1)}
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
    
    ///データ型→String型ハイフン付
    static func DataToStringAddHyphen(data : Data) -> String{
        
        var ret = data.reduce(""){$0 + self.HexadecimalZeroPadding(uint: $1) + "-"}
        ret = String(ret.prefix(ret.count-1))
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
    
    ///UNIX時間→日時文字列
    static func UnixTimeToDateString(unixTime : String) -> String{
        let format = "yyyy-MM-dd HH:mm:ss"
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return self.UnixTimeToDateString(unixTime: unixTime, format: format)
    }
    
    ///UNIX時間→日時文字列（フォーマット指定）
    static func UnixTimeToDateString(unixTime : String, format : String) -> String{
        
        // UNIX時間 "dateUnix" をDate型 "date" に変換
        let dateUnix : TimeInterval = TimeInterval(unixTime)!
        let date = Date(timeIntervalSince1970: dateUnix)
        
        // Date型を日時文字列に変換するためのDateFormatterを生成
        let formatter = DateFormatter()
        formatter.dateFormat = format

        // DateFormatterを使ってDate型 "date" を日時文字列 "dateStr" に変換
        let dateStr: String = formatter.string(from: date)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return dateStr
    }
    
    ///日時文字列→UNIX時間
    static func DateStringToUnixTime(dateStr : String) -> String{
        
        // 日時文字列をDate型に変換するためのDateFormatterを生成
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // DateFormatterを使って日時文字列 "dateStr" をDate型 "date" に変換
        let dateStr: String = dateStr
        let date: Date? = formatter.date(from: dateStr)

        // NSDate型 "date" をUNIX時間 "dateUnix" に変換
        let dateUnix: TimeInterval? = date?.timeIntervalSince1970
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return String(String(dateUnix!).prefix(10))
    }
    
    /// 2進数→10進数
    static func BinaryNumberToDecimal(binaryNumber : String)->Int{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return Int(binaryNumber,radix: 2)!
    }
    
    ///ゼロ埋め
    static func ZeroPadding(str : String)-> String{
        
        let ret = String(String("0" + str).suffix(2))
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
    
    /// 2進数ゼロ埋め
    static func BinaryNumberZeroPadding(uint : UInt8)-> String{
        
        // 2進数文字列に変換
        let byteString = String(uint, radix: 2)

        // 8桁(8bit)になるように0 padding
        let padding = String(repeating: "0", count: 8 - byteString.count)
        // 先頭にパディングを足す
        let ret = padding + byteString
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
    
    ///16進数ゼロ埋め
    static func HexadecimalZeroPadding(uint : UInt8)-> String{
        
        let ret = String(String("0" + String(uint,radix: 16)).suffix(2))
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
    
    /// 16進数結合
    static func HexadecimalJoin(uint1 : UInt8, uint2 : UInt8) -> String{
        
        var ret : String!
        
        let convData1 : String = HexadecimalZeroPadding(uint: uint1)
        let convData2 : String = HexadecimalZeroPadding(uint: uint2)
        
        ret = String(Int(convData2 + convData1, radix: 16)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
    
    ///書き込みデータ
    static func WriteData(str : String) -> Data{
        
        var ret : Data
        
        var start : Int = 0
        var end : Int = 0
        var sub : String = ""
        var array = [UInt8]()

        for i in stride(from: 0, to: str.count-1, by: 2){
            start = i
            end = i + 1
            let startIdx = str.index(str.startIndex, offsetBy: start, limitedBy: str.endIndex) ?? str.endIndex
            let endIdx = str.index(str.startIndex, offsetBy: end + 1, limitedBy: str.endIndex) ?? str.endIndex
            
            ///文字切り取り
            sub = String(str[startIdx..<endIdx])
            ///16進数に変換して値を格納
            array.append(UInt8(sub,radix: 16)!)
        }
        
        /// Data型に変換
        ret = Data(bytes: &array, count: array.count)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
    
    ///書き込みデータ（日付用）
    static func WriteDataForDateTime(str : String) -> Data{
        
        var ret : Data
        
        var start : Int = 0
        var end : Int = 0
        var sub : String = ""
        var array = [UInt8]()
        
        // 年の加工
        let yyyy = str.prefix(4)
        var yyyyHex = String(Int(yyyy)!, radix: 16)
        yyyyHex = String(String("0" + yyyyHex).suffix(4))
        array.append(UInt8(yyyyHex.suffix(2), radix: 16)!)
        array.append(UInt8(yyyyHex.prefix(2), radix: 16)!)
        
        // 月日時分秒の加工
        let str = str.suffix(10)

        for i in stride(from: 0, to: str.count-1, by: 2){
            start = i
            end = i + 1
            let startIdx = str.index(str.startIndex, offsetBy: start, limitedBy: str.endIndex) ?? str.endIndex
            let endIdx = str.index(str.startIndex, offsetBy: end + 1, limitedBy: str.endIndex) ?? str.endIndex
            
            ///文字切り取り
            sub = String(str[startIdx..<endIdx])
            // 16進数に変換
            sub = String(Int(sub)!, radix: 16)
            sub = String(String("0" + sub).suffix(2))
            ///16進数に変換して値を格納
            array.append(UInt8(sub,radix: 16)!)
        }
        /// Data型に変換
        ret = Data(bytes: &array, count: array.count)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: ConvertUtil().className , functionName: #function , message: "")
        return ret
    }
}


