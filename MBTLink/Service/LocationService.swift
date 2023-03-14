//
// LocationService.swift
// 位置情報関連サービス
//
// MBTLink
//

import Foundation
import CoreLocation

final class LocationService: NSObject,CLLocationManagerDelegate {
    // MARK: - enum
    /// 受信レベル
    enum ReceiveLevel : String{
        case Low = "低"
        case Middle = "中"
        case High = "高"
    }
    /// ステータス
    enum Status : Int{
        case Prossesing = 1
        case Success = 2
    }
    
    // MARK: - Private変数
    //メソッド実行回数のカウント
    private var LocationUpdateCount : Int = 0
    private var DidUpdateLocationsCount : Int = 0
    private var GetLocationFileNameCount : Int = 0
    /// クラス名
    private let className = String(String(describing: ( LocationService.self)).split(separator: "-")[0])
    /// ロケーションマネジャー
    private var locationManager: CLLocationManager!
    /// 最終更新日
    private var lastUpdate : String = ""
    /// 緯度
    private var latitude : String = ""
    /// 経度
    private var longitude : String = ""
    /// ステータス
    private var status = Status.Prossesing.rawValue
    /// ファイル操作クラス
    private let fileUtil = FileUtil()
    /// 位置情報書き込みデータ
    private var writeData : String! = ""
    /// 位置情報ファイル名
    private var locationFileName : String!
    
    /// 緯度
    private static var latitudestatic : String = ""
    /// 経度
    private static var longitudestatic : String = ""
    
