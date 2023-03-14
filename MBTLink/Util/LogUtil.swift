//
//  LogUtil.swift
//  MBTLink
//
//  Created by school on 2022/05/10.
//

import Foundation

class LogUtil {
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: LogUtil.self).split(separator: "-")[0])
    // MARK: - enum
    /// ログレベル
    enum LogLevel : Int{
        case DEBUG = 1
        case INFO = 2
        case ACTION = 3
        case WARN = 4
        case ERROR = 5
    }
    
    
    static let fileUtil = FileUtil()
    
    static let applicationName = CommonUtil.GetAppName()
    // ログ出力の指定レベル
    static let OUT_PUT_LOG_LEVEL : Int = LogLevel.DEBUG.rawValue
    //ログ出力用
    public static func createSystemLog(logLevel : String, className : String, functionName : String, message : String){
        /*
        CommonUtil.Print(logLevel : logLevel, className : className, functionName : functionName, message : message)
        var logLevelInt : Int = 0
        switch logLevel{
        case StringsConst.DEBUG :
            logLevelInt = LogLevel.DEBUG.rawValue
            break
        case StringsConst.INFO :
            logLevelInt = LogLevel.INFO.rawValue
            break
        case StringsConst.ACTION :
            logLevelInt = LogLevel.ACTION.rawValue
            break
        case StringsConst.WARN :
            logLevelInt = LogLevel.WARN.rawValue
            break
        case StringsConst.ERROR :
            logLevelInt = LogLevel.ERROR.rawValue
            break
        default:
            break
        }
        var writeData : String = ""
        // 受け取ったログレベルが出力指定レベルより大きいか等しい場合はログを出力する
        if logLevelInt >= OUT_PUT_LOG_LEVEL{
            
        let del: Set<Character> = ["(",")"] // ( と ) を削除
        var classNameStr = className
        classNameStr.removeAll(where: { del.contains($0) })
        var functionNameStr = functionName
        functionNameStr.removeAll(where: { del.contains($0) })
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "mbtlinkSystemLog_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        // ディレクトリの作成
        fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
        let receiveFileName = CommonConst.ReceiveDir + "/" + "Log" + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString + "," + logLevel + "," + classNameStr + "," + functionNameStr
        if message != ""{
            writeData = writeData + "," + message
        }
        csvWriteData.append("\n")
        csvWriteData.append(writeData)
     
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive/Log"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
            for file in allFiles{

            // ２日前以前のログファイルを削除する
                if file.contains("mbtlinkSystemLog") {
                let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                let YYYYMMdd_HH = file[startIndex...endIndex]
                //print(YYYYMMdd_HH)
                //print(beforeDtStr)
                
                    if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                    || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                    let delFile = "\(logDir)/\(file)"
                    fileUtil.RemoveItem(atPath: delFile)
                    }
                }
            }
        }
        //ログメッセージが生成された場合はサーバーへログを送信させる
        // FIXME: ネットワークエラーによるループ処理を停止させるために"Error occured"が入ったエラーログ送信を停止させている
        if writeData != "" && writeData.contains("Error occured") == false {
            DataCommunicationService.postSendLogMsg(msg: writeData, deviceID: "", deviceAdr: "", deviceType: 0)
        }
        */
    }
    
    //エラーログ出力用
    public static func createErrorLog(className : String, functionName : String, message : String){
        var writeData : String = ""
        let del: Set<Character> = ["(",")"] // ( と ) を削除
        var classNameStr = className
        classNameStr.removeAll(where: { del.contains($0) })
        var functionNameStr = functionName
        functionNameStr.removeAll(where: { del.contains($0) })
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "mbtlinkErrorLog_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        // ディレクトリの作成
        fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
        let receiveFileName = CommonConst.ReceiveDir + "/" + "Log" + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString + "," + StringsConst.ERROR + "," + classNameStr + "," + functionNameStr
        if message != ""{
            writeData = writeData + "," + message
        }
        csvWriteData.append("\n")
        csvWriteData.append(writeData)
     
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive/Log"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
            for file in allFiles{

            // ２日前以前のログファイルを削除する
                if file.contains("mbtlinkErrorLog") {
                let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                let YYYYMMdd_HH = file[startIndex...endIndex]
                //print(YYYYMMdd_HH)
                //print(beforeDtStr)
                
                    if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                    || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                    let delFile = "\(logDir)/\(file)"
                    fileUtil.RemoveItem(atPath: delFile)
                    }
                }
            }
    }
