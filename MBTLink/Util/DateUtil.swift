//
// DateUtil.swift
// 日付関連クラス
//
// MBTLink
//

import Foundation

final class DateUtil {
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: DateUtil.self).split(separator: "-")[0])
    // MARK: - Public Methods
    ///日付フォーマット変換後取得
    static func GetDateFormatConvert(format : String) -> String{
        
        let dt = Date()
        let dateFormatter = DateFormatter()
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        //dateFormatter.calendar = Calendar(identifier: .gregorian)
        //dateFormatter.locale = Locale(identifier: "ja_JP")
        if StringsConst.LANGUAGE == "日本語"{
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        }else if StringsConst.LANGUAGE == "English"{
        dateFormatter.timeZone = TimeZone.current
        }
        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: dt)
    }
    
    ///日付フォーマット変換後取得
    static func GetTimeZone() -> String{

        let dateFormatter = DateFormatter()
        if StringsConst.LANGUAGE == "日本語"{
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        }else if StringsConst.LANGUAGE == "English"{
        dateFormatter.timeZone = TimeZone.current
        }
//        print(dateFormatter.timeZone.identifier.description)
//        print(dateFormatter.timeZone.description)
//        return dateFormatter.timeZone.description
        let timeZone = dateFormatter.timeZone.identifier.description.replacingOccurrences(of: "\\", with: "")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: DateUtil().className , functionName: #function , message: "")
        return timeZone
    }
    
    // 日付加減算
    static func GetAddedDate(num : Int) -> Date{
        
        let dt = Date()
        let modifyDate = Calendar.current.date(byAdding: .day, value: num, to: dt)!
        return modifyDate
    }
    
    ///日付フォーマット変換後取得
    static func GetDateFormatConvert(format : String, dt : Date) -> String{
        
        let dateFormatter = DateFormatter()
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")

        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: dt)
    }
    /// 日付文字列を別のフォーマットに変換し返却
    /// - Parameters:
    ///   - dateString: 変換したい文字列
    ///   - fromFormat: 変換前の文字列の形式(dateFormat)
    ///   - toFormat: 変換後の文字列の形式(dateFormat)
    static func getFormattedDateString(dateString: String, from fromFormat: String = "yyyyMMddHHmmss", to toFormat: String = "yyyy/MM/dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        // DateFormatterのロケールやその他指定は各自変えて下さい
        dateFormatter.locale = .current
        dateFormatter.dateFormat = fromFormat
        guard let date = dateFormatter.date(from: dateString) else { return "" }
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: date)
    }
    static func getFormattedDateStringHHmm(dateString: String, from fromFormat: String = "yyyyMMddHHmmss", to toFormat: String = "HHmm") -> String {
        let dateFormatter = DateFormatter()
        // DateFormatterのロケールやその他指定は各自変えて下さい
        dateFormatter.locale = .current
        dateFormatter.dateFormat = fromFormat
        guard let date = dateFormatter.date(from: dateString) else { return "" }
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: date)
    }
}
