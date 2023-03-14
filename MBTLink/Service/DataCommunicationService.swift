//
// DataCommunicationService.swift
// データ通信関連サービス
//
// MBTLink
//

import Foundation

class DataCommunicationService : NSObject {
    // MARK: - enum
    /// デバイス種別
    enum DeviceType : Int{
        /// デバイスデータなし
        case NoData = 0
        /// スマートウォッチ
        case SmartWatch = 1
        /// 環境センサ
        case EnvSensor = 10
        ///体重計
        case WeightScale = 20
        ///体温計
        case Thermometer = 21
        ///血圧計
        case BloodPressuresMonitor = 22
        ///パルスオキシメータ
        case PulseOximeter = 23
    }
    
    /// 送信データ種別・デバイスデータなし
    enum SendDataTypeNoData : Int{
        /// 位置情報
        case Location = 1
    }
    /// 送信データ種別・スマートウォッチ
    enum SendDataTypeSmartWatch : Int{
        /// ペアリング情報
        case Pairing = 0
        /// 心拍数、血圧、SpO2データ
        case HeartBpSpo2 = 1
        /// 歩数データ
        case Step = 2
        /// 睡眠データ
        case Sleep = 3
        ///　心拍数データ履歴
        case Heart24 = 11
        /// 歩数データ履歴
        case Step24 = 12
        /// 睡眠データ履歴
        case Sleep24 = 13
    }
    /// 送信データ種別・パルスオキシメーター
    enum SendDataTypePulseOximeter : Int{
        /// ペアリング情報
        case Pairing = 0
        /// スポット測定データ
        case Spot = 1
        /// モニタリング測定データ
        case Monitoring = 2
    }
    /// 送信データ種別・その他
    enum SendDataTypeOther : Int{
        /// ペアリング情報
        case Pairing = 0
        /// 測定データ
        case Measurement = 1
    }
    
    // MARK: - public変数
    /// 位置情報受信タイマー
    public var LocationReceiveTimer: Timer!
    //メソッド実行回数のカウント
    private var LocationReceiveCount : Int = 0
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( DataCommunicationService.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// 位置情報サービス
    //private var locationService : LocationService!
    public var locationService : LocationService!
    /// 要求連番
    private static var requestSeqNo : Int = 0
    //static let dataCommunicationService = DataCommunicationService()
    
    
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
        self.locationService = LocationService()
    }
    