/*
    public static func createSystemLog(className : String, functionName : String, message : String) -> String{
        let del: Set<Character> = ["(",")"] // ( と ) を削除
        var classNameStr = className
        classNameStr.removeAll(where: { del.contains($0) })
        var functionNameStr = functionName
        functionNameStr.removeAll(where: { del.contains($0) })
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "mbtlinkSystemLog_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        // ディレクトリの作成
        fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
        let receiveFileName = CommonConst.ReceiveDir + "/" + "Log" + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        var writeData : String = ""
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = dateString + "," + classNameStr + "," + functionNameStr
        if message != ""{
            writeData = writeData + "," + message
        }
        csvWriteData.append("\n")
        csvWriteData.append(writeData)
     
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive/Log"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
        for file in allFiles{

            // ２日前以前のログファイルを削除する
            if file.contains("mbtlinkSystemLog") {
                let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                let YYYYMMdd_HH = file[startIndex...endIndex]
                //print(YYYYMMdd_HH)
                //print(beforeDtStr)
                
                if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                    || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                    let delFile = "\(logDir)/\(file)"
                    fileUtil.RemoveItem(atPath: delFile)
                }
            }
        }
        return writeData
    }
 */
    
    ///送信失敗時のJSONデータ保存メソッド
    public static func createResendFile(json:String, fileType: String){
        var writeData : String = ""
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmssSSS")
        let csvFileNameStr = "resendJson_"
        let csvFileName = csvFileNameStr + "\(nowDate).txt"
        // ディレクトリの作成
        fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Resend" + "/" + fileType)
        let receiveFileName = CommonConst.ReceiveDir + "/" + "Resend" + "/" + fileType + "/" + csvFileName
        
        // ファイル書き込みデータ
        var csvWriteData : String = ""
        //let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
        
        // ファイルが存在する場合
        if self.fileUtil.FileExists(atPath: receiveFileName){
            // ファイルからデータ読み込み
            csvWriteData = self.fileUtil.ReadFromFile(fileName: receiveFileName)
        }
        
        writeData = String(describing:json)
        csvWriteData.append(writeData)
     
        // ファイル書き込み
        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
        
        /*
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive/Log"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
            
            for file in allFiles{

            // ２日前以前のログファイルを削除する
                if file.contains("mbtlinkErrorLog") {
                let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                let YYYYMMdd_HH = file[startIndex...endIndex]
                //print(YYYYMMdd_HH)
                //print(beforeDtStr)
                
                    if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                    || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                    let delFile = "\(logDir)/\(file)"
                    fileUtil.RemoveItem(atPath: delFile)
                    }
                }
            }
         */
    }
    
    
    
    
    
    /// ログファイル操作処理
    public static func manageLogFile(){
        
        // ログ格納場所
        let logDir = CommonConst.logDir
        // ディレクトリの作成
        fileUtil.CreateDirectory(atPath: logDir)
        // 現在日時取得
        let nowdateYYYYMMdd_HH = DateUtil.GetDateFormatConvert(format: "YYYYMMdd_HH")
        // ファイル名を作成
        let fileName = "\(applicationName)_\(nowdateYYYYMMdd_HH)0000.log"
        let filePath = logDir + "/" + fileName
        
        let nowDate = DateUtil.GetDateFormatConvert(format: "YYYY-MM-dd HH:mm:ss")
        
        
        /// 対象ディレクトリ内にファイル名が存在するか確認
        // ファイルが存在しない場合
        if !fileUtil.FileExists(atPath: filePath){
            // ファイル作成
            fileUtil.CreateFile(atPath: filePath, contents: nil)
            // ログファイル削除
            self.removeLogFile()
        }
        // 書き込み(追記)
        fileUtil.AppendToFile(text: "\(nowDate)  -> テスト", fileName: filePath)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: LogUtil().className , functionName: #function , message: "")
    }
    
    /// ログファイル削除処理
    private static func removeLogFile(){
        // 現在日付 - 7日　を取得する
        let before7Dt : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let before7DtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd_HH", dt: before7Dt)
        
        let logDir = CommonConst.logDir
        
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
        
        let applicationNameLength = applicationName.utf8.count
        let startIndexPoint = applicationNameLength + 1
        let endIndexPoint = -9
        
        for file in allFiles{
            let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
            let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
            let YYYYMMdd_HH = file[startIndex...endIndex]
            //print(YYYYMMdd_HH)
            // ７日前以前のログファイルを削除する
            if (YYYYMMdd_HH.compare(before7DtStr) == .orderedAscending
                || YYYYMMdd_HH.compare(before7DtStr) == .orderedSame) {
                let delFile = "\(logDir)/\(file)"
                fileUtil.RemoveItem(atPath: delFile)
            } else {
                break
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: LogUtil().className , functionName: #function , message: "")
    }
}
