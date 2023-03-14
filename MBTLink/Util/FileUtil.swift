//
// FileUtil.swift
// ファイル入出力機能クラス
//
// MBTLink
//

import Foundation

class FileUtil {
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: FileUtil.self).split(separator: "-")[0])
    /// Documents/hogeディレクトリ内の操作
    private let fileManager = FileManager.default
    /// ルートディレクトリ
    private let rootDirectory = NSHomeDirectory() + "/Documents"
    var usedcount : Int = 0

    // MARK: - Public Methods
    /// イニシャライザ
    init() {
        // ルートディレクトリを作成する
        self.CreateDirectory(atPath: "")
    }

    /// ディレクトリを作成する
    /// - Parameter path: 対象パス
    func CreateDirectory(atPath path: String) {
        if self.FileExists(atPath: path) {
                return
        }
            
        do {
//            try fileManager.createDirectory(atPath: self.convertPath(path), withIntermediateDirectories: false, attributes: nil)
            try fileManager.createDirectory(atPath: self.convertPath(path), withIntermediateDirectories: true, attributes: nil)
            //システムログ作成、送信
            //アプリクラッシュ
            //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        } catch let error {
            print(error.localizedDescription)
            //システムログ作成、送信
            //アプリクラッシュ
            //LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: error.localizedDescription)
            
        }
    }

    /// ファイルを作成する
    /// - Parameters:
    ///   - path: 保存先ファイルパス
    ///   - contents: コンテンツ
    func CreateFile(atPath path: String, contents: Data?) {
        if !fileManager.createFile(atPath: self.convertPath(path), contents: contents, attributes: nil) {
            print("Create file error")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Create file error")
        }
    }

    /// ファイルがあるか確認する
    /// - Parameter path: 対象ファイルパス
    /// - Returns: ファイルがあるかどうか
    func FileExists(atPath path: String) -> Bool {
        //アプリクラッシュ
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return fileManager.fileExists(atPath: self.convertPath(path))
    }

    /// 対象パスがディレクトリか確認する
    /// - Parameter path: 対象パス
    /// - Returns:ディレクトリかどうか（存在しない場合もfalse）
    func IsDirectory(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: self.convertPath(path), isDirectory: &isDirectory)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return isDirectory.boolValue
    }

    /// ファイルを移動する
    /// - Parameters:
    ///   - srcPath: 移動元ファイルパス
    ///   - dstPath: 移動先ファイルパス
    func MoveItem(atPath srcPath: String, toPath dstPath: String) {
        // 移動先に同名ファイルが存在する場合はエラー
        do {
            try fileManager.moveItem(atPath: self.convertPath(srcPath), toPath: self.convertPath(dstPath))
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        } catch let error {
            print(error.localizedDescription)
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: error.localizedDescription)
        }
    }

    /// ファイルをコピーする
    /// - Parameters:
    ///   - srcPath: コピー元ファイルパス
    ///   - dstPath: コピー先ファイルパス
    func CopyItem(atPath srcPath: String, toPath dstPath: String) {
        // コピー先に同名ファイルが存在する場合はエラー
        do {
            try fileManager.copyItem(atPath: self.convertPath(srcPath), toPath: self.convertPath(dstPath))
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        } catch let error {
            print(error.localizedDescription)
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: error.localizedDescription)
        }
    }

    /// ファイルを削除する
    /// - Parameter path: 対象ファイルパス
    func RemoveItem(atPath path: String) {
        do {
            try fileManager.removeItem(atPath: self.convertPath(path))
        } catch let error {
            print(error.localizedDescription)
        }
    }

    /// ファイルをリネームする
    /// - Parameters:
    ///   - path: 対象ファイルパス
    ///   - newName: 変更後のファイル名
    func RenameItem(atPath path: String, to newName: String) {
        let srcPath = path
        let dstPath = NSString(string: NSString(string: srcPath).deletingLastPathComponent).appendingPathComponent(newName)
        self.MoveItem(atPath: srcPath, toPath: dstPath)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    // ディレクトリ内のアイテムのパスを取得する
    /// - Parameter path: 対象ディレクトリパス
    /// - Returns:対象ディレクトリ内のアイテムのパス一覧
    func ContentsOfDirectory(atPath path: String) -> [String] {
        do {
            return try fileManager.contentsOfDirectory(atPath: self.convertPath(path))
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }

    /// ディレクトリ内のアイテムのパスを再帰的に取得する
    /// - Parameter path: 対象ディレクトリパス
    /// - Returns:対象ディレクトリ内のアイテムのパス一覧
    func SubpathsOfDirectory(atPath path: String) -> [String] {
        do {
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            return try fileManager.subpathsOfDirectory(atPath: self.convertPath(path))
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }

    /// ファイル情報を取得する
    /// - Parameter path: 対象ファイルパス
    /// - Returns: 対象ファイルの情報（作成日など）
    func AttributesOfItem(atPath path: String) -> [FileAttributeKey : Any] {
        do {
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            return try fileManager.attributesOfItem(atPath: self.convertPath(path))
        } catch let error {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    /// ファイル書き込み
    func WritingToFile(text: String, fileName:String) {
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                fatalError("フォルダURL取得エラー")
        }

        let fileURL = dirURL.appendingPathComponent(fileName)
     
        /// ファイルの書き込み
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// ファイル書き込み(追記)
    func AppendToFile(text: String, fileName:String) {
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                fatalError("フォルダURL取得エラー")
        }

        let fileURL = dirURL.appendingPathComponent(fileName)
     
        /// ファイルの書き込み
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = "\n" + text
            // 一番後ろにシーク
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: .utf8)!)
        } catch {
            print("Error: \(error)")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ファイル読み込み
    func ReadFromFile(fileName:String) -> String {
            
        /// ①DocumentsフォルダURL取得
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                fatalError("フォルダURL取得エラー")
        }
            
        /// ②対象のファイルURL取得
        let fileURL = dirURL.appendingPathComponent(fileName)
     
        /// ③ファイルの読み込み
        guard let fileContents = try? String(contentsOf: fileURL) else {
                fatalError("ファイル読み込みエラー")
        }
            
        /// ④読み込んだ内容を戻り値として返す
        return fileContents
    }
    
    /// パス変換
    private func convertPath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return self.rootDirectory + path
        }
        
        return self.rootDirectory + "/" + path
    }
    
    func fileDel(csvFileNameStr : String, targetFile : String){
        //ファイル削除
        // 現在日付 - ２日　を取得する
        // MEMO : 10日→２日保持に変更
        let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
        let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
        
        let logDir = "Receive"
            
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        let startIndexPoint = csvFileNameStr.utf8.count
        let endIndexPoint = -5
        for file in allFiles{
                // ７日前以前のログファイルを削除する
                if file.contains(targetFile) {
                    let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                    let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                    let YYYYMMdd_HH = file[startIndex...endIndex]
                    //print(YYYYMMdd_HH)
                    //print(beforeDtStr)
                    
                    if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                        || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                        let delFile = "\(logDir)/\(file)"
                        RemoveItem(atPath: delFile)
                    }
                }
        }
    }
}