    /// POST送信
    func PostSend(data : Data){
        // ログ出力
//        LogUtil.manageLogFile()

        // 送信先URL
        let key = "key" + "_" + "userSettingData"
        let userSetting = UserDefaults.standard.getUserSetting(key)
        
        guard let url = URL(string: (userSetting?.dataServerURL ?? "") + CommonConst.DataSendUri) else { return }
        //print((userSetting?.dataServerURL ?? "") + CommonConst.DataSendUri)
        // URLリクエスト
        var request = URLRequest(url: url)
        // POST
        request.httpMethod = "POST"
        // ヘッダー
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // 送信データ
        let jsonValue = self.CreateSendData(data: data)
        //print(jsonValue)
        //print(data)
        let jsonValueStr : String = String(data: jsonValue, encoding: .utf8)!
        print(jsonValueStr)
        request.httpBody = jsonValue
        
        // データ送信
        URLSession.shared.dataTask(with: request) {(data, response, error) in

            if let error = error {
                //CommonUtil.Print(className: self.className, message: "エラーが発生しました。: \(error)")
                LogUtil.createResendFile(json: jsonValueStr, fileType: "Data")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Error occured: \(error)")
                LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Error occured: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    //CommonUtil.Print(className: self.className, message: "応答のステータスコードが成功ではありませんでした。: \(response.statusCode)")
                    LogUtil.createResendFile(json: jsonValueStr, fileType: "Data")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "The status code of response is not successful: \(response.statusCode)")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "The status code of response is not successful: \(response.statusCode)")
                    return
                }
            }

            if let data = data {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let result = jsonDict!["result"] as! String
                    let error = jsonDict!["error"] as! Int

                    CommonUtil.Print(className: self.className, message: "result:\(result) error:\(error)")
                } catch {
                    //CommonUtil.Print(className: self.className, message: "レスポンスの解析でエラーが発生しました。")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "error occurred during JSONSerialization of response")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "error occurred during JSONSerialization of response")
                }
            } else {
                //CommonUtil.Print(className: self.className, message: "予期せぬエラーが発生しました。")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "An unexpected error has occurred")
                LogUtil.createErrorLog(className: self.className, functionName: #function, message: "An unexpected error has occurred")
            }
        }.resume()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //ログ送信
    public static func postSendLogMsg(msg : String,deviceID : String,deviceAdr : String,deviceType : Int){
        // 送信先URL
        let key = "key" + "_" + "userSettingData"
        let userSetting = UserDefaults.standard.getUserSetting(key)
        
        guard let url = URL(string: (userSetting?.dataServerURL ?? "") + CommonConst.LogSendUri) else { return }
        //print(url)
        // URLリクエスト
        var request = URLRequest(url: url)
        // POST
        request.httpMethod = "POST"
        // ヘッダー
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // 送信データ
        let jsonValue = DataCommunicationService().CreateSendDataForConnectStatus(logMsg : msg,deviceID: deviceID,deviceAdr: deviceAdr,deviceType: deviceType)
        //print(jsonValue)
        let jsonValueStr : String = String(data: jsonValue, encoding: .utf8)!
        request.httpBody = jsonValue

        // データ送信
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if let error = error {
                //print("エラーが発生しました。: \(error)")
                LogUtil.createResendFile(json: jsonValueStr, fileType: "Log")
                // FIXME: ネットワークエラーによるループ処理を停止させるために"Error occured"が入ったエラーログ送信を停止させている、createSystemLogメソッド要修正
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "Error occured: \(error)")
                LogUtil.createErrorLog(className: DataCommunicationService().className , functionName: #function, message: "Error occured: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    print("応答のステータスコードが成功ではありませんでした。: \(response.statusCode)")
                    LogUtil.createResendFile(json: jsonValueStr, fileType: "Log")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "The status code of response is not successful: \(response.statusCode)")
                    LogUtil.createErrorLog(className: DataCommunicationService().className , functionName: #function, message: "The status code of response is not successful: \(response.statusCode)")
                    return
                }
            }

            if let data = data {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    //let result = jsonDict!["result"] as! String
                    //let error = jsonDict!["error"] as! Int

                    //print("result:\(result) error:\(error)")
                } catch {
                    print("レスポンスの解析でエラーが発生しました。")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "error occurred during JSONSerialization of response")
                    LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "error occurred during JSONSerialization of response")
                }
            } else {
                print("予期せぬエラーが発生しました。")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "An unexpected error has occurred")
                LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "An unexpected error has occurred")
            }
        }.resume()
    }
    
    ///接続状態ログ送信
    func postSendLogMsg(msg : String,deviceID : String,deviceAdr : String,deviceType : Int){
        // 送信先URL
        let key = "key" + "_" + "userSettingData"
        let userSetting = UserDefaults.standard.getUserSetting(key)
        
        guard let url = URL(string: (userSetting?.dataServerURL ?? "") + CommonConst.LogSendUri) else { return }
        print(url)
        // URLリクエスト
        var request = URLRequest(url: url)
        // POST
        request.httpMethod = "POST"
        // ヘッダー
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // 送信データ
        let jsonValue = self.CreateSendDataForConnectStatus(logMsg : msg,deviceID: deviceID,deviceAdr: deviceAdr,deviceType: deviceType)
        //print(jsonValue)
        let jsonValueStr : String = String(data: jsonValue, encoding: .utf8)!
        request.httpBody = jsonValue

        // データ送信
        URLSession.shared.dataTask(with: request) {(data, response, error) in

            if let error = error {
                print("エラーが発生しました。: \(error)")
                LogUtil.createResendFile(json: jsonValueStr, fileType: "Log")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Error occured: \(error)")
                LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Error occured: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    print("応答のステータスコードが成功ではありませんでした。: \(response.statusCode)")
                    LogUtil.createResendFile(json: jsonValueStr, fileType: "Log")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "The status code of response is not successful: \(response.statusCode)")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "The status code of response is not successful: \(response.statusCode)")
                    return
                }
            }

            if let data = data {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let result = jsonDict!["result"] as! String
//                    let error = jsonDict!["error"] as! Int

                    print("result:\(result)")
                } catch {
                    print("レスポンスの解析でエラーが発生しました。")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "error occurred during JSONSerialization of response")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "error occurred during JSONSerialization of response")
                }
            } else {
                print("予期せぬエラーが発生しました。")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "An unexpected error has occurred")
                LogUtil.createErrorLog(className: self.className, functionName: #function, message: "An unexpected error has occurred")
            }
        }.resume()
    }
    
    //データの再送信
    func postResendData(data : Data){
            // ログ出力
    //        LogUtil.manageLogFile()

            // 送信先URL
            let key = "key" + "_" + "userSettingData"
            let userSetting = UserDefaults.standard.getUserSetting(key)
            
            guard let url = URL(string: (userSetting?.dataServerURL ?? "") + CommonConst.DataSendUri) else { return }
            //print((userSetting?.dataServerURL ?? "") + CommonConst.DataSendUri)
            // URLリクエスト
            var request = URLRequest(url: url)
            // POST
            request.httpMethod = "POST"
            // ヘッダー
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // 送信データ
            //let jsonValue = self.CreateSendData(data: data)
            //print(jsonValue)
            //print(data)
            let jsonValueStr : String = String(data: data, encoding: .utf8)!
            request.httpBody = data
            
            // データ送信
            URLSession.shared.dataTask(with: request) {(data, response, error) in

                if let error = error {
                    //CommonUtil.Print(className: self.className, message: "エラーが発生しました。: \(error)")
                    LogUtil.createResendFile(json: jsonValueStr, fileType: "Data")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Error occured: \(error)")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Error occured: \(error)")
                    return
                }

                if let response = response as? HTTPURLResponse {
                    if !(200...299).contains(response.statusCode) {
                        //CommonUtil.Print(className: self.className, message: "応答のステータスコードが成功ではありませんでした。: \(response.statusCode)")
                        LogUtil.createResendFile(json: jsonValueStr, fileType: "Data")
                        LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "The status code of response is not successful: \(response.statusCode)")
                        LogUtil.createErrorLog(className: self.className, functionName: #function, message: "The status code of response is not successful: \(response.statusCode)")
                        return
                    }
                }

                if let data = data {
                    do {
                        let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let result = jsonDict!["result"] as! String
                        let error = jsonDict!["error"] as! Int

                        CommonUtil.Print(className: self.className, message: "result:\(result) error:\(error)")
                    } catch {
                        //CommonUtil.Print(className: self.className, message: "レスポンスの解析でエラーが発生しました。")
                        LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "error occurred during JSONSerialization of response")
                        LogUtil.createErrorLog(className: self.className, functionName: #function, message: "error occurred during JSONSerialization of response")
                    }
                } else {
                    //CommonUtil.Print(className: self.className, message: "予期せぬエラーが発生しました。")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "An unexpected error has occurred")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "An unexpected error has occurred")
                }
            }.resume()
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        
    }
    
    //ログの再送信
    func postResendLogMsg(data : Data){
        // 送信先URL
        let key = "key" + "_" + "userSettingData"
        let userSetting = UserDefaults.standard.getUserSetting(key)
        
        guard let url = URL(string: (userSetting?.dataServerURL ?? "") + CommonConst.LogSendUri) else { return }
        print(url)
        // URLリクエスト
        var request = URLRequest(url: url)
        // POST
        request.httpMethod = "POST"
        // ヘッダー
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // 送信データ
        //let jsonValue = self.CreateSendDataForConnectStatus(logMsg : msg,deviceID: deviceID,deviceAdr: deviceAdr,deviceType: deviceType)
        //print(jsonValue)
        let jsonValueStr : String = String(data: data, encoding: .utf8)!
        request.httpBody = data

        // データ送信
        URLSession.shared.dataTask(with: request) {(data, response, error) in

            if let error = error {
                print("エラーが発生しました。: \(error)")
                LogUtil.createResendFile(json: jsonValueStr, fileType: "Log")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Error occured: \(error)")
                LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Error occured: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    print("応答のステータスコードが成功ではありませんでした。: \(response.statusCode)")
                    LogUtil.createResendFile(json: jsonValueStr, fileType: "Log")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "The status code of response is not successful: \(response.statusCode)")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "The status code of response is not successful: \(response.statusCode)")
                    return
                }
            }

            if let data = data {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let result = jsonDict!["result"] as! String
//                    let error = jsonDict!["error"] as! Int

                    print("result:\(result)")
                } catch {
                    print("レスポンスの解析でエラーが発生しました。")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "error occurred during JSONSerialization of response")
                    LogUtil.createErrorLog(className: self.className, functionName: #function, message: "error occurred during JSONSerialization of response")
                }
            } else {
                print("予期せぬエラーが発生しました。")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "An unexpected error has occurred")
                LogUtil.createErrorLog(className: self.className, functionName: #function, message: "An unexpected error has occurred")
            }
        }.resume()
    }
    
    
    
    /// 位置情報受信タイマーStart
    func StartLocationReceiveTimer(){
        let message = "位置情報受信タイマー"
        CommonUtil.Print(className: self.className, message: message + "Start")
        
        if self.LocationReceiveTimer == nil {
            // タイマー設定
            self.LocationReceiveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(locationReceive), userInfo: nil, repeats: true)
            
            CommonUtil.Print(className: self.className, message: message + "設定完了")
            
            // タイマーStart
            self.LocationReceiveTimer.fire()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 位置情報受信タイマーStop
    func StopLocationReceiveTimer(){
        let message = "位置情報受信タイマー"
        CommonUtil.Print(className: self.className, message: message +  "Stop")

        if self.LocationReceiveTimer != nil && self.LocationReceiveTimer.isValid {
            // タイマーを停止
            self.LocationReceiveTimer.invalidate()
            self.LocationReceiveTimer = nil
            
            CommonUtil.Print(className: self.className, message: message +  "Stop完了")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //位置情報送信タイマー開始
     func startLocationSendTimer(){
         let locationInterval = LocationInfoSettingTableViewController.loadLocationInfoSettingData()?.ShortestSendInterval.replacingOccurrences(of: StringsConst.MINUTES, with: "")
        if TopViewController.locationSendTimer == nil{
            //タイマー設定
            TopViewController.locationSendTimer = Timer.scheduledTimer(timeInterval: Double(locationInterval!)! * 60, target: self, selector: #selector(locationDataSendMonitor), userInfo: nil, repeats: true)
            print(Double(locationInterval!)! * 60)
            
            // タイマーStart
            TopViewController.locationSendTimer.fire()
        }
         //システムログ作成、送信
         LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //位置情報送信タイマー終了
    func stopLocationSendTimer(){
        
        if TopViewController.locationSendTimer != nil && TopViewController.locationSendTimer.isValid {
            // タイマーを停止
            TopViewController.locationSendTimer.invalidate()
            TopViewController.locationSendTimer = nil
            
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
   
    
    // MARK: - Private Methods
    
    /// 送信データ作成
    private func CreateSendData(data : Data) -> Data{
    
        let com = self.CreateCommonJson()
        // JSON結合
        let sendData = CommonUtil.JsonJoin(json1: com, Json2: data)
        
        //CommonUtil.Print(className: self.className, message: String(bytes: sendData, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return sendData
    }
    
    /// 共通JSON作成
    private func CreateCommonJson() -> Data{
        var com = CommonCodable.Common()
        ///位置情報送信フラグがtrueだったらデータをセット
        let locationInfo = LocationInfoSettingTableViewController.loadLocationInfoSettingData()
        let SendStart : Int32?
        let SendEnd : Int32?
        let dateNow = Int32(DateUtil.GetDateFormatConvert(format: "HHmm"))
        
        if let start = locationInfo?.LocationInfoSendStart {
            SendStart = Int32((start.replacingOccurrences(of: ":", with: "")))
        }else {
            SendStart = nil
        }
        if let end = locationInfo?.LocationInfoSendEnd {
            SendEnd = Int32((end.replacingOccurrences(of: ":", with: "")))
        }else {
            SendEnd = nil
        }
        
        if locationInfo?.IsLocationInfoSend ?? false {
            if locationInfo?.LocationInfoSendMethodNum == 0{
                ///位置情報(緯度)
                com.GPS_LAT = self.locationService.GetLatitude()
                ///位置情報(経度)
                com.GPS_LNG = self.locationService.GetLongitude()
            }else if SendStart != nil || SendEnd != nil {
                if SendStart == SendEnd ||
                    (SendStart! <= dateNow! && dateNow! <= SendEnd! ){
                    ///位置情報(緯度)
                    com.GPS_LAT = self.locationService.GetLatitude()
                    ///位置情報(経度)
                    com.GPS_LNG = self.locationService.GetLongitude()
                }
            }
        }
        
        ///タイムゾーン
        com.TIME_ZONE = DateUtil.GetTimeZone()
        
        ///データ送信日時(YYYYMMDDhhmmss)
        com.POST_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        ///連番 (IoTゲートウェイ起動時からの要求連番 1～65534)
        DataCommunicationService.requestSeqNo+=1
        com.TSN = String(DataCommunicationService.requestSeqNo)
        
        com.setUserSetting()
        // @@@旧フォーマット
//        var com = CommonCodable.OldCommon()
//        com.setUserSetting()
//        ///位置情報(緯度)
//        com.GPS_LAT = self.locationService.GetLatitude()
//        ///位置情報(経度)
//        com.GPS_LONG = self.locationService.GetLongitude()
//        ///データ送信日時(YYYYMMDDhhmmss)
//        com.DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
//        ///連番 (EasyUplink起動時からの要求連番 1～65534)
//        self.requestSeqNo+=1
//        com.TSN = String(self.requestSeqNo)
        //print(com)
        
        // JSONへ変換
        
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(com) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    
    ///アプリバージョン通知json作成
    static func CreateAppVersionJson() -> Data{
        var appVersion = CommonCodable.AppVersion()
        print(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        appVersion.MODULE_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        appVersion.setUserSetting()

        //print(appVersion)
        
        // JSONへ変換
        
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(appVersion) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: DataCommunicationService().className , functionName: #function , message: "")
        return jsonValue
    }
    
    ///位置情報受信
    @objc func locationReceive() {
        self.locationService.LocationUpdate()
        if LocationReceiveCount == 60{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            LocationReceiveCount = 0
        }else{
            LocationReceiveCount += 1
        }
    }
    
    //位置情報送信処理
    @objc func locationDataSendMonitor(){
        let locationInfo = LocationInfoSettingTableViewController.loadLocationInfoSettingData()
        let SendMethod : Int? = locationInfo?.LocationInfoSendMethodNum
        let SendStart : Int32?
        let SendEnd : Int32?
        let dateNow = Int32(DateUtil.GetDateFormatConvert(format: "HHmm"))
        
        if let start = locationInfo?.LocationInfoSendStart {
            SendStart = Int32((start.replacingOccurrences(of: ":", with: "")))
        }else {
            SendStart = nil
        }
        if let end = locationInfo?.LocationInfoSendEnd {
            SendEnd = Int32((end.replacingOccurrences(of: ":", with: "")))
        }else {
            SendEnd = nil
        }
        
//        let dateNow = Int32(DateUtil.GetDateFormatConvert(format: "HHmm"))
//        let SendStart = Int32((locationInfo?.LocationInfoSendStart.replacingOccurrences(of: ":", with: ""))!)
//        let SendEnd = Int32((locationInfo?.LocationInfoSendEnd.replacingOccurrences(of: ":", with: ""))!)
        
        CommonUtil.Print(className: self.className, message: "Start:" + String(SendStart!))
        CommonUtil.Print(className: self.className, message: "End:" + String(SendEnd!))
        CommonUtil.Print(className: self.className, message: "Now:" + String(dateNow!))
        
        // 常時通知選択 or 選択した時刻内の場合　→ 送信
        if SendMethod != nil && (SendStart != nil || SendEnd != nil) {
            if (SendMethod == 0) || (SendStart! <= dateNow! && dateNow! <= SendEnd!){
                //位置情報送信
                var json : Data!
                json  = self.locationService.CreateSendDataJson(deviceType: DataCommunicationService.DeviceType.NoData.rawValue, sendDataType: DataCommunicationService.SendDataTypeNoData.Location.rawValue)
                // データ送信
                self.PostSend(data: json)
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    ///アプリバージョン通知
    static func postSendAppVersion(){
        // 送信先URL
        let key = "key" + "_" + "userSettingData"
        let userSetting = UserDefaults.standard.getUserSetting(key)
        
        guard let url = URL(string: (userSetting?.dataServerURL ?? "") + CommonConst.VersionNotice) else { return }
        //print((userSetting?.dataServerURL ?? "") + CommonConst.VersionNotice)
        // URLリクエスト
        var request = URLRequest(url: url)
        // POST
        request.httpMethod = "POST"
        // ヘッダー
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // 送信データ
        let jsonValue = CreateAppVersionJson()
        //print(jsonValue)
        request.httpBody = jsonValue
        
        // データ送信
        URLSession.shared.dataTask(with: request) {(data, response, error) in

            if let error = error {
                //print("エラーが発生しました。: \(error)")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "Error occured: \(error)")
                LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "Error occured: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    //print("応答のステータスコードが成功ではありませんでした。: \(response.statusCode)")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "The status code of response is not successful: \(response.statusCode)")
                    LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "The status code of response is not successful: \(response.statusCode)")
                    return
                }
            }

            if let data = data {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let result = jsonDict!["result"] as! String
                    let error = jsonDict!["error"] as! Int

                    print("result:\(result) error:\(error)")
                } catch {
                    //print("レスポンスの解析でエラーが発生しました。")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "error occurred during JSONSerialization of response")
                    LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "error occurred during JSONSerialization of response")
                }
            } else {
                //print("予期せぬエラーが発生しました。")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "An unexpected error has occurred")
                LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "An unexpected error has occurred")
            }
        }.resume()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: DataCommunicationService().className , functionName: #function , message: "")
    }
    
    ///通知
    static func postSendPairing(data : Data){
        // 送信先URL
        let key = "key" + "_" + "userSettingData"
        let userSetting = UserDefaults.standard.getUserSetting(key)
        
        guard let url = URL(string: (userSetting?.dataServerURL ?? "") + CommonConst.DataSendUri) else { return }
        //print((userSetting?.dataServerURL ?? "") + CommonConst.DataSendUri)
        // URLリクエスト
        var request = URLRequest(url: url)
        // POST
        request.httpMethod = "POST"
        // ヘッダー
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // 送信データ
        let jsonValue = CreateSendDataForParing(data: data)
        //print(jsonValue)
        let jsonValueStr : String = String(data: jsonValue, encoding: .utf8)!
        request.httpBody = jsonValue
        
        // データ送信
        URLSession.shared.dataTask(with: request) {(data, response, error) in

            if let error = error {
                //print("エラーが発生しました。: \(error)")
                LogUtil.createResendFile(json: jsonValueStr, fileType: "Data")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "Error occured: \(error)")
                LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "Error occured: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    //print("応答のステータスコードが成功ではありませんでした。: \(response.statusCode)")
                    LogUtil.createResendFile(json: jsonValueStr, fileType: "Data")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "The status code of response is not successful: \(response.statusCode)")
                    LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "The status code of response is not successful: \(response.statusCode)")
                    return
                }
            }

            if let data = data {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let result = jsonDict!["result"] as! String
                    let error = jsonDict!["error"] as! Int

                    print("result:\(result) error:\(error)")
                } catch {
                    //print("レスポンスの解析でエラーが発生しました。")
                    LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "error occurred during JSONSerialization of response")
                    LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "error occurred during JSONSerialization of response")
                }
            } else {
                //print("予期せぬエラーが発生しました。")
                LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "An unexpected error has occurred")
                LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "An unexpected error has occurred")
            }
        }.resume()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: DataCommunicationService().className , functionName: #function , message: "")
    }
    
    ///ペアリング共通json作成
    static func CreatePairingCommon() -> Data{
        var com = CommonCodable.Common()
        ///位置情報送信フラグがtrueだったらデータをセット
        let locationInfo = LocationInfoSettingTableViewController.loadLocationInfoSettingData()
        let SendStart : Int32?
        let SendEnd : Int32?
        let dateNow = Int32(DateUtil.GetDateFormatConvert(format: "HHmm"))
        
        if let start = locationInfo?.LocationInfoSendStart {
            SendStart = Int32((start.replacingOccurrences(of: ":", with: "")))
        }else {
            SendStart = nil
        }
        if let end = locationInfo?.LocationInfoSendEnd {
            SendEnd = Int32((end.replacingOccurrences(of: ":", with: "")))
        }else {
            SendEnd = nil
        }
        
        if locationInfo?.IsLocationInfoSend ?? false {
            if SendStart != nil || SendEnd != nil {
                if SendStart == SendEnd ||
                    (SendStart! <= dateNow! && dateNow! <= SendEnd! ){
                    ///位置情報(緯度)
                    com.GPS_LAT = LocationService.GetLatitudeStatic()
                    ///位置情報(経度)
                    com.GPS_LNG = LocationService.GetLongitudeStatic()
                }
            }
        }

        ///タイムゾーン
        com.TIME_ZONE = DateUtil.GetTimeZone()
        
        ///データ送信日時(YYYYMMDDhhmmss)
        com.POST_DATE = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        ///連番 (IoTゲートウェイ起動時からの要求連番 1～65534)
        DataCommunicationService.requestSeqNo+=1
        com.TSN = String(DataCommunicationService.requestSeqNo)
        
        com.setUserSetting()
        //print(com)
        
        // JSONへ変換
        
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(com) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: DataCommunicationService().className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: DataCommunicationService().className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: DataCommunicationService().className , functionName: #function , message: "")
        return jsonValue
    }
    
    /// 送信データ作成
    static func CreateSendDataForParing(data : Data) -> Data{
    
        let com = CreatePairingCommon()
        // JSON結合
        let sendData = CommonUtil.JsonJoin(json1: com, Json2: data)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: DataCommunicationService().className , functionName: #function , message: "")
        return sendData
    }
    
    ///ログ送信用json作成
    ///args : 接続状態（切断時→Disconnect　接続時→Connected）
    func CreateSendDataForConnectStatus(logMsg : String,deviceID : String,deviceAdr : String,deviceType : Int) -> Data{
        var log = LogCodable()
        ///ログメッセージ設定
        log.LOG_MSG = logMsg
        log.DEVICE_ID = deviceID
        log.DEVICE_ADR = deviceAdr
        log.DEVICE_TYPE = deviceType
        
        log.setUserSetting()
        //print(log)
        
        // JSONへ変換
        
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(log) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }
        //システムログ作成、送信
        //ログ作成が無限ループになるため、使えない
        //アプリクラッシュ
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
}
