//
// StringUtil.swift
// MBTLink
// 文字列関連クラス
//
// MBTLink
//

import Foundation

final class StringUtil {
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: StringUtil.self).split(separator: "-")[0])
    // MARK: - Public Methods
    /// 文字列切り出し
    static func SubString(text : String, from : Int, length : Int) -> String {
    
        let to = text.index(text.startIndex, offsetBy:from + length-1)
        let from = text.index(text.startIndex, offsetBy:from)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: StringUtil().className , functionName: #function , message: "")
        return String(text[from...to])
    }
    
    // 入力文字列に対し半角英数字及び特定記号の検出をする
    static func fixInputStr(text : String) -> String {
        // 許容文字
        var permitedChar : [String] = []
        permitedChar.append(contentsOf: CommonConst.UpperHalfEngChar)  // 半角英数字（大文字）
        permitedChar.append(contentsOf: CommonConst.LowerHalfEngChar)  // 半角英数字（大文字）
        permitedChar.append(contentsOf: CommonConst.NumericChar)    // 数字
        permitedChar.append(contentsOf: CommonConst.SpecialChar)    // 特殊文字
        
        var fixedStr = ""
        
        for targetChar in text {
            let targetStr = String(targetChar)
            if(permitedChar.contains(targetStr)){
                fixedStr.append(contentsOf: targetStr)
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: StringUtil().className , functionName: #function , message: "")
        // 許容された文字列のみを返却する
        return fixedStr
    }
}