    // MARK: - Public Methods
    /// イニシャライザ
    override init(){
        super.init()
        //位置情報取得の設定
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        ///位置情報設定値
        let receiveLevel = LocationInfoSettingTableViewController.loadLocationInfoSettingData()?.LocationInfoReceiveLevel
        let receiveLevelStr = NSLocalizedString(receiveLevel ?? StringsConst.LOW, comment: "")
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        SetReceiveLevel(receiveLevel: receiveLevelStr)
        self.locationManager.distanceFilter = 1

        // バックグラウンドでの位置情報更新を許可
        self.locationManager.allowsBackgroundLocationUpdates = true
        // ロケーション更新の自動中断（デフォルトはONっぽい）_0124追加
        self.locationManager.pausesLocationUpdatesAutomatically = false
        // 位置情報ファイル保存ディレクトリ作成
        self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir)
        // 位置情報ファイル送信ディレクトリ作成
//        self.fileUtil.CreateDirectory(atPath: CommonConst.SendDir)
        
        
//        testIbeaconSetting()
    }
    
    /// 位置情報更新
    func LocationUpdate() {
        
        self.status = Status.Prossesing.rawValue
        // stop -> start で位置情報更新させる
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()

        //CommonUtil.Print(className: self.className, message: DateUtil.GetDateFormatConvert(format: "yyyy年MM月dd日 HH:mm:ss.SSS"))
        if LocationUpdateCount == 60{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            LocationUpdateCount = 0
        }else{
            LocationUpdateCount += 1
        }
    }
    
    /// 最終更新日取得
    func GetLastUpdate()-> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.lastUpdate
    }
    
    /// 緯度取得
    func GetLatitude()-> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.latitude
    }
    
    /// 経度取得
    func GetLongitude()-> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.longitude
    }
    /// ステータス取得
    func GetStatus() -> Int{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.status
    }
    
    static func GetLatitudeStatic()-> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: LocationService().className , functionName: #function , message: "")
        return LocationService.latitudestatic
    }
    
    static func GetLongitudeStatic()-> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: LocationService().className , functionName: #function , message: "")
        return LocationService.longitudestatic
    }
    
    /// 受信レベル設定
    func SetReceiveLevel(receiveLevel :  String){
        // 位置情報受信レベル
        switch receiveLevel{
        case NSLocalizedString(ReceiveLevel.Low.rawValue, comment: ""):
            // 3km以内（低）
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            break
        case NSLocalizedString(ReceiveLevel.Middle.rawValue, comment: ""):
            // 100m以内（中）
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            break
        case NSLocalizedString(ReceiveLevel.High.rawValue, comment: ""):
            // 最高精度（高）
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            break
        default:
            break
        }
        //システムログ作成、送信
        //init()の影響？、アプリクラッシュ
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

// MARK: - LocationManager関連イベント
    // 位置情報取得成功時
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationFileName =  self.getLocationFileName()
        
        let location : CLLocation = locations.last!
        
        self.lastUpdate = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss.SSS")
        self.latitude = String(location.coordinate.latitude)
        self.longitude = String(location.coordinate.longitude)
        self.status = Status.Success.rawValue
        LocationService.latitudestatic = String(location.coordinate.latitude)
        LocationService.longitudestatic = String(location.coordinate.longitude)
        //let printData :String = "位置情報取得成功 \(self.lastUpdate) 緯度：\(self.latitude) 経度：\(self.longitude)"

        //CommonUtil.Print(className: self.className, message: printData)
        var writeData : String = ""
        writeData.append(lastUpdate)
        writeData.append(",")
        writeData.append(String(location.coordinate.latitude))
        writeData.append(",")
        writeData.append(String(location.coordinate.longitude))
        
        if self.writeData == ""{
            self.writeData = writeData
        }
        else{
            self.writeData = self.writeData + "\n" + writeData
        }
        
        let receiveFileName = CommonConst.ReceiveDir + "/" + self.locationFileName
        // ファイル書き込み
//        self.fileUtil.WritingToFile(text: self.writeData,fileName: receiveFileName)
        if DidUpdateLocationsCount == 60{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            DidUpdateLocationsCount = 0
        }else{
            DidUpdateLocationsCount += 1
        }
    }

    // 位置情報取得失敗時
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        CommonUtil.Print(className: self.className, message: "位置情報取得失敗")
        
        // myLocationManager.stopUpdatingLocation()
        
        if #available(iOS 14.0, *){
            let status = manager.authorizationStatus
            if (status == .notDetermined) {
                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
                
                    // 常に許可するように求める
                self.locationManager.requestAlwaysAuthorization();
            }
        }
        else{
            if CLLocationManager.authorizationStatus() == .notDetermined {
                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
                
                self.locationManager.requestAlwaysAuthorization()
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 位置情報認証変更
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        // 位置情報の認証チェック
        if #available(iOS 14.0, *){
            let status = manager.authorizationStatus
            if  status == .notDetermined {
                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
                    
                    // 常に許可するように求める
                self.locationManager.requestAlwaysAuthorization();
            }
        }
        else{
            if CLLocationManager.authorizationStatus() == .notDetermined {
                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
                
                self.locationManager.requestAlwaysAuthorization()
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 位置情報ファイル名取得
    private func getLocationFileName() -> String{
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        if GetLocationFileNameCount == 60{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            GetLocationFileNameCount = 0
        }else{
            GetLocationFileNameCount += 1
        }
        return "locationInfo_" + dateString + ".txt"
    }
    
    ///位置情報送信json作成
    func CreateSendDataJson(deviceType : Int, sendDataType : Int) -> Data{
        // デバイス情報JSON作成
        let deviceInfoJson = self.createDeviceInfoJson(deviceType : deviceType, sendDataType : sendDataType)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return deviceInfoJson
    }
    
    /// デバイス情報JSON作成
    func createDeviceInfoJson(deviceType : Int ,sendDataType : Int)->Data{
        ///新フォーマット
        var dataInfo = CommonCodable.DataInfo()
        
        //デバイス種別
        dataInfo.DEVICE_TYPE = deviceType
        //送信データ種別
        dataInfo.DATA_TYPE = sendDataType
        
        // JSONへ変換
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(dataInfo) else {
            LogUtil.createSystemLog(logLevel:StringsConst.ERROR , className: self.className , functionName: #function , message: "Fail to encode JSON")
            LogUtil.createErrorLog(className: self.className, functionName: #function, message: "Fail to encode JSON")
            fatalError("JSON へのエンコードに失敗しました。")
        }

        // JSONデータ確認
        print("***** JSONデータ確認 *****")
        print(String(bytes: jsonValue, encoding: .utf8)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return jsonValue
    }
    

    
    /// iBeacon用の設定
//    let UUIDList = [
//        "544F594F-4E49-4353-8133-7236216EBA1B",
//        "544F594F-4E49-4353-8133-7236216EBA1C",
//        "544F594F-4E49-4353-8133-7236216EB10B",
//        "544F594F-4E49-4353-8133-7236216EB10C",
//        "00010203-0405-0607-0809-0A0B0C0D0E0F",
//    ]
//    let UUIDList = [
//        "00010203-0405-0607-0809-0A0B0C0D0E0F",
//        "544F594F-4E49-4353-8133-7236216EBA1B",
//        "544F594F-4E49-4353-8133-7236216EBA1C",
//        "544F594F-4E49-4353-8133-7236216EB10B",
//        "544F594F-4E49-4353-8133-7236216EB10C",
//        "544F594F-4E49-4353-8133-7236216EB91B",
//        "544F594F-4E49-4353-8133-7236216EB92B",
//        "544F594F-4E49-4353-8133-7236216EB93B",
//        "544F594F-4E49-4353-8133-7236216EB94B",
//        "544F594F-4E49-4353-8133-7236216EB95B",
//        "544F594F-4E49-4353-8133-7236216EB96B",
//        "544F594F-4E49-4353-8133-7236216EB97B",
//        "544F594F-4E49-4353-8133-7236216EB98B",
//        "544F594F-4E49-4353-8133-7236216EB81B",
//        "544F594F-4E49-4353-8133-7236216EB82B",
//        "544F594F-4E49-4353-8133-7236216EB83B",
//        "544F594F-4E49-4353-8133-7236216EB84B",
//        "544F594F-4E49-4353-8133-7236216EB85B",
//        "544F594F-4E49-4353-8133-7236216EB86B",
//        "544F594F-4E49-4353-8133-7236216EB87B",
//        "544F594F-4E49-4353-8133-7236216EB88B",
//        "53544152-4A50-4E40-8154-2631935EB11B",
//        "53544152-4A50-4E40-8154-2631935EB12B",
//        "544F594F-4E49-4353-8133-7236216EB13B",
//        "53544152-4A50-4E40-8154-2631935EB14B",
//        "544F594F-4E49-4353-8133-7236216BB01B",
//        "544F594F-4E49-4353-8133-7236216BB02B",
//        "544F594F-4E49-4353-8133-7236216BB03B",
//        "544F594F-4E49-4353-8133-7236216EBA1B",
//    ]
//    let UUIDList = [
//        "544F594F-4E49-4353-8133-7236216EB10C",
//        "544F594F-4E49-4353-8133-7236216EB91B",
//        "544F594F-4E49-4353-8133-7236216EB92B",
//        "544F594F-4E49-4353-8133-7236216EB93B",
//        "544F594F-4E49-4353-8133-7236216EB94B",
//        "544F594F-4E49-4353-8133-7236216EB95B",
//        "544F594F-4E49-4353-8133-7236216EB96B",
//        "544F594F-4E49-4353-8133-7236216EB97B",
//        "544F594F-4E49-4353-8133-7236216EB98B",
//        "544F594F-4E49-4353-8133-7236216EBA1C",
//        "544F594F-4E49-4353-8133-7236216EB81B",
//        "544F594F-4E49-4353-8133-7236216EB82B",
//        "544F594F-4E49-4353-8133-7236216EB83B",
//        "544F594F-4E49-4353-8133-7236216EB84B",
//        "544F594F-4E49-4353-8133-7236216EB85B",
//        "544F594F-4E49-4353-8133-7236216EB86B",
//        "544F594F-4E49-4353-8133-7236216EB87B",
//        "544F594F-4E49-4353-8133-7236216EB88B",
//        "53544152-4A50-4E40-8154-2631935EB11B",
//        "53544152-4A50-4E40-8154-2631935EB12B",
//        "53544152-4A50-4E40-8154-2631935EB14B",
//        "544F594F-4E49-4353-8133-7236216EBA1B",
//        "00010203-0405-0607-0809-0A0B0C0D0E0F",
//        "544F594F-4E49-4353-8133-7236216EB13B",
//    ]
//    let UUIDList = [
//        "53544152-4A50-4E40-8154-2631935EB11B",
//        "53544152-4A50-4E40-8154-2631935EB12B",
//        "544F594F-4E49-4353-8133-7236216EB13B",
//        "53544152-4A50-4E40-8154-2631935EB14B",
//        "544F594F-4E49-4353-8133-7236216BB01B",
//        "544F594F-4E49-4353-8133-7236216BB02B",
//        "544F594F-4E49-4353-8133-7236216BB03B",
//        "544F594F-4E49-4353-8133-7236216EBA1B",
//    ]
    
//    //var beaconRegion:CLBeaconRegion!
//    var beaconRegionDic : [String : CLBeaconRegion]! = [:]
//
//    /// iBeacon用の設定メソッド
//    func testIbeaconSetting(){
//
//        /// 位置情報の認証ステータスを取得
//        let status = CLLocationManager.authorizationStatus()
//        /// 位置情報の認証が許可されていない場合は認証ダイアログを表示
//        if (status != CLAuthorizationStatus.authorizedWhenInUse) {
//            locationManager.requestWhenInUseAuthorization()
//        }
//        ///S
//        // レンジングを始める前にロケーション更新を開始
//        locationManager.stopUpdatingLocation()
//
//        for strUuid in UUIDList{
//            let strUuidSub = String(strUuid.suffix(3))
//            print("testIbeacon, registUuid:\(strUuidSub)")
//            /// 受信対象のビーコンのUUIDを設定
//            //let uuid:UUID? = UUID(uuidString: "544F594F-4E49-4353-8133-7236216EBA1B")
//            let uuid:UUID? = UUID(uuidString: strUuid)
//            /// ビーコン領域の初期化
////            beaconRegion = CLBeaconRegion(uuid: uuid!, identifier: "iBeacon" + strUuid)
////            beaconRegion.notifyEntryStateOnDisplay = false
////            beaconRegion.notifyOnEntry = true
////            beaconRegion.notifyOnExit = true
////            self.locationManager.startMonitoring(for: beaconRegion)
//
//            let beaconRegion:CLBeaconRegion! = CLBeaconRegion(uuid: uuid!, identifier: "iBeacon" + strUuid)
//            beaconRegion.notifyEntryStateOnDisplay = true
//            beaconRegion.notifyOnEntry = true
//            beaconRegion.notifyOnExit = true
//            self.locationManager.startMonitoring(for: beaconRegion)
//            //保存
//            beaconRegionDic.updateValue(beaconRegion, forKey: strUuid)
//
//        }
//
//    }
//
//    // 位置情報の認証ステータス変更
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//        if (status == .authorizedWhenInUse) {
//            // ビーコン領域の観測を開始
//            print("testIbeacon:didChangeAuthorization")
//            //self.locationManager.startMonitoring(for: self.beaconRegion)
//            for strUuid in UUIDList{
//                let beaconRegion:CLBeaconRegion! = beaconRegionDic[strUuid]
//                self.locationManager.startMonitoring(for: beaconRegion)
//            }
//        }
//    }
//
//    // ビーコン領域の観測を開始
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        // ビーコン領域のステータスを取得
//        print("testIbeacon:1_didStartMonitoringFor")
////        self.locationManager.requestState(for: self.beaconRegion)
//            for strUuid in UUIDList{
//                let beaconRegion:CLBeaconRegion! = beaconRegionDic[strUuid]
//                self.locationManager.requestState(for: beaconRegion)
//            }
//    }
//
//    // ビーコン領域のステータスを取得
//    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
//
//        switch (state) {
//        case .inside: // ビーコン領域内
////            // ビーコンの測定を開始
//            print("testIbeacon:3_didDetermineState_inside")
//////            self.locationManager.startRangingBeacons(satisfying: self.beaconRegion.beaconIdentityConstraint)
////            for strUuid in UUIDList{
////                let beaconRegion:CLBeaconRegion! = beaconRegionDic[strUuid]
////                self.locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
////            }
//            break
//        case .outside: // ビーコン領域外
//            print("testIbeacon:3_didDetermineState_outside")
//            break
//
//        case .unknown: // 不明
//            print("testIbeacon:3_didDetermineState_unknown")
//            break
//
//        }
//    }
//
//    // ビーコン領域に入った時
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        // ビーコンの位置測定を開始
//        print("testIbeacon:2_didEnterRegion")
////            self.locationManager.startRangingBeacons(satisfying: self.beaconRegion.beaconIdentityConstraint)
//        for strUuid in UUIDList{
//            let beaconRegion:CLBeaconRegion! = beaconRegionDic[strUuid]
//            self.locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
//        }
//
//    }
//
//    // ビーコン領域から出た時
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        // ビーコンの位置測定を停止
//        print("testIbeacon:2_didExitRegion")
//        //            self.locationManager.stopRangingBeacons(satisfying: self.beaconRegion.beaconIdentityConstraint)
////                for strUuid in UUIDList{
////                    let beaconRegion:CLBeaconRegion! = beaconRegionDic[strUuid]
////                    self.locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
////                }
//    }
//
//    ///beacon監視でエラー。
//    private func locationManager(_ manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)      {
//
//        print("testIbeacon:2_withError")
//        //ex) 監視するbeaconが無効、beaconを２１種類以上登録した場合など
//    }
//
//    // ビーコンの位置測定
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
//
//        for beacon in beacons {
//            print("uuid:\(beacon.uuid)")
//            print("major:\(beacon.major)")
//            print("minor:\(beacon.minor)")
//            var beaconProximity:String = "unknown"
//            if (beacon.proximity == CLProximity.immediate) {
//                print("proximity:immediate")
//                beaconProximity = "immediate"
//            }
//            if (beacon.proximity == CLProximity.near) {
//                print("proximity:near")
//                beaconProximity = "near"
//            }
//            if (beacon.proximity == CLProximity.far) {
//                print("proximity:far")
//                beaconProximity = "far"
//            }
//            if (beacon.proximity == CLProximity.unknown) {
//                print("proximity:unknown")
//            }
//            print("accuracy:\(beacon.accuracy)")
//            print("rssi:\(beacon.rssi)")
//            print("timestamp:\(beacon.timestamp)")
//
//            //beaconDataの保存
//            let strUuid = beacon.uuid.uuidString
//            let strMajorId = beacon.major.stringValue
//            let strKey = strUuid + "_" + strMajorId
//            //beaconDataDic.updateValue(beacon, forKey: strUuid)
//            beaconDataDic.updateValue(beacon, forKey: strKey)
//
//            beaconDataUuidDic.updateValue(strUuid, forKey: strUuid)
////            let strMajorId = beacon.major.stringValue
////            beaconDataMajorDic.updateValue(strMajorId, forKey: strUuid)
////            let strMinorId = beacon.minor.stringValue
////            beaconDataMinorDic.updateValue(strMinorId, forKey: strUuid)
////            let strRssi = String(beacon.rssi)
////            beaconDataRssiDic.updateValue(strRssi, forKey: strUuid)
//
//            //beaconDataTextDic.updateValue(getIbeaconText(beacon: beacon), forKey: strUuid)
//            beaconDataTextDic.updateValue(getIbeaconText(beacon: beacon), forKey: strKey)
//
//            //csv出力
//            CsvOutput(data: getCSVText(beacon: beacon))
//            ///出力
//            let strUuidSub = String(strUuid.suffix(3))
//            print("testIbeacon, time:\(beacon.timestamp) , uuid:\(strUuidSub) , major:\(strMajorId) , proximity:\(beaconProximity) , rssi:\(beacon.rssi)")
//        }
//    }
//
//    //取得beaconDataの保存
//    var beaconDataDic : [String : CLBeacon]! = [:]
//    var beaconDataUuidDic : [String : String]! = [:]
//    var beaconDataMajorDic : [String : String]! = [:]
//    var beaconDataMinorDic : [String : String]! = [:]
//    var beaconDataRssiDic : [String : String]! = [:]
//    var beaconDataTextDic : [String : String]! = [:]
//
//    //
//    func getIbeaconText(beacon: CLBeacon) -> String{
//        var text = "no_data"
//        var textMajor = "major:" + beacon.major.stringValue
//        var textMinor = "minor:" + beacon.minor.stringValue
//        var textProximity = "proximity" + getIbeaconProximity(beacon: beacon)
//        var textAccuracy = "accuracy:" + String(beacon.accuracy)
//        var textRssi = "rssi:" + String(beacon.rssi)
//        ///var textTimestamp = "timestamp:" + String(beacon.timestamp)
//
//        text = textMajor + "," + textMinor + "," + textProximity + "," + textAccuracy + "," + textRssi
//        //test
//        text = textRssi
//        text = textMajor + "," + textMinor + "," + textRssi
//
//        return text
//    }
//
//    func getIbeaconProximity(beacon: CLBeacon) -> String{
//        var strProximity = "no_proximity"
//        if (beacon.proximity == CLProximity.immediate) {
//            strProximity = "immediate"
//        }
//        if (beacon.proximity == CLProximity.near) {
//            strProximity = "near"
//        }
//        if (beacon.proximity == CLProximity.far) {
//            strProximity = "far"
//        }
//        if (beacon.proximity == CLProximity.unknown) {
//            strProximity = "unknown"
//        }
//
//        return strProximity
//    }
//
//    /// CSV出力
//    func CsvOutput(data : String){
//        let fileUtil = FileUtil()
//        let CsvFileHeader = "timeStamp,UUID,major,minor,proximity,accuracy,rssi"
//        // CSVファイル名
//        let csvFileName : String = "iBeaconMonitor_" + DateUtil.GetDateFormatConvert(format: "yyyyMMdd") + ".csv"
//        let csvFileDir : String = CommonConst.ReceiveDir + "/" + CommonConst.iBeacon + "/"
//        let fullPass : String = csvFileDir + csvFileName
//
//        // ファイル書き込みデータ
//        var csvWriteData : String = ""
//        var writeData : String = ""
//        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
//
//        fileUtil.CreateDirectory(atPath: csvFileDir)
//
//        // ファイルが存在する場合
//        if fileUtil.FileExists(atPath: fullPass){
//            // ファイルからデータ読み込み
//            csvWriteData = fileUtil.ReadFromFile(fileName: fullPass)
//        }
//
//        writeData = dateString +  "," + data
//
//        if csvWriteData == "" {
//            csvWriteData = CsvFileHeader
//        }
//
//        csvWriteData.append("\n")
//        csvWriteData.append(writeData)
//
//        // ファイル書き込み
//        fileUtil.WritingToFile(text: csvWriteData,fileName: fullPass)
//
//        //一日ごとにファイル削除
//        let allFiles = fileUtil.ContentsOfDirectory(atPath: csvFileDir)
//        for file in allFiles{
//            if !(file.contains(csvFileName)) {
//                var delFile = csvFileDir + file
//                fileUtil.RemoveItem(atPath: delFile)
//            }
//        }
//    }
//
//    func getCSVText(beacon: CLBeacon) -> String{
//        var text = "no_data"
//        var textMajor = "major:" + beacon.major.stringValue
//        var textMinor = "minor:" + beacon.minor.stringValue
//        var textProximity = "proximity" + getIbeaconProximity(beacon: beacon)
//        var textAccuracy = "accuracy:" + String(beacon.accuracy)
//        var textRssi = "rssi:" + String(beacon.rssi)
//        let textUuid = "UUID:" + beacon.uuid.uuidString
//        text = textUuid + "," + textMajor + "," + textMinor + "," + textProximity + "," + textAccuracy + "," + textRssi
//
//        return text
//    }
}
