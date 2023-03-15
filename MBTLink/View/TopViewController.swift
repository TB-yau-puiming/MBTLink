//　
// TopViewController.swift
// トップ画面
//
// MBTLink

import UIKit
import CoreBluetooth
import CRPSmartBand

class TopViewController: UIViewController {
    
    // MARK: - UI部品
    // インフォメーション
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var personalIDTxt: UILabel!
    @IBOutlet weak var serialNumTxt: UILabel!
    
    // MARK: - Public変数
    /// ウォッチデバイスArray
    public var WatchDeviceArray = [String]()
    /// LANCEBAND管理辞書
    public var WatchManageDic = [String : WatchManageService]()
    /// CRPSmartBand管理辞書
    public var CRPSmartBandManageDic = [String : CRPSmartBandManageService]()
    /// 環境センサ管理
    public var EnvSensorManage : MeasuringInstrumentManageService!
    /// 体重計管理
    public var WeightScaleManage : MeasuringInstrumentManageService!
    /// 血圧計管理
    public var BpmManage : MeasuringInstrumentManageService!
    /// 体温計管理
    public var ThermometerManage : MeasuringInstrumentManageService!
    /// パルスオキシメーター管理
    public var PulseOximeterManage : MeasuringInstrumentManageService!
        
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( TopViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// ファイル操作クラス
    private let fileUtil = FileUtil()
    /// 接続状態TableView
    private var connectStatusTvc : ConnectStatusTableViewController!
    // 各デバイス毎サービス
    /// 環境センサ サービス
    private let envSensorService = EnvSensorService()
    /// 体重計 サービス
    private let weightScaleService = WeightScaleService()
    /// 血圧計 サービス
    private let bpmService = BloodPressuresMonitorService()
    /// 体温計 サービス
    private let thermometerService = ThermometerService()
    /// パルスオキシメーター サービス
    private let pulseOximeterService = PulseOximeterService()
    /// LANCEBAND サービス
    private let watchService = WatchService()
    /// CRPSmartbandサービス
    private let crpSmartbandService = CRPSmartBandService()
    /// ウォッチ 接続監視
    private var watchConnectMonitoringTimer : Timer!
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    /// 測定間隔カウントタイマー
    private var measuringIntervalCountTimer : Timer!
    /// 測定間隔カウンター
    private var measuringIntervalCounter : Int = 0
    /// CRPSmartBandデータ取得監視タイマー
    private var crpSmartBandGetDataMonitoringTimer : Timer!
    ///CRPSmartBandデータ取得監視タイマー測定間隔
    private var CRPSmartBandGetDataMonitoring : Double = 5
    ///CRPSmartBand歩数データ取得監視タイマー
    private var crpSmartBandGetStepsDataMonitoringTimer : Timer!
    ///CRPSmartBand歩数データ取得監視タイマー測定間隔
    private var crpSmartBandGetStepsDataMonitoring : Double = 5
    ///CRPSmartBand歩数以外の取得監視タイマー
    private var crpSmartBandGetDataTimers : Timer!
    ///CRPSmartBand24時間歩数データ取得監視タイマー
    private var crpSmartBandGet24StepDataMonitoringTimer : Timer!
    ///CRPSmartBand24時間心拍数データ取得監視タイマー
    private var crpSmartBandGet24HeartRateDataMonitoringTimer : Timer!
    ///CRPSmartBand睡眠履歴データ取得監視タイマー
    private var crpSmartBandGetTodaySleepDataMonitoringTimer : Timer!
    ///CRPSmartBand睡眠履歴データ取得監視タイマー
    private var crpSmartBandGetSleepDataMonitoringTimer : Timer!
    ///CRPSmartBand24時間心拍数データ取得監視タイマー測定間隔
    private var crpSmartBandGet24HeartRateDataMonitoring : Double = 5
    ///データ再送信監視タイマー
    private var dataResendMonitoringTimer : Timer!
    /// 位置情報送信タイマー
    static var locationSendTimer : Timer!
    /// 毎時処理実行タイマー
    private var processOnceAnHourTimer : Timer!

   // private var crpSmartBand : CRPSmartBandSDK!
    ///ファームウェアバージョン
    public var firmwareVersion : String = ""
    /// ファームウェアバージョンチェックフラグ
    private var firmwareFlag : Bool = false
    ///心拍
    private var heartRate : Int = 0
    private var heartRateManual : Int = 0
    ///血圧高
    private var sbp : Int = 0
    private var sbpManual : Int = 0
    ///血圧低
    private var dbp : Int = 0
    private var dbpManual : Int = 0
    ///SPO2
    private var o2 : Int = 0
    private var o2Manual : Int = 0

    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.informationLabel.isHidden = true
        //self.connectStatusTableView.isHidden = true
        
        // ナビゲーションバー
        // アイコン画像設定
        let imageView = UIImageView(image:UIImage(named: "icon"))
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        // back -> 戻るに変更
        let backbutton = UIBarButtonItem()
        backbutton.title = StringsConst.BACK
        navigationItem.backBarButtonItem = backbutton
        
        //接続状態TableView
        self.connectStatusTvc = (self.children[0] as! ConnectStatusTableViewController)
        
        // ファイル保存ディレクトリ作成
        self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir)
        
        ///測定機器監理サービス
        // 環境センサ管理
        self.EnvSensorManage = MeasuringInstrumentManageService(deviceName: EnvSensorConst.DeviceName)
        // 体重計管理
        self.WeightScaleManage = MeasuringInstrumentManageService(deviceName: WeightScaleConst.DeviceName)
        // 血圧計管理
        self.BpmManage = MeasuringInstrumentManageService(deviceName: BloodPressuresMonitorConst.DeviceName)
        // 体温計管理
        self.ThermometerManage = MeasuringInstrumentManageService(deviceName: ThermometerConst.DeviceName)
        // パルスオキシメーター管理
        self.PulseOximeterManage = MeasuringInstrumentManageService(deviceName: PulseOximeterConst.DeviceName)
        
        // 測定機器設定情報読み出し
        // 環境センサ
        self.EnvSensorManage.LoadMeasuringInstrumentSettingData()
        // 体重計
        self.WeightScaleManage.LoadMeasuringInstrumentSettingData()
        // 血圧計
        self.BpmManage.LoadMeasuringInstrumentSettingData()
        // 体温計
        self.ThermometerManage.LoadMeasuringInstrumentSettingData()
        // パルスオキシメーター管理
        self.PulseOximeterManage.LoadMeasuringInstrumentSettingData()
        
        /// 測定機器設定情報取得
        // 環境センサ
        let esDevice = self.EnvSensorManage.MeasuringInstrumentSettingInfo.DeviceNamePairing
        let envSensorDevice : String = ((esDevice != nil) ? esDevice! : "")
        // 体重計
        let wsDevice = self.WeightScaleManage.MeasuringInstrumentSettingInfo.DeviceNamePairing
        let weightScaleDevice : String = ((wsDevice != nil) ? wsDevice! : "")
        // 血圧計
        let bDevice = self.BpmManage.MeasuringInstrumentSettingInfo.DeviceNamePairing
        let bpmDevice : String = ((bDevice != nil) ? bDevice! : "")
        // 体温計
        let tmDevice = self.ThermometerManage.MeasuringInstrumentSettingInfo.DeviceNamePairing
        let thermometerDevice : String = ((tmDevice != nil) ? tmDevice! : "")
        // パルスオキシメーター
        let poDevice = self.PulseOximeterManage.MeasuringInstrumentSettingInfo.DeviceNamePairing
        let pulseOximeterDevice : String = ((poDevice != nil) ? poDevice! : "")
        
        /// BLEサービス初期化
        /// 環境センサ
        let envSensorPairing : Bool = self.EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings
        self.EnvSensorManage.BleService = BleService(
            deviceName          : EnvSensorConst.DeviceName
            ,writeData          : nil
            ,deviceNamePairing  : envSensorDevice
            ,pairingStatus      : envSensorPairing
            ,writeServiceReturnFlg: true)
        // 計測データ取得サービスの設定
        self.EnvSensorManage.BleService.SetInstrumentationService(serviceUUID       : CBUUID(string : EnvSensorConst.BleService.SensorService.Service.kUUID), characteristicUUID: [CBUUID(string: EnvSensorConst.BleService.SensorService.Characteristic.LatestData.kUUID)], properties        :BleService.Properties.Notify.rawValue)
        // スキャニング用サービスUUIDの設定
        self.EnvSensorManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : EnvSensorConst.BleService.DeviceInformationService.Service.kUUID))

        /// 体重計
        let weightScalePairing : Bool = self.WeightScaleManage.MeasuringInstrumentSettingInfo.IsSettings
        self.WeightScaleManage.BleService = BleService(
            deviceName          : WeightScaleConst.DeviceName
            ,writeData          : nil
            ,deviceNamePairing  : weightScaleDevice
            ,pairingStatus      : weightScalePairing
            ,writeServiceReturnFlg: true)
        // バッテリーサービスの設定
        self.WeightScaleManage.BleService.SetBatteryService(
            serviceUUID         : CBUUID(string : WeightScaleConst.BleService.BatteryService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
            , properties        :BleService.Properties.Read.rawValue)
        // 計測データ取得サービスの設定
        self.WeightScaleManage.BleService.SetInstrumentationService(
            serviceUUID         : CBUUID(string : WeightScaleConst.BleService.WeightScaleService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.WeightScaleService.Characteristic.Measurement.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue)
        // 書き込みサービス設定
        self.WeightScaleManage.BleService.SetWriteService(
            serviceUUID       : CBUUID(string : WeightScaleConst.BleService.WeightScaleService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.WeightScaleService.Characteristic.DateTime.kUUID)]
            , properties        :BleService.Properties.Write.rawValue)
        // スキャニング用サービスUUIDの設定
        self.WeightScaleManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : WeightScaleConst.BleService.WeightScaleService.Service.kUUID))
        
        /// 血圧計
        let bpmPairing : Bool = self.BpmManage.MeasuringInstrumentSettingInfo.IsSettings
        self.BpmManage.BleService = BleService(
            deviceName          : BloodPressuresMonitorConst.DeviceName
            ,writeData          : nil
            ,deviceNamePairing  : bpmDevice
            ,pairingStatus      : bpmPairing
            ,writeServiceReturnFlg: true)
        // バッテリーサービスの設定
        self.BpmManage.BleService.SetBatteryService(
            serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.BatteryService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
            , properties        :BleService.Properties.Read.rawValue
        )
        // 計測データ取得サービスの設定
        self.BpmManage.BleService.SetInstrumentationService(
            serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.BloodPressure.Service.kUUID)
            , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BloodPressure.Characteristic.Measurement.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // 書き込みサービス設定
        self.BpmManage.BleService.SetWriteService(
            serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.BloodPressure.Service.kUUID)
            , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BloodPressure.Characteristic.DateTime.kUUID)]
            , properties        :BleService.Properties.Write.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.BpmManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : BloodPressuresMonitorConst.BleService.BloodPressure.Service.kUUID))

        /// 体温計
        let thermometerPairing : Bool = self.ThermometerManage.MeasuringInstrumentSettingInfo.IsSettings
        self.ThermometerManage.BleService = BleService(
            deviceName          : ThermometerConst.DeviceName
            ,writeData          : nil
            ,deviceNamePairing  : thermometerDevice
            ,pairingStatus      : thermometerPairing
            ,writeServiceReturnFlg: true)
        // バッテリーサービスの設定
        self.ThermometerManage.BleService.SetBatteryService(
            serviceUUID       : CBUUID(string : ThermometerConst.BleService.BatteryService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
            , properties        :BleService.Properties.Read.rawValue
        )
        // 計測データ取得サービスの設定
        self.ThermometerManage.BleService.SetInstrumentationService(
            serviceUUID       : CBUUID(string : ThermometerConst.BleService.ThermometerService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.ThermometerService.Characteristic.TemperatureMeasurement.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // 書き込みサービス設定
        self.ThermometerManage.BleService.SetWriteService(
            serviceUUID       : CBUUID(string : ThermometerConst.BleService.ThermometerService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.ThermometerService.Characteristic.DateTime.kUUID)]
            , properties        :BleService.Properties.Write.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.ThermometerManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : ThermometerConst.BleService.ThermometerService.Service.kUUID))

        /// パルスオキシメーター
        let pulseOximeterPairing : Bool = self.PulseOximeterManage.MeasuringInstrumentSettingInfo.IsSettings
        self.PulseOximeterManage.BleService = BleService(
            deviceName          : PulseOximeterConst.DeviceName
            ,writeData          : nil
            ,deviceNamePairing  : pulseOximeterDevice
            ,pairingStatus      : pulseOximeterPairing
            ,writeServiceReturnFlg: true)
        // 計測データ取得サービスの設定
        self.PulseOximeterManage.BleService.SetInstrumentationService(
            serviceUUID       : CBUUID(string : PulseOximeterConst.BleService.PulseOximeter.Service.kUUID)
            , characteristicUUID: [CBUUID(string: PulseOximeterConst.BleService.PulseOximeter.Characteristic.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.PulseOximeterManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : PulseOximeterConst.BleService.PulseOximeter.Service.kUUID))

        // デリゲート設定
        // 環境センサ
        self.EnvSensorManage.BleService.delegate = self
        // 体重計
        self.WeightScaleManage.BleService.delegate = self
        // 血圧計
        self.BpmManage.BleService.delegate = self
        // 体温計
        self.ThermometerManage.BleService.delegate = self
        // パルスオキシメーター
        self.PulseOximeterManage.BleService.delegate = self
        
        // セントラルマネージャーのセットアップ
        // 環境センサ
        self.EnvSensorManage.BleService.SetupBluetoothService()
        // 体重計
        self.WeightScaleManage.BleService.SetupBluetoothService()
        // 血圧計
        self.BpmManage.BleService.SetupBluetoothService()
        // 体温計
        self.ThermometerManage.BleService.SetupBluetoothService()
        // パルスオキシメーター
        self.PulseOximeterManage.BleService.SetupBluetoothService()

        // ウォッチ ログ出力
        YCBTProduct.setDebugLogEnable(false)
        
        //ウォッチ登録デバイス情報読み出し
        let watchDevice = CommonUtil.LoadWatchDeviceData()
        if watchDevice != nil {
            
            self.WatchDeviceArray  = watchDevice!.WatchDeviceArray
            
            CommonUtil.Print(className: self.className, message: "登録デバイスArray:\(String(describing: self.WatchDeviceArray))")
            
            //ウォッチ設定情報読み出し
            if self.WatchDeviceArray.count > 0{
                for device in self.WatchDeviceArray{
                    
                    if device.contains(WatchConst.WatchDeviceName.Lanceband2)||device.contains(WatchConst.WatchDeviceName.Lanceband3){
                        // LANCEBAND
                        let manage = WatchManageService()
                        
                        // ウォッチ設定情報読み出し
                        manage.LoadWatchSettingData(deviceNameKey: device)
                        // デバイス名
                        manage.WatchBleService.SetDeviceName(value: manage.WatchSettingInfo.WatchDeviceName)
                        // MACアドレス
                        manage.WatchBleService.SetMacAddress(value: manage.WatchSettingInfo.WatchMacAddress)
                        
                        CommonUtil.Print(className: self.className, message: "登録デバイス:\(device)")
                        CommonUtil.Print(className: self.className, message: "ウォッチ設定情報:\(manage.WatchSettingInfo)")
                            
                        self.WatchManageDic.updateValue(manage, forKey: device)
                    }
                    else if device.contains(WatchConst.WatchDeviceName.CRPSmartBand){
                        // CRPSmartBand
                        let manage = CRPSmartBandManageService()
                        // ウォッチ設定情報読み出し
                        manage.LoadWatchSettingData(deviceNameKey: device)
                        // デバイス名
                        manage.WatchBleService.SetDeviceName(value: manage.WatchSettingInfo.WatchDeviceName)
                        // MACアドレス
                        manage.WatchBleService.SetMacAddress(value: manage.WatchSettingInfo.WatchMacAddress)
                        
                        // ウォッチ設定状態
                        manage.WatchBleService.IsWatchSetting(bool: manage.WatchSettingInfo.IsWatchSettings)
                        
                        CommonUtil.Print(className: self.className, message: "登録デバイス:\(device)")
                        CommonUtil.Print(className: self.className, message: "ウォッチ設定情報:\(manage.WatchSettingInfo)")
                            
                        self.CRPSmartBandManageDic.updateValue(manage, forKey: device)
                        //接続成功時に１回のみファームウェア確認を行う
                        firmwareFlag = true
                    }
                }
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        CommonUtil.Print(className: self.className, message: "viewWillAppear表示")
        
        CommonUtil.Print(className: self.className, message: "登録ウォッチデバイスArray:\(String(describing: self.WatchDeviceArray))")
        //個人認証IDとシリアル番号セット
//        setUITxt()
        
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) {
//            granted, error in
//            if let error = error {}
//            for i in 1...100 {
//                let contets = UNMutableNotificationContent()
//                contets.title = "test"
//                contets.body = "notification"
//                contets.sound = .none
//                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval(1 + (1 * i)), repeats: false)
//                let request = UNNotificationRequest.init(identifier: "test", content: contets, trigger: trigger)
//                UNUserNotificationCenter.current().add(request)
//            }
//        }
//        center.getDeliveredNotifications {(notifications: [UNNotification])  in
//            print(notifications)
//        }
//        center.getPendingNotificationRequests {(requests: [UNNotificationRequest]) in
//            print(requests)
//        }
//        center.getNotificationCategories{ categoru in
//            print(categoru)
//        }
//        center.removeAllDeliveredNotifications()

        // LANCEBAND
        for manage in self.WatchManageDic.values{
            // デリゲート設定
            manage.WatchBleService.delegate = self
            // デバイス切断
            manage.WatchBleService.ForceDisconnectDevice()
            
            if let peripheral = manage.WatchBleService.GetConnectPeripheral(){
                CommonUtil.Print(className: self.className, message: "デバイス:\(peripheral.name ?? "") 接続状態:\(peripheral.state.rawValue)")
            }
        }
        // CRPSmartBand
        for manage in self.CRPSmartBandManageDic.values{
            // デリゲート設定
            manage.WatchBleService.SetupBluetoothService()
            manage.WatchBleService.delegate = self
            // デバイス切断
            //manage.WatchBleService.Disconnect()
            // 血圧測定するかどうか
            CRPSmartBandBleService.BloodPressureMeasure = Bool(manage.WatchSettingInfo.BloodPressureMeasure)
            // SpO2測定するかどうか
            CRPSmartBandBleService.SpO2Measure = Bool(manage.WatchSettingInfo.SpO2Measure)
            //測定間隔
            self.CRPSmartBandGetDataMonitoring = Double(manage.WatchSettingInfo.MeasurementInterval)
            //歩数送信間隔
            self.crpSmartBandGetStepsDataMonitoring = Double(manage.WatchSettingInfo.StepSendInterval)
            if let discovery = manage.WatchBleService.GetConnectDiscovery(){
                CommonUtil.Print(className: self.className, message: "デバイス:\(discovery.localName ?? "")　MACアドレス:\(discovery.mac ?? "") 接続状態:\(discovery.remotePeripheral.state.rawValue)")
            }
        }
        
        // 登録デバイス情報
        // 環境センサ
//        CommonUtil.Print(className: self.className, message: "\(String(describing: self.EnvSensorManage.MeasuringInstrumentSettingInfo))")
        // 体重計
//        CommonUtil.Print(className: self.className, message: "\(String(describing: self.WeightScaleManage.MeasuringInstrumentSettingInfo))")
        // 血圧計
//        CommonUtil.Print(className: self.className, message: "\(String(describing: self.BpmManage.MeasuringInstrumentSettingInfo))")
        // 体温計
//        CommonUtil.Print(className: self.className, message: "\(String(describing: self.ThermometerManage.MeasuringInstrumentSettingInfo))")
        // パルスオキシメーター
//        CommonUtil.Print(className: self.className, message: "\(String(describing: self.PulseOximeterManage.MeasuringInstrumentSettingInfo))")
        
        // 毎時処理タイマーStart
        self.startProcessOnceAnHourTimer()

        // ウォッチ 接続監視タイマーStart
        self.startWatchConnectMonitoringTimer()

        // 位置情報受信タイマーStart
        self.dcService.StartLocationReceiveTimer()

        ///位置情報設定値
        let locationInfo = LocationInfoSettingTableViewController.loadLocationInfoSettingData()
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "callout loadLocationInfoSettingData")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
        if locationInfo?.IsLocationInfoSend ?? false {
            //位置情報送信タイマーStart
            self.dcService.startLocationSendTimer()
        }

        // CRPSmartBandデータ取得監視・タイマーStart
        if self.CRPSmartBandManageDic.count > 0{
            //タイマー開始時間を調整するために現在時刻を取得
            let time = DateUtil.GetDateFormatConvert(format: "mmss")
            let timeStr = String(describing:time)
            //let timeInt = Int(timeStr) ?? 0
            var delayTime : Int = 0
            //調整目標時刻(５分刻み)
            let standardTime = (Int(floor(Double((Int(timeStr.prefix(2)) ?? 0)/5))) + 1) * 5
            //目標時刻 - 現在時刻 = ずらす秒数
            delayTime = (standardTime * 60) - (Int(timeStr.prefix(2)) ?? 0)*60 - (Int(timeStr.suffix(2)) ?? 0)
            //５分刻み時刻+1分以内なら調整しない
            if delayTime > 299{
                delayTime = 0
            }
            //
            //print("timeStr: \(timeStr) delayTime:\(delayTime)")
            DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + Double(delayTime)) {
                self.startCRPSmartBandGetDataMonitoringTimer()
                self.startsendStepsTimer()
                self.startSendTimers()
                self.startResendTimers()
            }
        }
/*
        CommonUtil.Print(className: self.className, message: "===Top画面 viewWillAppear終了時点 BleServiceログ出力開始===")
        CommonUtil.Print(className: self.className, message: "[EnvSensorManage]")
        self.EnvSensorManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[WeightScaleManage]")
        self.WeightScaleManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[BpmManage]")
        self.BpmManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[ThermometerManage]")
        self.ThermometerManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[PulseOximeterManage]")
        self.PulseOximeterManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "===Top画面 viewWillAppear終了時点 BleServiceログ出力終了===")
*/
        //接続状態TableView リロード
        self.connectStatusTvc.TableViewReloadData()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
//        Thread.sleep(forTimeInterval: 7.0)
    }
    
    ///画面が表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
//    func setUITxt(){
//        let key = "key" + "_" + "userSettingData"
//        let userSettings = UserDefaults.standard.getUserSetting(key)
//        if (userSettings?.personalID == ""){
//            personalIDTxt.text = "未設定"
//        }else {
//            personalIDTxt.text = userSettings?.personalID ?? "未設定"
//        }
//        if (userSettings?.serialNumber == ""){
//            serialNumTxt.text = "未設定"
//        }else {
//            serialNumTxt.text = userSettings?.serialNumber ?? "未設定"
//        }
//    }
    
    /// 各ボタン押下時遷移先設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case CommonConst.Segue.LocationSettingManage :
            //位置情報設定画面
            guard let destination = segue.destination as? LocationInfoSettingTableViewController else {
                fatalError("Failed to prepare LocationInfoSettingTableViewController.")
            }
            destination.dcService = self.dcService
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "location settings")
            break
            
        case CommonConst.Segue.MeasuringInstrumentSetting :
            // 測定機器画面
            guard let destination = segue.destination as? MeasuringInstrumentSettingTableViewController else {
                fatalError("Failed to prepare MeasuringInstrumentSettingTableViewController.")
            }

            // 測定間隔カウントタイマーSTOP
            self.stopMeasuringIntervalTimer()
            
            // 遷移先に引き渡し
            // 環境センサ管理
            destination.EnvSensorManage = self.EnvSensorManage
            // 体重計管理
            destination.WeightScaleManage = self.WeightScaleManage
            // 血圧計管理
            destination.BpmManage = self.BpmManage
            // 体温計管理
            destination.ThermometerManage = self.ThermometerManage
            // パルスオキシメーター管理
            destination.PulseOximeterManage = self.PulseOximeterManage
            // データ通信サービス
            destination.DcService = self.dcService
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "measuring instrument setting")
            break
        case CommonConst.Segue.WatchSettingManage:
            // ウォッチ設定管理画面
            guard let destination = segue.destination as? WatchSettingManageViewController else {
                fatalError("Failed to prepare WatchSettingManageViewController.")
            }
            
            // ウォッチ 接続監視タイマーStop
            self.stopWatchConnectMonitoringTimer()
            
            // LANCEBAND
            if self.WatchManageDic.count > 0{
                for manage in self.WatchManageDic.values{
                    // スキャンデバイス タイマーStop
                    //manage.StopWatchScanDeviceTimer()
                    // 歩数履歴データ取得 タイマーStop
                    manage.StopWatchSyncHistoryStepTimer()
                    // 脈拍履歴データ取得 タイマーStop
                    manage.StopWatchSyncHistoryHeatTimer()
                    // 血圧履歴データ取得 タイマーStop
                    manage.StopWatchSyncHistoryBloodTimer()
                    
                    if manage.GetLancebandType() == WatchConst.LancebandType.Lanceband3{
                        // 総合履歴データ取得 タイマーStop
                        manage.StopWatchSyncHistoryCombinedTimer()
                    }
                }
            }
            // CRPSmartBand
            if self.CRPSmartBandManageDic.count > 0{
                // CRPSmartBandデータ取得監視・タイマーStop
                self.stopCRPSmartBandGetDataMonitoringTimer()
                // CRPSmartBand歩数データ取得監視・タイマーStop
                self.stopsendStepsTimer()

                for manage in self.CRPSmartBandManageDic.values{
                    // スキャンデバイス タイマーStop
                    manage.StopWatchScanDeviceTimer()
                    // 心拍数計測データ取得停止
                    manage.WatchBleService.SetStopSingleHR()
                    // 血圧計測データ取得停止
                    manage.WatchBleService.SetStopBlood()
                    // SPO2計測データ取得停止
                    manage.WatchBleService.SetStopSpO2()
                }
            }
            
            // LANCEBAND管理辞書
            destination.WatchManageDic = self.WatchManageDic
            // CRPSmartBand管理辞書
            destination.CRPSmartBandManageDic = self.CRPSmartBandManageDic
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "wearable device settings")
            break
//        case CommonConst.Segue.WebView :
//            // WebView
//            guard let destination = segue.destination as? WebViewController else {
//                fatalError("Failed to prepare WebViewController.")
//            }
//
//            // URL
//            destination.UrlString = CommonConst.MBTLinkPersonalUrl
//            // タイトル
//            destination.TitleName = "MBTLink Personal"
//            break
        case CommonConst.Segue.ServerSettingManage :
            //位置情報設定画面
            guard let destination = segue.destination as? UserSettingTableViewController else {
                fatalError("Failed to prepare UserSettingTableViewController.")
            }
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.ACTION , className: self.className , functionName: #function , message: "server settings")
            break
        default:
            // 位置情報受信タイマーStop
            self.dcService.StopLocationReceiveTimer()
            break
        }
        
    }
    // MARK: - Private Methods
    
    /// 毎時処理・タイマーStart
       private func startProcessOnceAnHourTimer(){
           //let message = "毎時処理タイマーStart"

           //CommonUtil.Print(className: self.className, message: message + "Start")
           //システムログ作成、送信
           LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to start timer")
           
           if self.processOnceAnHourTimer == nil{
               //タイマー設定
               //1時間に一回、日次処理を実行する
               self.processOnceAnHourTimer = Timer.scheduledTimer(timeInterval: CommonConst.TimeInterval.IOSDeviceBatteryMonitering, target: self, selector: #selector(self.executeOnceADate), userInfo: nil, repeats: true)
               
               //CommonUtil.Print(className: self.className, message: message + "設定完了")
               
               // タイマーStart
               self.processOnceAnHourTimer.fire()
               //システムログ作成、送信
               LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer started")
           }
       }
       /// 毎時処理・タイマーStop

       private func stopProcessOnceAnHourTimer(){
           //let message = "毎時処理タイマーStop"
           //CommonUtil.Print(className: self.className, message: message + "Stop")
           //システムログ作成、送信
           LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to stop timer")
           if self.processOnceAnHourTimer != nil && self.processOnceAnHourTimer.isValid {
               // タイマーを停止
               self.processOnceAnHourTimer.invalidate()
               self.processOnceAnHourTimer = nil
               
               //CommonUtil.Print(className: self.className, message: message +  "Stop完了")
               //システムログ作成、送信
               LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer stopped")
           }
       }
    
        /// 日次処理
       @objc func executeOnceADate() {
           //現在日の取得
           let dateFormatter = DateFormatter()
           dateFormatter.timeZone = TimeZone.current
           dateFormatter.locale = Locale.current
           dateFormatter.dateFormat = "HH:mm:ss"
           let nowTime:String = dateFormatter.string(from: Date())
           
           // iOS端末バッテリー取得
           self.batteryMonitoring(nowTime: nowTime)
           // 環境センサ再接続
           self.envSensorReconnect(nowTime: nowTime)
           //システムログ作成、送信
           LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
       }
    
    /// バッテリー情報モニタリング
    func batteryMonitoring(nowTime: String){
            
            UIDevice.current.isBatteryMonitoringEnabled = true
            
            // バッテリー残量を取得
            let batteryLevel:Float = UIDevice.current.batteryLevel
            let battery = NSString(format: "%.0f", batteryLevel * 100) as String + "%"
            let batteryStatus: UIDevice.BatteryState = UIDevice.current.batteryState
            
            var sendBatteryLevel: String = "";
            
            switch batteryStatus {
                 case .charging:
                     sendBatteryLevel = "ios:charging"
                 case .full:
                     sendBatteryLevel = "ios:\(battery)"
                 case .unplugged:
                     sendBatteryLevel = "ios:\(battery)"
                 default:
                     sendBatteryLevel = ""
             }
            
            // Webへのデータ送信
            self.dcService.postSendLogMsg(msg: sendBatteryLevel, deviceID: "", deviceAdr: "", deviceType: 0)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        }
    
/*
    func batteryMonitoring(nowTime: String){
        //モニタリング期間From
        let monitoringFrom = "00:00:00"
        //モニタリング期間To
        let monitoringTo = "00:59:59"
        
        if (monitoringFrom <= nowTime && nowTime <= monitoringTo) {
            
            UIDevice.current.isBatteryMonitoringEnabled = true
            
            // バッテリー残量を取得
            let batteryLevel:Float = UIDevice.current.batteryLevel
            let battery = NSString(format: "%.0f", batteryLevel * 100) as String + "%"
            let batteryStatus: UIDevice.BatteryState = UIDevice.current.batteryState
            
            var sendBatteryLevel: String = "";
            
            switch batteryStatus {
                 case .charging:
                     sendBatteryLevel = "ios:charging"
                 case .full:
                     sendBatteryLevel = "ios:\(battery)"
                 case .unplugged:
                     sendBatteryLevel = "ios:\(battery)"
                 default:
                     sendBatteryLevel = ""
             }
            
            // Webへのデータ送信
            self.dcService.postSendLogMsg(msg: sendBatteryLevel, deviceID: "", deviceAdr: "", deviceType: 0)
        }
    }
 */
 
    /// 環境センサ再接続
    func envSensorReconnect(nowTime: String){
        //モニタリング期間From
        let monitoringFrom = "00:00:00"
        //モニタリング期間To
        let monitoringTo = "00:59:59"
        
        if (monitoringFrom <= nowTime && nowTime <= monitoringTo) {
            /// 環境センサ設定済みであれば再接続処理
            if self.EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 環境センサー再接続
                self.EnvSensorManage.BleService.reConnectPeripheral()
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ウォッチ接続監視・タイマーStart
    private func startWatchConnectMonitoringTimer(){
        //let message = "ウォッチ接続監視タイマー"
        //CommonUtil.Print(className: self.className, message: message + "Start")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to start timer")
        if self.watchConnectMonitoringTimer == nil{
            //タイマー設定
            self.watchConnectMonitoringTimer = Timer.scheduledTimer(timeInterval: WatchConst.TimeInterval.WatchConnectMonitoring, target: self, selector: #selector(watchConnectMonitoring), userInfo: nil, repeats: true)
            
            //CommonUtil.Print(className: self.className, message: message + "設定完了")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer started")
            // タイマーStart
            self.watchConnectMonitoringTimer.fire()
        }
    }

    /// ウォッチ接続監視・タイマーStop
    private func stopWatchConnectMonitoringTimer(){
        let message = "ウォッチ接続監視タイマー"
        //CommonUtil.Print(className: self.className, message: message + "Stop")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to stop timer")
        if self.watchConnectMonitoringTimer != nil && self.watchConnectMonitoringTimer.isValid {
            // タイマーを停止
            self.watchConnectMonitoringTimer.invalidate()
            self.watchConnectMonitoringTimer = nil
            
            CommonUtil.Print(className: self.className, message: message +  "Stop完了")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer stopped")
        }
    }

    /// ウォッチ 接続監視
    @objc func watchConnectMonitoring() {
        //CommonUtil.Print(className: self.className, message: "ウォッチ接続監視　デバイス設定数：\(self.WatchDeviceArray.count)件")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "numbers of device set : \(self.WatchDeviceArray.count)")
        
        var state :CBPeripheralState = CBPeripheralState.disconnected
        
        if self.WatchDeviceArray.count > 0{
        
            // LANCEBAND
            for manage in self.WatchManageDic.values{
                
                if let peripheral = manage.WatchBleService.GetConnectPeripheral() {
                    
                    //CommonUtil.Print(className: self.className, message: "peripheralデバイス名：\(peripheral.name ?? "")")
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "peripheral device name:\(peripheral.name ?? "")")
                    state = peripheral.state
                }
                else{
                    state = CBPeripheralState.disconnected
                }
                
                if state == CBPeripheralState.connected{
                    //CommonUtil.Print(className: self.className, message: "接続中 デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "")")
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "connected device name:\(manage.WatchBleService.GetDeviceName() ?? "")")
                }
                else{
                    //CommonUtil.Print(className: self.className, message: "未接続　デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "")")
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected device name:\(manage.WatchBleService.GetDeviceName() ?? "")")
                    if manage.WatchSettingInfo.IsWatchSettings{
                        // ウォッチ設定中
                        // ウォッチ スキャンデバイスタイマーStart
                        manage.StartWatchScanDeviceTimer()
                    }
                }
            }
            
            // CRPSmartBand
            for manage in self.CRPSmartBandManageDic.values{
                
                if let discovery = manage.WatchBleService.GetConnectDiscovery() {
                    
                    //CommonUtil.Print(className: self.className, message: "discoveryデバイス名：\(discovery.localName ?? "") MACアドレス：\(discovery.mac ?? "")")
                    
                    state = discovery.remotePeripheral.state
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "discovery device name:\(discovery.localName ?? "") MAC address:\(discovery.mac ?? "")")
                }
                else{
                    state = CBPeripheralState.disconnected
                }
                
                if state == CBPeripheralState.connected{
                    //CommonUtil.Print(className: self.className, message: "接続中 デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "connceted device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                }
                else{
                    //CommonUtil.Print(className: self.className, message: "未接続　デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected　device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                }
            }
        }
        else{
            //CommonUtil.Print(className: self.className, message: "未接続　設定デバイスなし")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected no device set")
        }
        
        // 接続状態更新
        self.connectStatusTvc.TableViewReloadData()
    }
    
    /// 各種測定機器接続処理
    // 環境センサ接続処理
    func connectEnvSensor(manage: MeasuringInstrumentManageService){
        // bleスキャンを停止
        self.EnvSensorManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        //self.EnvSensorManage.BleService.DisconnectPeripheral()
        
        // 測定機器管理サービスに機器設定情報を設定
        self.EnvSensorManage = manage
        
        // サービスの設定
        self.EnvSensorManage.BleService.clearService()
        // 計測データ取得サービスの設定
        self.EnvSensorManage.BleService.SetInstrumentationService(
            serviceUUID         : CBUUID(string : EnvSensorConst.BleService.SensorService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: EnvSensorConst.BleService.SensorService.Characteristic.LatestData.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.EnvSensorManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : EnvSensorConst.BleService.DeviceInformationService.Service.kUUID))
        // 書き込みサービスreturnフラグの設定
        self.EnvSensorManage.BleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: true)
        
        // セントラルマネージャーの初期化
        self.EnvSensorManage.BleService.SetupBluetoothService()
        
        // デリゲート設定
        self.EnvSensorManage.BleService.delegate = self
        
        // bleスキャンの再開
        self.EnvSensorManage.BleService.StartBleScan()
        
        // bleサービスのログ出力
        outputManageLog(eventName: "接続処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // 体重計接続処理
    func connectWeightScale(manage: MeasuringInstrumentManageService){
        // bleスキャンを停止
        self.WeightScaleManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        //self.WeightScaleManage.BleService.DisconnectPeripheral()
        
        // 測定機器管理サービスに機器設定情報を設定
        self.WeightScaleManage = manage
        
        // サービスの設定
        self.WeightScaleManage.BleService.clearService()
        
        // バッテリーサービスの設定
        self.WeightScaleManage.BleService.SetBatteryService(
            serviceUUID         : CBUUID(string : WeightScaleConst.BleService.BatteryService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
            , properties        :BleService.Properties.Read.rawValue
        )
        // 計測データ取得サービスの設定
        self.WeightScaleManage.BleService.SetInstrumentationService(
            serviceUUID         : CBUUID(string : WeightScaleConst.BleService.WeightScaleService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.WeightScaleService.Characteristic.Measurement.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // 書き込みサービス設定
        self.WeightScaleManage.BleService.SetWriteService(
            serviceUUID       : CBUUID(string : WeightScaleConst.BleService.WeightScaleService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.WeightScaleService.Characteristic.DateTime.kUUID)]
            , properties        :BleService.Properties.Write.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.WeightScaleManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : WeightScaleConst.BleService.WeightScaleService.Service.kUUID))
        // 書き込みサービスreturnフラグの設定
        self.WeightScaleManage.BleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: true)
        
        // セントラルマネージャーの初期化
        self.WeightScaleManage.BleService.SetupBluetoothService()
        
        // デリゲート設定
        self.WeightScaleManage.BleService.delegate = self
        
        // bleスキャンの再開
        self.WeightScaleManage.BleService.StartBleScan()
        
        // bleサービスのログ出力
        outputManageLog(eventName: "接続処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    //血圧計接続処理
    func connectBloodPressuresMonitor(manage: MeasuringInstrumentManageService){
        // bleスキャンを停止
        self.BpmManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        //self.BpmManage.BleService.DisconnectPeripheral()
        
        // 測定機器管理サービスに機器設定情報を設定
        self.BpmManage = manage
        
        // サービスの設定
        self.BpmManage.BleService.clearService()
        // バッテリーサービスの設定
        self.BpmManage.BleService.SetBatteryService(
            serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.BatteryService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
            , properties        :BleService.Properties.Read.rawValue
        )
        // 計測データ取得サービスの設定
        self.BpmManage.BleService.SetInstrumentationService(
            serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.BloodPressure.Service.kUUID)
            , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BloodPressure.Characteristic.Measurement.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // 書き込みサービス設定
        self.BpmManage.BleService.SetWriteService(
            serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.BloodPressure.Service.kUUID)
            , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BloodPressure.Characteristic.DateTime.kUUID)]
            , properties        :BleService.Properties.Write.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.BpmManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : BloodPressuresMonitorConst.BleService.BloodPressure.Service.kUUID))
        // 書き込みサービスreturnフラグの設定
        self.BpmManage.BleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: true)
        
        // セントラルマネージャーの初期化
        self.BpmManage.BleService.SetupBluetoothService()
        
        // デリゲート設定
        self.BpmManage.BleService.delegate = self
        
        // bleスキャンの再開
        self.BpmManage.BleService.StartBleScan()
        
        // bleサービスのログ出力
        outputManageLog(eventName: "接続処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // 体温計接続処理
    func connectThermometer(manage: MeasuringInstrumentManageService){
        // bleスキャンを停止
        self.ThermometerManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        //self.ThermometerManage.BleService.DisconnectPeripheral()
        
        // 測定機器管理サービスに機器設定情報を設定
        self.ThermometerManage = manage
        
        // サービスの設定
        self.ThermometerManage.BleService.clearService()
        // バッテリーサービスの設定
        self.ThermometerManage.BleService.SetBatteryService(
            serviceUUID       : CBUUID(string : ThermometerConst.BleService.BatteryService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
            , properties        :BleService.Properties.Read.rawValue
        )
        // 計測データ取得サービスの設定
        self.ThermometerManage.BleService.SetInstrumentationService(
            serviceUUID       : CBUUID(string : ThermometerConst.BleService.ThermometerService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.ThermometerService.Characteristic.TemperatureMeasurement.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // 書き込みサービス設定
        self.ThermometerManage.BleService.SetWriteService(
            serviceUUID       : CBUUID(string : ThermometerConst.BleService.ThermometerService.Service.kUUID)
            , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.ThermometerService.Characteristic.DateTime.kUUID)]
            , properties        :BleService.Properties.Write.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.ThermometerManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : ThermometerConst.BleService.ThermometerService.Service.kUUID))
        // 書き込みサービスreturnフラグの設定
        self.ThermometerManage.BleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: true)
        
        // セントラルマネージャーの初期化
        self.ThermometerManage.BleService.SetupBluetoothService()
        
        // デリゲート設定
        self.ThermometerManage.BleService.delegate = self
        
        // bleスキャンの再開
        self.ThermometerManage.BleService.StartBleScan()
        
        // bleサービスのログ出力
        outputManageLog(eventName: "接続処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // パルスオキシメーター接続処理
    func connectPulseOximeter(manage: MeasuringInstrumentManageService){
        // bleスキャンを停止
        self.PulseOximeterManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        //self.PulseOximeterManage.BleService.DisconnectPeripheral()
        
        // 測定機器管理サービスに機器設定情報を設定
        self.PulseOximeterManage = manage
        
        // サービスの設定
        self.PulseOximeterManage.BleService.clearService()
        // 計測データ取得サービスの設定
        self.PulseOximeterManage.BleService.SetInstrumentationService(
            serviceUUID       : CBUUID(string : PulseOximeterConst.BleService.PulseOximeter.Service.kUUID)
            , characteristicUUID: [CBUUID(string: PulseOximeterConst.BleService.PulseOximeter.Characteristic.kUUID)]
            , properties        :BleService.Properties.Notify.rawValue
        )
        // スキャニング用サービスUUIDの設定
        self.PulseOximeterManage.BleService.SetScaningServiceUUID(uuid : CBUUID(string : PulseOximeterConst.BleService.PulseOximeter.Service.kUUID))
        // 書き込みサービスreturnフラグの設定
        self.PulseOximeterManage.BleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: true)
        
        // セントラルマネージャーの初期化
        self.PulseOximeterManage.BleService.SetupBluetoothService()
        
        // デリゲート設定
        self.PulseOximeterManage.BleService.delegate = self
        
        // bleスキャンの再開
        self.PulseOximeterManage.BleService.StartBleScan()
        
        // bleサービスのログ出力
        outputManageLog(eventName: "接続処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 各種測定機器切断処理
    // 環境センサ切断処理
    func disConnectEnvSensor(){
        // bleスキャンを停止
        self.EnvSensorManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        self.EnvSensorManage.BleService.DisconnectPeripheral()
        // bleサービスのログ出力
        outputManageLog(eventName: "切断処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // 体重計センサ切断処理
    func disConnectWeightScale(){
        // bleスキャンを停止
        self.WeightScaleManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        self.WeightScaleManage.BleService.DisconnectPeripheral()
        // bleサービスのログ出力
        outputManageLog(eventName: "切断処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // 血圧計切断処理
    func disConnectBloodPressuresMonitor(){
        // bleスキャンを停止
        self.BpmManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        self.BpmManage.BleService.DisconnectPeripheral()
        // bleサービスのログ出力
        outputManageLog(eventName: "切断処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // 体温計切断処理
    func disConnectThermometer(){
        // bleスキャンを停止
        self.ThermometerManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        self.ThermometerManage.BleService.DisconnectPeripheral()
        // bleサービスのログ出力
        outputManageLog(eventName: "切断処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // パルスオキシメーター切断処理
    func disConnectPulseOximeter(){
        // bleスキャンを停止
        self.PulseOximeterManage.BleService.StopBleScan()
        // ペリフェラル接続を切断
        self.PulseOximeterManage.BleService.DisconnectPeripheral()
        // bleサービスのログ出力
        outputManageLog(eventName: "切断処理")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // 全デバイスのログ出力
    func outputManageLog(eventName: String){
        
        CommonUtil.Print(className: self.className, message: "===Top画面 \(eventName) BleServiceログ出力開始===")
        CommonUtil.Print(className: self.className, message: "[EnvSensorManage]")
        self.EnvSensorManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[WeightScaleManage]")
        self.WeightScaleManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[BpmManage]")
        self.BpmManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[ThermometerManage]")
        self.ThermometerManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "[PulseOximeterManage]")
        self.PulseOximeterManage.BleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "===Top画面 \(eventName) BleServiceログ出力終了===")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}

// MARK: - BLEサービス関連
extension TopViewController : BleDelegate{
    
    /// BLE検出可能
    func blePowerOn(deviceName: String) {
        //CommonUtil.Print(className: self.className, message: "*****BLE検出可能：\(#function):\(#line)")
        
        switch deviceName {
        case EnvSensorConst.DeviceName:
            // 設定済み
            if self.EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 環境センサ・BLEスキャン開始
                self.EnvSensorManage.BleService.StartBleScan()
            }
            break
        case WeightScaleConst.DeviceName:
            // 設定済み
            if self.WeightScaleManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体重計・BLEスキャン開始
                self.WeightScaleManage.BleService.StartBleScan()
            }
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 設定済み
            if self.BpmManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 血圧計・BLEスキャン開始
                self.BpmManage.BleService.StartBleScan()
                self.BpmManage.BleService.loggingBleServiceContents()
            }
            break
        case ThermometerConst.DeviceName:
            // 設定済み
            if self.ThermometerManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体温計・BLEスキャン開始
                self.ThermometerManage.BleService.StartBleScan()
            }
            break
        case PulseOximeterConst.DeviceName:
            // 設定済み
            if self.PulseOximeterManage.MeasuringInstrumentSettingInfo.IsSettings{
                // パルスオキシメーター・BLEスキャン開始
                self.PulseOximeterManage.BleService.StartBleScan()
            }
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイススキャン成功
    func successToScanDevice(peripheral : CBPeripheral, deviceName : String){
        //CommonUtil.Print(className: self.className, message: "*****デバイススキャン成功：\(#function):\(#line)")

        switch deviceName {
        case EnvSensorConst.DeviceName:
            // 設定済み
            if self.EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 環境センサー・機器に接続
                self.EnvSensorManage.BleService.ConnectPeripheral()
            }
            break
        case WeightScaleConst.DeviceName:
            // 設定済み
            if self.WeightScaleManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体重計・機器に接続
                self.WeightScaleManage.BleService.ConnectPeripheral()
            }
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 設定済み
            if self.BpmManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 血圧計・機器に接続
                self.BpmManage.BleService.ConnectPeripheral()
            }
            break
        case ThermometerConst.DeviceName:
            // 設定済み
            if self.ThermometerManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体温計・機器に接続
                self.ThermometerManage.BleService.ConnectPeripheral()
            }
            break
        case PulseOximeterConst.DeviceName:
            // 設定済み
            if self.PulseOximeterManage.MeasuringInstrumentSettingInfo.IsSettings{
                // パルスオキシメーター・機器に接続
                self.PulseOximeterManage.BleService.ConnectPeripheral()
            }
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイス接続成功
    func successToDeviceConnect(peripheral : CBPeripheral, deviceName: String) {
        //CommonUtil.Print(className: self.className, message: "*****デバイス接続成功：\(#function):\(#line)")
        // 処理なし
        // 書き込みデータ（日時）作成
        let nowDateTime = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        let writeData = ConvertUtil.WriteDataForDateTime(str: nowDateTime)
        
        switch deviceName {
        case EnvSensorConst.DeviceName:
            if self.EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings{
                // ログ送信
                self.dcService.postSendLogMsg(msg: BleService.ConnectStatus.Connected.rawValue, deviceID: EnvSensorConst.DeviceId, deviceAdr: self.EnvSensorManage.MeasuringInstrumentSettingInfo.SerialNumber ?? "", deviceType: DataCommunicationService.DeviceType.EnvSensor.rawValue)
            }
            break
        case WeightScaleConst.DeviceName:
            // 設定済み
            if self.WeightScaleManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 書き込みデータ設定
                self.WeightScaleManage.BleService.SetWriteData(writeData: writeData)
            }
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 設定済み
            if self.BpmManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 書き込みデータ設定
                self.BpmManage.BleService.SetWriteData(writeData: writeData)
            }
            break
        case ThermometerConst.DeviceName:
            // 設定済み
            if self.ThermometerManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 書き込みデータ設定
                self.ThermometerManage.BleService.SetWriteData(writeData: writeData)
            }
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイス接続失敗
    func failToDeviceConnect(deviceName: String) {
        //CommonUtil.Print(className: self.className, message: "*****デバイス接続失敗：\(#function):\(#line)")
        
        switch deviceName {
        case EnvSensorConst.DeviceName:
            // 設定済み
            if self.EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 環境センサ・BLEスキャン開始
                self.EnvSensorManage.BleService.StartBleScan()
            }
            break
        case WeightScaleConst.DeviceName:
            // 設定済み
            if self.WeightScaleManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体重計・BLEスキャン開始
                self.WeightScaleManage.BleService.StartBleScan()
            }
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 設定済み
            if self.BpmManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 血圧計・BLEスキャン開始
                self.BpmManage.BleService.StartBleScan()
            }
            break
        case ThermometerConst.DeviceName:
            // 設定済み
            if self.ThermometerManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体温計・BLEスキャン開始
                self.ThermometerManage.BleService.StartBleScan()
            }
            break
        case PulseOximeterConst.DeviceName:
            // 設定済み
            if self.PulseOximeterManage.MeasuringInstrumentSettingInfo.IsSettings{
                // パルスオキシメーター・BLEスキャン開始
                self.PulseOximeterManage.BleService.StartBleScan()
            }
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// デバイス接続切断
    func deviceDisconnect(deviceName: String) {
        //CommonUtil.Print(className: self.className, message: "*****デバイス接続切断：\(#function):\(#line)")
        
        switch deviceName {
        case EnvSensorConst.DeviceName:
            // 設定済み
            if self.EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings{
                // ログ送信
                self.dcService.postSendLogMsg(msg: BleService.ConnectStatus.Disconnect.rawValue, deviceID: EnvSensorConst.DeviceId, deviceAdr: self.EnvSensorManage.MeasuringInstrumentSettingInfo.SerialNumber ?? "", deviceType: DataCommunicationService.DeviceType.EnvSensor.rawValue)
                
                // 環境センサ・BLE接続
                self.EnvSensorManage.BleService.ConnectPeripheral()
            }
            break
        case WeightScaleConst.DeviceName:
            // 設定済み
            if self.WeightScaleManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体重計・BLE接続
                self.WeightScaleManage.BleService.ConnectPeripheral()
            }
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 設定済み
            if self.BpmManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 血圧計・BLE接続
                self.BpmManage.BleService.ConnectPeripheral()
            }
            break
        case ThermometerConst.DeviceName:
            // 設定済み
            if self.ThermometerManage.MeasuringInstrumentSettingInfo.IsSettings{
                // 体温計・BLE接続
                self.ThermometerManage.BleService.ConnectPeripheral()
            }
            break
        case PulseOximeterConst.DeviceName:
            // 設定済み
            if self.PulseOximeterManage.MeasuringInstrumentSettingInfo.IsSettings{
                //スポットデータ送信
                var json : Data!
                var rssi : String
                ///配列の空チェック
                if !(self.pulseOximeterService.SaveDataArray.isEmpty) {
                    if let data = self.pulseOximeterService.SaveDataArray.last {
                        rssi = String(self.PulseOximeterManage.BleService.GetRssi()!)
                        json  = self.pulseOximeterService.CreateSendDataJson(data: data, deviceAddress: self.PulseOximeterManage.MeasuringInstrumentSettingInfo.Uuid!, batteryLevel: "", rssi: rssi,sendDataType: DataCommunicationService.SendDataTypePulseOximeter.Spot.rawValue)
                    }
                    // データ送信
                    self.dcService.PostSend(data: json)
                    ///配列の要素削除
                    self.pulseOximeterService.SaveDataArray.removeAll()
                }
                // パルスオキシメーター・BLE接続
                self.PulseOximeterManage.BleService.ConnectPeripheral()
            }
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// データ読み取り完了
    func complete(peripheral : CBPeripheral, deviceName: String, data: Data) {
        //CommonUtil.Print(className: self.className, message: "*****デバイス読み取り完了：\(#function):\(#line)")
                    
        var json : Data!
        var rssi : String
        
        switch deviceName {
        case EnvSensorConst.DeviceName:
            // 環境センサ
            // CSV出力
            self.envSensorService.CsvOutput(data: data)
            // データ送信用JSON作成
            rssi = String(self.EnvSensorManage.BleService.GetRssi()!)
            json  = self.envSensorService.CreateSendDataJson(data: data, deviceAddress: self.EnvSensorManage.MeasuringInstrumentSettingInfo.SerialNumber!, batteryLevel: self.envSensorService.GetBatteryLevel(data: data), rssi: rssi,sendDataType: DataCommunicationService.SendDataTypeOther.Measurement.rawValue)
            break
        case WeightScaleConst.DeviceName:
            // 体重計
            // CSV出力
            self.weightScaleService.CsvOutput(data: data)
            // データ送信用JSON作成
            rssi = String(self.WeightScaleManage.BleService.GetRssi()!)
            json  = self.weightScaleService.CreateSendDataJson(data: data, deviceAddress: self.WeightScaleManage.MeasuringInstrumentSettingInfo.SerialNumber!, batteryLevel: String(self.WeightScaleManage.BleService.GetBatteryLevel()), rssi: rssi,sendDataType: DataCommunicationService.SendDataTypeOther.Measurement.rawValue)
            
            // 測定結果がエラーの場合は送信を中断する
            if(self.weightScaleService.isErrorData(data: data)){
                return
            }
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 血圧計
            // CSV出力
            self.bpmService.CsvOutput(data: data)
            // データ送信用JSON作成
            rssi = String(self.BpmManage.BleService.GetRssi()!)
            json  = self.bpmService.CreateSendDataJson(data: data, deviceAddress: self.BpmManage.MeasuringInstrumentSettingInfo.SerialNumber!, batteryLevel: String(self.BpmManage.BleService.GetBatteryLevel()), rssi: rssi,sendDataType: DataCommunicationService.SendDataTypeOther.Measurement.rawValue)
            
            // 測定結果がエラーの場合は送信を中断する
            if(self.bpmService.isErrorData(data: data)){
                return
            }
            break
        case ThermometerConst.DeviceName:
            // 体温計
            // CSV出力
            self.thermometerService.CsvOutput(data: data)
            // データ送信用JSON作成
            rssi = String(self.ThermometerManage.BleService.GetRssi()!)
            json  = self.thermometerService.CreateSendDataJson(data: data, deviceAddress: self.ThermometerManage.MeasuringInstrumentSettingInfo.SerialNumber!, batteryLevel: String(self.ThermometerManage.BleService.GetBatteryLevel()), rssi: rssi,sendDataType: DataCommunicationService.SendDataTypeOther.Measurement.rawValue)
            
            // 測定結果がエラーの場合は送信を中断する
            if(self.thermometerService.isErrorData(data: data)){
                return
            }
            break
        case PulseOximeterConst.DeviceName:
            if data.count < 1 {
                return
            }
            // パルスオキシメーター
            
            //SPO2が100%より上の場合は測定エラーなのではじく
            let pulseOximeterSpo2 = ConvertUtil.HexadecimalJoin(uint1: data[2], uint2: data[3])
            if let IntSpo2 = Int(pulseOximeterSpo2) {
                print(IntSpo2)
                if IntSpo2 > 100 {
                    return
                }
            }else{
                ///SPO2を数値に変換できないエラーパターン
                return
            }
                
            // CSV出力
            self.pulseOximeterService.CsvOutput(data: data)
            
            if self.measuringIntervalCounter == 0{
                // 測定間隔カウントタイマーStart
                self.startMeasuringIntervalTimer()
            }
            
            // 測定間隔
            let measuringInterval = Int((self.PulseOximeterManage.MeasuringInstrumentSettingInfo.MeasuringInterval?.replacingOccurrences(of: StringsConst.MINUTES, with: ""))!)! * 60
            
            // 測定間隔が経過していない場合
            if self.measuringIntervalCounter < measuringInterval {
                print(self.measuringIntervalCounter)
                // データ保持（旧フォーマット暫定措置）
                if self.pulseOximeterService.SaveDataArray.count == 4{
                    self.pulseOximeterService.SaveDataArray.remove(at: 0)
                }
                else{
                    self.pulseOximeterService.SaveDataArray.append(data)
                }
                
                return
            }
            // データ送信用JSON作成
            rssi = String(self.PulseOximeterManage.BleService.GetRssi()!)
            json  = self.pulseOximeterService.CreateSendDataJson(data: data, deviceAddress: self.PulseOximeterManage.MeasuringInstrumentSettingInfo.Uuid!, batteryLevel: "", rssi: rssi,sendDataType: DataCommunicationService.SendDataTypePulseOximeter.Monitoring.rawValue)
            // 測定間隔カウンター初期化
            self.measuringIntervalCounter = 1
            break
        default:
            return
        }
        
        // データ送信
        self.dcService.PostSend(data: json)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}

// MARK: - YCBLEサービス関連
extension TopViewController : YCBleDelegate{
    /// lanceband ウォッチスキャン成功
    func successToScanWatch(deviceName: String?, peripherals: [CBPeripheral]) {
        //CommonUtil.Print(className: self.className, message: "successToScanWatch")
        
        for peripheral in peripherals{
            
            let name : String = String(peripheral.name!)
            
            if name == deviceName{
                // デバイス接続
                if let manage = self.WatchManageDic[name] {
                    manage.WatchBleService.SetConnectPeripheral(peripheral: peripheral)
                    manage.WatchBleService.ConnectPeripheral()
                }
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "successToScanWatch")
    }
    
    /// ウォッチ接続成功
    func successToWatchConnect(deviceName : String) {
        CommonUtil.Print(className: self.className, message: "successToWatchConnect　デバイス名:\(deviceName)")

        if let manage = self.WatchManageDic[deviceName] {
            // ウォッチ スキャンデバイス タイマーStop
            manage.StopWatchScanDeviceTimer()
            // ウォッチ 脈拍監視モード設定
            manage.WatchBleService.SettingHeartMode(heartMode: YCBleService.HeartMode.Auto.rawValue, time: manage.WatchSettingInfo.MeasurementInterval)
            // ウォッチ 歩数履歴データ取得・タイマーStart
            manage.StartWatchSyncHistoryStepTimer()
            // ウォッチ 脈拍履歴データ取得・タイマーStart
            manage.StartWatchSyncHistoryHeatTimer()
            // ウォッチ 血圧履歴データ取得・タイマーStart
            manage.StartWatchSyncHistoryBloodTimer()
            
            if manage.GetLancebandType() == WatchConst.LancebandType.Lanceband3{
                // ウォッチ 総合履歴データ取得・タイマーStart
                manage.StartWatchSyncHistoryCombinedTimer()
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "successToWatchConnect　device name:\(deviceName)")
    }
    
    /// 履歴データ取得完了
    func syncHistoryDataComplete(deviceName : String, historyType: Int, rows: [[String : Any]]) {
        
        var json : Data!
        
        if let manage = self.WatchManageDic[deviceName] {
            
            switch historyType {
            case YCBleService.SyncDataHistoryType.Step.rawValue:
                // 歩数
                // CSV出力
                self.watchService.HistoryDataStepCsvOutput(deviceName: deviceName,rows: rows)
                // データ送信用JSON作成
                json = watchService.CreateHistoryDataStepSendDataJson(rows: rows, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, batteryLevel: "", rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Step.rawValue)
                // データ送信
                self.dcService.PostSend(data: json)
                // 歩数履歴データ削除
                manage.WatchBleService.DeleteHistoryData(historyType: YCBleService.DeleteDataHistoryType.Step.rawValue)
                break
            case YCBleService.SyncDataHistoryType.Heart.rawValue:
                // 脈拍CSV出力
                self.watchService.HistoryDataHeartCsvOutput(deviceName: deviceName,rows: rows)
                
                for row in rows {
                    // データ送信用JSON作成
                    json = watchService.CreateHistoryDataHeartSendDataJson(row: row, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, batteryLevel: "", rssi: "",sendDataType: DataCommunicationService.SendDataTypeSmartWatch.HeartBpSpo2.rawValue)
                    // データ送信
                    self.dcService.PostSend(data: json)
                }
                
                // 脈拍履歴データ削除
                manage.WatchBleService.DeleteHistoryData(historyType: YCBleService.DeleteDataHistoryType.Heart.rawValue)
                break
            case YCBleService.SyncDataHistoryType.Blood.rawValue:
                // 血圧CSV出力
                self.watchService.HistoryDataBloodCsvOutput(deviceName: deviceName,rows: rows)
                // @@@後でデータ送信する際にコメントを外すこと
//                for row in rows {
//                    // データ送信用JSON作成
//                    json = watchService.CreateHistoryDataBloodSendDataJson(row: row, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, batteryLevel: "", rssi: "",sendDataType: DataCommunicationService.SendDataTypeSmartWatch.HeatBpSpo2.rawValue)
//                    // データ送信
//                    self.dcService.PostSend(data: json)
//                }
                // 血圧履歴データ削除
                manage.WatchBleService.DeleteHistoryData(historyType: YCBleService.DeleteDataHistoryType.Blood.rawValue)
                break
            case YCBleService.SyncDataHistoryType.Combined.rawValue:
                // SPO2・CSV出力
                self.watchService.HistoryDataSpo2CsvOutput(deviceName: deviceName,rows: rows)
                
                for row in rows {
                    // データ送信用JSON作成
                    json = watchService.CreateHistoryDataCombinedSendDataJson(row: row, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, batteryLevel: "", rssi: "",sendDataType: DataCommunicationService.SendDataTypeSmartWatch.HeartBpSpo2.rawValue)
                    // データ送信
                    self.dcService.PostSend(data: json)
                }
                
                // 総合履歴データ削除
                manage.WatchBleService.DeleteHistoryData(historyType: YCBleService.DeleteDataHistoryType.Combined.rawValue)
                break
            default:
                break
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// MACアドレス取得完了
    func getMacAddressComplete(deviceName : String, macAddress: String) {
        // 処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 脈拍監視モード設定完了
    func settingHeartModeComplete(deviceName: String, code: Error_Code) {
        // 処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// 測定間隔カウント・タイマーStart
    private func startMeasuringIntervalTimer(){
        //let message = "測定間隔カウントタイマー"
        //CommonUtil.Print(className: self.className, message: message + "Start")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to start timer")
        if self.measuringIntervalCountTimer == nil{
            //タイマー設定
            self.measuringIntervalCountTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(measuringIntervalCount), userInfo: nil, repeats: true)
            
            //CommonUtil.Print(className: self.className, message: message + "設定完了")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer started")
            // タイマーStart
            self.measuringIntervalCountTimer.fire()
        }
    }
    
    /// 測定間隔カウント・タイマーStop
    private func stopMeasuringIntervalTimer(){
        //let message = "測定間隔カウントタイマー"
        //CommonUtil.Print(className: self.className, message: message + "Stop")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to stop timer")
        if self.measuringIntervalCountTimer != nil && self.measuringIntervalCountTimer.isValid {
            // タイマーを停止
            self.measuringIntervalCountTimer.invalidate()
            self.measuringIntervalCountTimer = nil
            // 測定間隔カウンター初期化
            self.measuringIntervalCounter = 0
            
            //CommonUtil.Print(className: self.className, message: message +  "Stop完了")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer stoped")
        }
    }
    /// 測定間隔カウント
    @objc func measuringIntervalCount() {
        self.measuringIntervalCounter+=1
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}

// MARK: - CRPSmartBandBleサービス関連
extension TopViewController : CRPSmartBandBleDelegate{
    
    /// BLE検出可能
    func blePowerOn() {
        //CommonUtil.Print(className: self.className, message: "blePowerOn")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "blePowerOn")
    }
    /// ウォッチスキャン成功
    func successToScanWatch(deviceNameKey : String?, discoverys: [CRPDiscovery]) {
        //CommonUtil.Print(className: self.className, message: "successToScanWatch")
        
        for discovery in discoverys{
            
            if let name = discovery.localName,let macAddress = discovery.mac{
                
                if name.contains(WatchConst.WatchDeviceName.CRPSmartBand){
                    
                    let discoveryDeviceNameKey : String = "\(name) \(macAddress)"
                
                    if discoveryDeviceNameKey == deviceNameKey{
                        // デバイス接続
                        if let manage = self.CRPSmartBandManageDic[deviceNameKey!] {
                            manage.WatchBleService.SetConnectDiscovery(discovery: discovery)
                            manage.WatchBleService.ConnectDiscovery()
                        }
                    }
                }
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "successToScanWatch")
    }
    /// CRPSmartBandウォッチ接続成功
    func successToWatchConnect(discovery : CRPDiscovery){
        //CommonUtil.Print(className: self.className, message: "successToWatchConnect")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "successToWatchConnect")
        let name :String = discovery.localName!
        let macAddress : String = discovery.mac!
        let deviceNameKey : String = "\(name) \(macAddress)"
            
        if let manage = self.CRPSmartBandManageDic[deviceNameKey] {
            // ウォッチ スキャンデバイス タイマーStop
            manage.StopWatchScanDeviceTimer()
            
            ///ウォッチの時刻合わせ
            manage.WatchBleService.setRealTime()
            //ファームウェアバージョン取得
            if firmwareFlag == true{
                manage.WatchBleService.GetFirmware()
                firmwareFlag = false
            }
            // データ取得処理中
//            if manage.MeasurementResultDataStatus == .Prossesing{
                //CommonUtil.Print(className: self.className, message: "データ取得開始 デバイス：\(deviceNameKey)")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start to get data device:\(deviceNameKey)")
                //データ取得開始
                manage.WatchMeasurementResultData()
                // 未完リトライカウント初期化
                manage.IncompleteDisconnectRetryCount = 0
//            }
        }
    }
    
    /// 心拍数データ取得完了
    func getHeartRateDataComplete(deviceNameKey : String, heartRate: Int){
        if heartRate > 0 {
            //CommonUtil.Print(className: self.className, message: "心拍数データ取得完了 デバイス：\(deviceNameKey)")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "receive nonzero data device:\(deviceNameKey)")
 //           if let manage = self.CRPSmartBandManageDic[deviceNameKey]{
                if self.CRPSmartBandManageDic[deviceNameKey] != nil{
                ///旧フォーマット
                // データ送信用JSON作成
//                let json = self.crpSmartbandService.CreateHeartRateSendDataJson(heartRate: heartRate, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, batteryLevel: "", rssi: "",sendDataType: DataCommunicationService.SendDataTypeSmartWatch.HeartBpSpo2.rawValue)
//                // データ送信
//                self.dcService.PostSend(data: json)
                /*
                CRPSmartBandSDK.sharedInstance.getSleepData { (model, error) in
                    
                    // バッテリーレベル取得
                    let batteryLevel = manage.WatchBleService.GetBatteryLevel()
                    // ファームウェアバージョン取得
                    let firmwareVersion = manage.WatchBleService.GetFirmwareVersion()
                    //print("ver:" + firmwareVersion)
                    // データ送信用JSON作成
                    let json = self.crpSmartbandService.CreateSleepSendDataJson(sleepDetail: model.detail, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, firmwareVersion: firmwareVersion, batteryLevel: batteryLevel, rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Sleep.rawValue)
    //                // データ送信
                    self.dcService.PostSend(data: json)
                    
                    //睡眠データcsv出力
//                    self.crpSmartbandService.SleepDataCsvOutput(deviceNameKey: deviceNameKey, sleepDetail: model.detail)
                }
                */
                ///新フォーマット
                // 心拍を保持
                
//                let HrFlag = crpSmartBandBleService.HrFlag
                if CRPSmartBandBleService.HrFlag == true{
                self.heartRate = heartRate
                }else{
                    self.heartRateManual = heartRate
                }
                // 血圧測定結果データ取得
 //               manage.WatchBleService.SetStartBlood()
            }
            // CSV出力
            self.crpSmartbandService.HeartRateDataCsvOutput(deviceNameKey: deviceNameKey, heartRate: heartRate)

        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 血圧データ取得完了
    func getBloodDataComplete(deviceNameKey : String, heartRate: Int, sbp: Int, dbp: Int){
        if sbp != 255 && dbp != 255 {
            //CommonUtil.Print(className: self.className, message: "血圧データ取得完了 デバイス：\(deviceNameKey)")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "receive non255 data device:\(deviceNameKey)")
            if self.CRPSmartBandManageDic[deviceNameKey] != nil{
                // @@@後でデータ送信する際にコメントを外すこと
                // データ送信用JSON作成
//                let json = self.crpSmartbandService.CreateBloodSendDataJson(heartRate: heartRate, sbp: sbp, dbp: dbp, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, batteryLevel: "", rssi: "",sendDataType: DataCommunicationService.SendDataTypeSmartWatch.HeartBpSpo2.rawValue)
//                // データ送信
//                self.dcService.PostSend(data: json)
                
                ///新フォーマット
                if CRPSmartBandBleService.BpFlag == true{
                self.sbp = sbp
                self.dbp = dbp
                }else{
                self.sbpManual = sbp
                self.dbpManual = dbp
                }
                // SPO2測定結果データ取得
//                manage.WatchBleService.SetStartSpO2()
            }
            // CSV出力
            self.crpSmartbandService.BloodDataCsvOutput(deviceNameKey: deviceNameKey, heartRate: heartRate, sbp: sbp, dbp: dbp)

        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// SPO2データ取得完了
    func getSpo2DataComplete(deviceNameKey : String, o2: Int){
        if o2 > 0 && o2 < 255{
            //CommonUtil.Print(className: self.className, message: "SPO2データ取得完了 デバイス：\(deviceNameKey)")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "receive nonzero non255 data device:\(deviceNameKey)")
            if self.CRPSmartBandManageDic[deviceNameKey] != nil{
                ///旧フォーマット
                // データ送信用JSON作成
//                let json = self.crpSmartbandService.CreateSpo2SendDataJson(o2: o2, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, batteryLevel: "", rssi: "",sendDataType: DataCommunicationService.SendDataTypeSmartWatch.HeartBpSpo2.rawValue)
//                // データ送信
//                self.dcService.PostSend(data: json)
                
                ///新フォーマット
                //データ保存
                if CRPSmartBandBleService.SpO2Flag == true{
                    self.o2 = o2
                }else{
                    self.o2Manual = o2
                }
                

            }
            // CSV出力
            self.crpSmartbandService.Spo2DataCsvOutput(deviceNameKey: deviceNameKey, o2: o2)

        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
   func getDataCycleComplete(deviceNameKey : String){
       
//       let deviceNameKey : String = self.crpSmartBandBleService?.GetDeviceName()
       
      // let crpSmartBandManageService = CRPSmartBandManageService()
      // crpSmartBandManageService = self.CRPSmartBandManageDic.values.first
      // CommonUtil.Print(className: self.className, message: "デバイス：\(crpSmartBandManageService.GetDeviceNameKey() )")
      // let deviceNameKey = crpSmartBandManageService.GetDeviceNameKey()
      // print(crpSmartBandManageService.WatchBleService.GetDeviceName() ?? "")
//       print(deviceNameKey)
       //CommonUtil.Print(className: self.className, message: "データ送信 デバイス：\(deviceNameKey)")
       if let manage = self.CRPSmartBandManageDic[deviceNameKey]{
       // バッテリーレベル取得
        let batteryLevel = manage.WatchBleService.GetBatteryLevel()
        // ファームウェアバージョン取得
        let firmwareVersion = manage.WatchBleService.GetFirmwareVersion()
        print("ver:" + firmwareVersion)
        //データ送信用json作成
           let json = self.crpSmartbandService.createCRPSendDateJson(heartRate: heartRate, sbp: sbp, dbp: dbp, o2: o2, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, firmwareVersion: firmwareVersion , batteryLevel: batteryLevel, rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.HeartBpSpo2.rawValue)
        
        self.dcService.PostSend(data: json)
        
  //      CommonUtil.Print(className: self.className, message: "測定結果データ取得完了 デバイス：\(deviceNameKey)")
        // 測定結果データ取得完了
        manage.MeasurementResultDataStatus = CRPSmartBandManageService.Status.Complete
        // 処理中カウント初期化
        //manage.ProssesingConnectCount = 0
        // 処理中リトライカウント初期化
        //manage.ProssesingConnectRetryCount = 0
        // 測定データ初期化
            heartRate = 0
            sbp = 0
            dbp = 0
            o2 = 0
        }
       //システムログ作成、送信
       LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "device:\(deviceNameKey)")
    }
    
    func resendData(){
        let DataDir = "Receive/Resend/Data"
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = fileUtil.ContentsOfDirectory(atPath: DataDir)
        allFiles.sort{$0 < $1}
            
        for file in allFiles{
            if file.contains("resendJson_"){
                let fileName = DataDir + "/" + file
                // ファイルからデータ読み込み
                let resendData = self.fileUtil.ReadFromFile(fileName: fileName)
                print(resendData)
                let jsonValue = resendData.data(using: .utf8)!
                self.dcService.postResendData(data : jsonValue)
                self.fileUtil.RemoveItem(atPath: fileName)
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    func resendLog(){
        let logDir = "Receive/Resend/Log"
        // ログフォルダ内のファイル名一覧を取得する
        var allFiles = self.fileUtil.ContentsOfDirectory(atPath: logDir)
        allFiles.sort{$0 < $1}
            
        for file in allFiles{
            if file.contains("resendJson_"){
                let fileName = logDir + "/" + file
                // ファイルからデータ読み込み
                let resendData = self.fileUtil.ReadFromFile(fileName: fileName)
                print(resendData)
                let jsonValue = resendData.data(using: .utf8)!
                self.dcService.postResendLogMsg(data : jsonValue)
                self.fileUtil.RemoveItem(atPath: fileName)
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// CRPSmartBand歩数データ取得監視・タイマーStart
    private func startsendStepsTimer(){
        //let message = "H76歩数タイマー"
        //CommonUtil.Print(className: self.className, message: message + "Start")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to start timer")
        if self.crpSmartBandGetStepsDataMonitoringTimer == nil{
            ///歩数測定間隔が0分になっている場合には初期値の3分をセット
            if self.crpSmartBandGetStepsDataMonitoring == 0 {
                self.crpSmartBandGetStepsDataMonitoring = 5
            }
            //タイマー設定
            self.crpSmartBandGetStepsDataMonitoringTimer = Timer.scheduledTimer(timeInterval: self.crpSmartBandGetStepsDataMonitoring * 60, target: self, selector: #selector(sendStepsTimer), userInfo: nil, repeats: true)
            
            //CommonUtil.Print(className: self.className, message: message + "設定完了")
            
            // タイマーStart
            self.crpSmartBandGetStepsDataMonitoringTimer.fire()
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer started")
        }
    }
    /*
    /// CRPSmartBand24時間心拍数データ取得監視・タイマーStart
    private func startsend24HeartRateTimer(){
        let message = "24時間心拍数タイマー"
        CommonUtil.Print(className: self.className, message: message + "Start")
        
        if self.crpSmartBandGet24HeartRateDataMonitoringTimer == nil{
            ///取得間隔が0分になっている場合には初期値の5分をセット
            if self.crpSmartBandGet24HeartRateDataMonitoring == 0 {
                self.crpSmartBandGet24HeartRateDataMonitoring = 5
            }
            //タイマー設定
            //self.crpSmartBandGet24HeartRateDataMonitoringTimer = Timer.scheduledTimer(timeInterval: self.crpSmartBandGet24HeartRateDataMonitoring * 60, target: self, selector: #selector(send24HeartRateTimer), userInfo: nil, repeats: true)
            self.crpSmartBandGet24HeartRateDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(send24HeartRateTimer), userInfo: nil, repeats: false)
            
            CommonUtil.Print(className: self.className, message: message + "設定完了")
            
            // タイマーStart
            self.crpSmartBandGet24HeartRateDataMonitoringTimer.fire()
        }
    }
    */
    
    /// CRPSmartBand歩数データ取得監視・タイマーStop
    private func stopsendStepsTimer(){
        let message = "H76歩数タイマー"
        //CommonUtil.Print(className: self.className, message: message + "Stop")
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to stop timer")
        if self.crpSmartBandGetStepsDataMonitoringTimer != nil && self.crpSmartBandGetStepsDataMonitoringTimer.isValid{
            // タイマーを停止
            self.crpSmartBandGetStepsDataMonitoringTimer.invalidate()
            self.crpSmartBandGetStepsDataMonitoringTimer = nil
            
            //CommonUtil.Print(className: self.className, message: message +  "Stop完了")
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer stopped")
        }
    }
    
    ///CRPsmartBand歩数データ送信タイマー
    @objc func sendStepsTimer(){
        var state : CBPeripheralState = .disconnected
        
        for manage in self.CRPSmartBandManageDic.values{
            //ウォッチ接続状態の確認
            if let discovery = manage.WatchBleService.GetConnectDiscovery() {
                //CommonUtil.Print(className: self.className, message: "discoveryデバイス名：\(discovery.localName ?? "") MACアドレス：\(discovery.mac ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "discovery device name:\(discovery.localName ?? "") MAC address:\(discovery.mac ?? "")")
                
                state = discovery.remotePeripheral.state
            }
            else{
                state = CBPeripheralState.disconnected
            }
            
            //ウォッチ接続状態によって歩数データを送るか判定
            if state == CBPeripheralState.connected{
                CommonUtil.Print(className: self.className, message: "接続中 デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチの歩数データ取得の開始
                //保持していた全ての歩数データ
                let StepModelArray = CRPSmartBandService.SaveStepModelArray
                //データ送信用変数
                var StepsData : CommonCodable.H76StepModel?
                print(StepModelArray)
                if StepModelArray.isEmpty {
                    StepsData = CommonCodable.H76StepModel()
                    CRPSmartBandSDK.sharedInstance.getSteps ({(model, error) in
                        StepsData?.step = model.steps
                        StepsData?.calories = model.calory
                        StepsData?.distance = model.distance
                        StepsData?.getTime = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
                    })
                    
                }else {
                    StepsData = StepModelArray.last ?? CommonCodable.H76StepModel()
                }
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 3) {
                manage.WatchBleService.GetStep()
                }
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 6) {
                // バッテリーレベル取得
                let batteryLevel = manage.WatchBleService.GetBatteryLevel()
                // ファームウェアバージョン取得
                let firmwareVersion = manage.WatchBleService.GetFirmwareVersion()
                //print("ver:" + firmwareVersion)
                //24時間歩数取得
                let Step24Data = manage.WatchBleService.Get24Step()
                // データ送信用JSON作成
                let json = self.crpSmartbandService.CreateStepsSendDataJson(stepsData: StepsData!,historyStepData : Step24Data , deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, firmwareVersion: firmwareVersion, batteryLevel: batteryLevel, rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Step.rawValue)
                // データ送信
                self.dcService.PostSend(data: json)
                
                //歩数csv出力
                let deviceName = (manage.WatchBleService.GetDeviceName() ?? "") + (manage.WatchBleService.GetMacAddress() ?? "")
                self.crpSmartbandService.StepDataCsvOutput(deviceNameKey: deviceName, stepData: StepsData!)
                
                //test
                // CSVファイル名
                let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
                let csvFileNameStr = "stepLog_"
                let csvFileName = csvFileNameStr + "\(nowDate).txt"
                // ディレクトリの作成
                    self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
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
                
                writeData = dateString

                csvWriteData.append("\n")
                csvWriteData.append(writeData)
                    
                // ファイル書き込み
                self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
                let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
                let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
                
                let logDir = "Receive/Log"
                    
                // ログフォルダ内のファイル名一覧を取得する
                    var allFiles = self.fileUtil.ContentsOfDirectory(atPath: logDir)
                allFiles.sort{$0 < $1}
                    
                let startIndexPoint = csvFileNameStr.utf8.count
                let endIndexPoint = -5
                    
                    for file in allFiles{

                    // ２日前以前のログファイルを削除する
                        if file.contains("stepLog") {
                        let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                        let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                        let YYYYMMdd_HH = file[startIndex...endIndex]
                        //print(YYYYMMdd_HH)
                        //print(beforeDtStr)
                        
                        if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                            || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                            let delFile = "\(logDir)/\(file)"
                            self.fileUtil.RemoveItem(atPath: delFile)
                            }
                        }
                    }
                }
            }
            else{
                //CommonUtil.Print(className: self.className, message: "未接続　デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチ未接続のため、データ送信はなし
            }
        }
        //self.crpSmartBandGet24StepDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(send24StepsTimer), userInfo: nil, repeats: false)
        //self.crpSmartBandGet24HeartRateDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(send24HeartRateTimer), userInfo: nil, repeats: false)
        //self.crpSmartBandGetSleepDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(sendSleepHistoryTimer), userInfo: nil, repeats: false)
        
    }
    
    func startResendTimers(){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to start timer")
        if self.dataResendMonitoringTimer == nil{
            
            //タイマー設定
            self.dataResendMonitoringTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(resendTimers), userInfo: nil, repeats: true)
            
            //CommonUtil.Print(className: self.className, message: message + "設定完了")
            
            // タイマーStart
            self.dataResendMonitoringTimer.fire()
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer started")
        }
    }
    
    @objc func resendTimers(){
        resendData()
        DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 10) {
            self.resendLog()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start data,log resend timer")
    }
    
    //歩数以外のデータ取得タイマー管理
    
    @objc func startSendTimers(){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to start timer")
        if self.crpSmartBandGetDataTimers == nil{
            
            //タイマー設定
            self.crpSmartBandGetDataTimers = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(sendTimers), userInfo: nil, repeats: true)
            
            //CommonUtil.Print(className: self.className, message: message + "設定完了")
            
            // タイマーStart
            self.crpSmartBandGetDataTimers.fire()
            
        //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "24step, 24heartrate,sleephistory,sleep timer started")
        }
    }
    
    @objc func sendTimers(){
        self.crpSmartBandGet24HeartRateDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(send24HeartRateTimer), userInfo: nil, repeats: false)
        self.crpSmartBandGet24StepDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(send24StepsTimer), userInfo: nil, repeats: false)
        self.crpSmartBandGetSleepDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(sendSleepHistoryTimer), userInfo: nil, repeats: false)
        self.crpSmartBandGetTodaySleepDataMonitoringTimer = Timer.scheduledTimer(timeInterval: 80, target: self, selector: #selector(sendSleepTimer), userInfo: nil, repeats: false)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start 24step, 24heartrate,sleephistory,sleep timer")
    }
    
    ///CRPsmartBand24時間歩数データ送信タイマー
    @objc func send24StepsTimer(){
        
        
        var state : CBPeripheralState = .disconnected
        
        for manage in self.CRPSmartBandManageDic.values{
            //ウォッチ接続状態の確認
            if let discovery = manage.WatchBleService.GetConnectDiscovery() {
                //CommonUtil.Print(className: self.className, message: "discoveryデバイス名：\(discovery.localName ?? "") MACアドレス：\(discovery.mac ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "discovery device name:\(discovery.localName ?? "") MAC address:\(discovery.mac ?? "")")
                state = discovery.remotePeripheral.state
            }
            else{
                state = CBPeripheralState.disconnected
            }
            
            //ウォッチ接続状態によって歩数データを送るか判定
            if state == CBPeripheralState.connected{
                //CommonUtil.Print(className: self.className, message: "接続中 デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチの24時間歩数データ取得の開始
//                manage.WatchBleService.GetStep()
//                let Step24Data = manage.WatchBleService.Get24Step()
                manage.WatchBleService.GetStep()
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 3) {
                manage.WatchBleService.GetYesterdayStep()
                }
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 6) {
                    let Step24Data = manage.WatchBleService.Get24Step()
                    let YesterdayStep24Data = manage.WatchBleService.GetYesterday24Step()
                    //print(Step24Data)
                    // バッテリーレベル取得
                    let batteryLevel = manage.WatchBleService.GetBatteryLevel()
                    // ファームウェアバージョン取得
                    let firmwareVersion = manage.WatchBleService.GetFirmwareVersion()
                    //print("ver:" + firmwareVersion)
                    
                    // データ送信用JSON作成
                    let json = self.crpSmartbandService.Create24StepSendDataJson(YesterDayStep24Data: YesterdayStep24Data,Step24Data: Step24Data, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, firmwareVersion: firmwareVersion, batteryLevel: batteryLevel, rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Step24.rawValue)
                    // データ送信
                    self.dcService.PostSend(data: json)
                    
                     
                    //24時間歩数csv出力
                    let deviceName = (manage.WatchBleService.GetDeviceName() ?? "") + (manage.WatchBleService.GetMacAddress() ?? "")
                    self.crpSmartbandService.Step24DataCsvOutput(deviceNameKey: deviceName, step24Data: Step24Data)
                    
                    //test
                    // CSVファイル名
                    let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
                    let csvFileNameStr = "24StepLog_"
                    let csvFileName = csvFileNameStr + "\(nowDate).txt"
                    // ディレクトリの作成
                        self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
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
                    
                    writeData = dateString

                    csvWriteData.append("\n")
                    csvWriteData.append(writeData)
                        
                    // ファイル書き込み
                    self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
                    let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
                    let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
                    
                    let logDir = "Receive/Log"
                        
                    // ログフォルダ内のファイル名一覧を取得する
                        var allFiles = self.fileUtil.ContentsOfDirectory(atPath: logDir)
                    allFiles.sort{$0 < $1}
                        
                    let startIndexPoint = csvFileNameStr.utf8.count
                    let endIndexPoint = -5
                        
                    for file in allFiles{

                        // ２日前以前のログファイルを削除する
                        if file.contains("24HeartRateLog") {
                            let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                            let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                            let YYYYMMdd_HH = file[startIndex...endIndex]
                            //print(YYYYMMdd_HH)
                            //print(beforeDtStr)
                            
                            if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                                || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                                let delFile = "\(logDir)/\(file)"
                                self.fileUtil.RemoveItem(atPath: delFile)
                            }
                        }
                    }
                }
            }
            else{
                //CommonUtil.Print(className: self.className, message: "未接続　デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチ未接続のため、データ送信はなし
            }
        }
    }
    ///CRPsmartBand24時間心拍数データ送信タイマー
    @objc func send24HeartRateTimer(){
        var state : CBPeripheralState = .disconnected
        
        for manage in self.CRPSmartBandManageDic.values{
            //ウォッチ接続状態の確認
            if let discovery = manage.WatchBleService.GetConnectDiscovery() {
                //CommonUtil.Print(className: self.className, message: "discoveryデバイス名：\(discovery.localName ?? "") MACアドレス：\(discovery.mac ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "discovery device name:\(discovery.localName ?? "") MAC address:\(discovery.mac ?? "")")
                state = discovery.remotePeripheral.state
            }
            else{
                state = CBPeripheralState.disconnected
            }
            
            //ウォッチ接続状態によって24時間心拍数データを送るか判定
            if state == CBPeripheralState.connected{
                //CommonUtil.Print(className: self.className, message: "接続中 デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチの24時間心拍数データ取得の開始
                manage.WatchBleService.GetHeartRate()
                //24時間心拍数データ取得日時を保存
                let time = (DateUtil.GetDateFormatConvert(format: "mm"))
                let timeInt = Int(time) ?? 0
                var fixedTime = String(Int(floor(Double(timeInt/5))*5))
                if fixedTime == "0"{
                    fixedTime = "00"
                }
                if fixedTime == "5"{
                    fixedTime = "05"
                }
                let date = (DateUtil.GetDateFormatConvert(format: "yyyyMMddHH"))
                let getdate = date + fixedTime + "00"
                let timeInHHmm = DateUtil.getFormattedDateStringHHmm(dateString: getdate)
                
                //print(getdate)
                //let getdate = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
                
                CRPSmartBandService.heartRateGetDate = String(describing:getdate)
                ///ウォッチの昨日の24時間心拍数データ取得の開始
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 3) {
                manage.WatchBleService.GetYesterdayHeartRate()
                }
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 6) {
                    var HeartRate24Data : [Int] = []
                    if Int(timeInHHmm) ?? 0 < 5{
                        HeartRate24Data = Array(repeating: 0, count: 288)
                    }else{
                        HeartRate24Data = manage.WatchBleService.Get24HeartRate()
                    }
                    let YesterdayHeartRate24Data = manage.WatchBleService.GetYesterday24HeartRate()
                    //print(HeartRate24Data)
                    // バッテリーレベル取得
                    let batteryLevel = manage.WatchBleService.GetBatteryLevel()
                    // ファームウェアバージョン取得
                    let firmwareVersion = manage.WatchBleService.GetFirmwareVersion()
                    //print("ver:" + firmwareVersion)
                    
                    // データ送信用JSON作成
                    let json = self.crpSmartbandService.Create24HeartRateSendDataJson(YesterdayHeartRate24Data : YesterdayHeartRate24Data, HeartRate24Data: HeartRate24Data, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, firmwareVersion: firmwareVersion, batteryLevel: batteryLevel, rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Heart24.rawValue)
                    // データ送信
                    self.dcService.PostSend(data: json)
                    
                     
                    //24時間心拍数csv出力
                    let deviceName = (manage.WatchBleService.GetDeviceName() ?? "") + (manage.WatchBleService.GetMacAddress() ?? "")
                    self.crpSmartbandService.HeartRate24DataCsvOutput(deviceNameKey: deviceName, heartRate24Data: HeartRate24Data)
                    
                    //test
                    // CSVファイル名
                    let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
                    let csvFileNameStr = "24HeartRateLog_"
                    let csvFileName = csvFileNameStr + "\(nowDate).txt"
                    // ディレクトリの作成
                        self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
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
                    
                    writeData = dateString

                    csvWriteData.append("\n")
                    csvWriteData.append(writeData)
                        
                    // ファイル書き込み
                    self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
                    let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
                    let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
                    
                    let logDir = "Receive/Log"
                        
                    // ログフォルダ内のファイル名一覧を取得する
                        var allFiles = self.fileUtil.ContentsOfDirectory(atPath: logDir)
                    allFiles.sort{$0 < $1}
                        
                    let startIndexPoint = csvFileNameStr.utf8.count
                    let endIndexPoint = -5
                        
                    for file in allFiles{

                        // ２日前以前のログファイルを削除する
                        if file.contains("24HeartRateLog") {
                            let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                            let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                            let YYYYMMdd_HH = file[startIndex...endIndex]
                                //print(YYYYMMdd_HH)
                            //print(beforeDtStr)
                            
                            if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                                || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                                let delFile = "\(logDir)/\(file)"
                                self.fileUtil.RemoveItem(atPath: delFile)
                            }
                        }
                    }
                }
            }
            else{
                //CommonUtil.Print(className: self.className, message: "未接続　デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチ未接続のため、データ送信はなし
            }
        }
    }
    
    /// CRPsmartBand睡眠履歴データ送信タイマー
    @objc func sendSleepTimer(){
        var state : CBPeripheralState = .disconnected
        
        for manage in self.CRPSmartBandManageDic.values{
            //ウォッチ接続状態の確認
            if let discovery = manage.WatchBleService.GetConnectDiscovery() {
                //CommonUtil.Print(className: self.className, message: "discoveryデバイス名：\(discovery.localName ?? "") MACアドレス：\(discovery.mac ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "discovery device name:\(discovery.localName ?? "") MAC address:\(discovery.mac ?? "")")
                state = discovery.remotePeripheral.state
            }
            else{
                state = CBPeripheralState.disconnected
            }
            
            //ウォッチ接続状態によって睡眠データを送るか判定
            if state == CBPeripheralState.connected{
                //CommonUtil.Print(className: self.className, message: "接続中 デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチの睡眠データ取得の開始
                manage.WatchBleService.GetTodaySleep()
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 3) {
                    let TodaySleepData = manage.WatchBleService.GetTodaySleepData()
                    // バッテリーレベル取得
                    let batteryLevel = manage.WatchBleService.GetBatteryLevel()
                    // ファームウェアバージョン取得
                    let firmwareVersion = manage.WatchBleService.GetFirmwareVersion()
                    //print("ver:" + firmwareVersion)
                    // データ送信用JSON作成
                    let json = self.crpSmartbandService.CreateSleepSendDataJson(sleepDetail: TodaySleepData, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, firmwareVersion: firmwareVersion, batteryLevel: batteryLevel, rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Sleep.rawValue)
    //                // データ送信
                    self.dcService.PostSend(data: json)
                    
                    //睡眠csv出力
                    let deviceName = (manage.WatchBleService.GetDeviceName() ?? "") + (manage.WatchBleService.GetMacAddress() ?? "")
                    self.crpSmartbandService.SleepDataCsvOutput(deviceNameKey: deviceName, sleepDetail: TodaySleepData)
                    
                    //test
                    // CSVファイル名
                    let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
                    let csvFileNameStr = "TodaySleepDataLog_"
                    let csvFileName = csvFileNameStr + "\(nowDate).txt"
                    // ディレクトリの作成
                        self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
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
                    
                    writeData = dateString

                    csvWriteData.append("\n")
                    csvWriteData.append(writeData)
                        
                    // ファイル書き込み
                    self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
                    let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
                    let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
                    
                    let logDir = "Receive/Log"
                        
                    // ログフォルダ内のファイル名一覧を取得する
                        var allFiles = self.fileUtil.ContentsOfDirectory(atPath: logDir)
                    allFiles.sort{$0 < $1}
                        
                    let startIndexPoint = csvFileNameStr.utf8.count
                    let endIndexPoint = -5
                        
                    for file in allFiles{

                        // ２日前以前のログファイルを削除する
                        if file.contains("TodaySleepDataLog") {
                            let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                            let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                            let YYYYMMdd_HH = file[startIndex...endIndex]
                                //print(YYYYMMdd_HH)
                            //print(beforeDtStr)
                            
                            if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                                || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                                let delFile = "\(logDir)/\(file)"
                                self.fileUtil.RemoveItem(atPath: delFile)
                            }
                        }
                    }
                }
            }
            else{
                //CommonUtil.Print(className: self.className, message: "未接続　デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチ未接続のため、データ送信はなし
            }
            
        }
    }
    
    
    /// CRPsmartBand睡眠履歴データ送信タイマー
    @objc func sendSleepHistoryTimer(){
        var state : CBPeripheralState = .disconnected
        
        for manage in self.CRPSmartBandManageDic.values{
            //ウォッチ接続状態の確認
            if let discovery = manage.WatchBleService.GetConnectDiscovery() {
                //CommonUtil.Print(className: self.className, message: "discoveryデバイス名：\(discovery.localName ?? "") MACアドレス：\(discovery.mac ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "discovery device name:\(discovery.localName ?? "") MAC address:\(discovery.mac ?? "")")
                state = discovery.remotePeripheral.state
            }
            else{
                state = CBPeripheralState.disconnected
            }
            
            //ウォッチ接続状態によって24時間心拍数データを送るか判定
            if state == CBPeripheralState.connected{
                //CommonUtil.Print(className: self.className, message: "接続中 デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチの睡眠データ取得の開始
                manage.WatchBleService.GetYesterdaySleep()
                
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 3) {
                    manage.WatchBleService.GetTodaySleep()
                }
                
                DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 6) {
                    //睡眠履歴データ
                    let SleepHistoryData = manage.WatchBleService.GetYesterdaySleepData()
                    //睡眠データ
                    let TodaySleepData = manage.WatchBleService.GetTodaySleepData()
                    // バッテリーレベル取得
                    let batteryLevel = manage.WatchBleService.GetBatteryLevel()
                    // ファームウェアバージョン取得
                    let firmwareVersion = manage.WatchBleService.GetFirmwareVersion()
                    //print("ver:" + firmwareVersion)
                    
                    // データ送信用JSON作成
                    let json = self.crpSmartbandService.CreateSleepHistorySendDataJson(sleepDetail : TodaySleepData, sleepHistoryDetail: SleepHistoryData[0].detail, deviceId: manage.WatchSettingInfo.WatchDeviceName!, deviceAddress: manage.WatchSettingInfo.WatchMacAddress!, firmwareVersion: firmwareVersion, batteryLevel: batteryLevel, rssi: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Sleep24.rawValue)
                    // データ送信
                    self.dcService.PostSend(data: json)
                    
                   
                    //睡眠履歴csv出力
                    let deviceName = (manage.WatchBleService.GetDeviceName() ?? "") + (manage.WatchBleService.GetMacAddress() ?? "")
                    self.crpSmartbandService.SleepHistoryDataCsvOutput(deviceNameKey: deviceName, sleepHistoryData: SleepHistoryData[0].detail)
                    
                    //test
                    // CSVファイル名
                    let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
                    let csvFileNameStr = "SleepHistoryDataLog_"
                    let csvFileName = csvFileNameStr + "\(nowDate).txt"
                    // ディレクトリの作成
                        self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir + "/" + "Log")
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
                    
                    writeData = dateString

                    csvWriteData.append("\n")
                    csvWriteData.append(writeData)
                        
                    // ファイル書き込み
                    self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
                    let before : Date = DateUtil.GetAddedDate(num: CommonConst.logSavingDate)
                    let beforeDtStr = DateUtil.GetDateFormatConvert(format: "YYYYMMdd", dt: before)
                    
                    let logDir = "Receive/Log"
                        
                    // ログフォルダ内のファイル名一覧を取得する
                        var allFiles = self.fileUtil.ContentsOfDirectory(atPath: logDir)
                    allFiles.sort{$0 < $1}
                        
                    let startIndexPoint = csvFileNameStr.utf8.count
                    let endIndexPoint = -5
                        
                    for file in allFiles{

                        // ２日前以前のログファイルを削除する
                        if file.contains("SleepHistoryDataLog") {
                            let startIndex = file.index(file.startIndex, offsetBy: startIndexPoint)
                            let endIndex = file.index(file.endIndex,offsetBy: endIndexPoint)
                            let YYYYMMdd_HH = file[startIndex...endIndex]
                                //print(YYYYMMdd_HH)
                            //print(beforeDtStr)
                            
                            if (YYYYMMdd_HH.compare(beforeDtStr) == .orderedAscending
                                || YYYYMMdd_HH.compare(beforeDtStr) == .orderedSame) {
                                let delFile = "\(logDir)/\(file)"
                                self.fileUtil.RemoveItem(atPath: delFile)
                            }
                        }
                    }
                    
                }
            }
            else{
                //CommonUtil.Print(className: self.className, message: "未接続　デバイス名：\(manage.WatchBleService.GetDeviceName() ?? "") MACアドレス：\(manage.WatchBleService.GetMacAddress() ?? "")")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "not connected device name:\(manage.WatchBleService.GetDeviceName() ?? "") MAC address:\(manage.WatchBleService.GetMacAddress() ?? "")")
                ///ウォッチ未接続のため、データ送信はなし
            }
            
        }
    }

    
    /// CRPSmartBandデータ取得監視・タイマーStart
    private func startCRPSmartBandGetDataMonitoringTimer(){
        //let message = "CRPSmartBandデータ取得監視タイマー"
        //CommonUtil.Print(className: self.className, message: message + "Start")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to start timer")
        if self.crpSmartBandGetDataMonitoringTimer == nil{
            if self.CRPSmartBandGetDataMonitoring == 0 {
                self.CRPSmartBandGetDataMonitoring = 5
            }
            
            //タイマー設定
            self.crpSmartBandGetDataMonitoringTimer = Timer.scheduledTimer(timeInterval: self.CRPSmartBandGetDataMonitoring * 60, target: self, selector: #selector(crpSmartBandGetDataMonitoring), userInfo: nil, repeats: true)
            print("delayTime restart")
            //CommonUtil.Print(className: self.className, message: message + "設定完了")
            // タイマーStart
            self.crpSmartBandGetDataMonitoringTimer.fire()
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer started")
        }
    }
    
    /// CRPSmartBandデータ取得監視・タイマーStop
    private func stopCRPSmartBandGetDataMonitoringTimer(){
        //let message = "CRPSmartBandデータ取得監視タイマー"
        //CommonUtil.Print(className: self.className, message: message + "Stop")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to stop timer")
        if self.crpSmartBandGetDataMonitoringTimer != nil && self.crpSmartBandGetDataMonitoringTimer.isValid{
            // タイマーを停止
            self.crpSmartBandGetDataMonitoringTimer.invalidate()
            self.crpSmartBandGetDataMonitoringTimer = nil
            
            //CommonUtil.Print(className: self.className, message: message +  "Stop完了")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "timer stopped")
        }
    }
    /// CRPSmartBandデータ取得監視
    @objc func crpSmartBandGetDataMonitoring() {
        //CommonUtil.Print(className: self.className, message: "CRPSmartBandデータ取得監視")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start monitoring")
        //test
        // CSVファイル名
        let nowDate = DateUtil.GetDateFormatConvert(format: "yyyyMMdd")
        let csvFileNameStr = "watchMainTimeLog_"
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
        
        writeData = dateString + "," + "timerStart"

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

            // 2日前以前のログファイルを削除する
//            if file.contains("timerStart") {
            if file.contains("watchMainTimeLog_"){
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
        
        
        var incompleteSb : CRPSmartBandManageService?
//        var prossesingSb : CRPSmartBandManageService?
        var completeCount : Int = 0
        var state : CBPeripheralState = .disconnected
//        var ProssesingConnectRetryCount : [Int]
        
        
        for manage in self.CRPSmartBandManageDic.values{
            switch manage.MeasurementResultDataStatus {
            case .Incomplete:
                // データ取得未完
                if incompleteSb == nil{
                    incompleteSb = manage
                }
                break
//            case .Prossesing:
                // データ取得処理中
//                prossesingSb = manage
//               break
            case .Complete:
                // データ取得完了
                completeCount+=1
                continue

            }
        }
/*
        // データ取得処理中
        if prossesingSb != nil{
            CommonUtil.Print(className: self.className, message: "データ取得処理中")
            
            if let discovery = prossesingSb!.WatchBleService.GetConnectDiscovery() {
                CommonUtil.Print(className: self.className, message: "デバイス：\(prossesingSb!.WatchBleService.GetDeviceNameKey() ?? "")")
                
                state = discovery.remotePeripheral.state
            }
            
            if state == .connected{
                // 処理中カウント インクリメント
                prossesingSb?.ProssesingConnectCount+=1
                CommonUtil.Print(className: self.className, message: "データ取得処理中\(prossesingSb!.ProssesingConnectCount)回目")
                
                ProssesingConnectRetryCount = setWatchRestartCount()
                
//                if prossesingSb!.ProssesingConnectCount >= WatchConst.Retry.ProssesingConnectRetryStartCount {
//                    if prossesingSb!.ProssesingConnectCount <= WatchConst.Retry.ProssesingConnectRetryEndCount {
                if prossesingSb!.ProssesingConnectCount >= ProssesingConnectRetryCount[0] {
                    if prossesingSb!.ProssesingConnectCount <= ProssesingConnectRetryCount[1] {
                        
                        if prossesingSb!.ProssesingConnectRetryCount > 0{
                            CommonUtil.Print(className: self.className, message: "データ取得処理中 リトライ\(prossesingSb!.ProssesingConnectRetryCount)回目")
                        }
                        // 処理中リトライカウント インクリメント
                        prossesingSb!.ProssesingConnectRetryCount+=1
                    }
                    else{
                        CommonUtil.Print(className: self.className, message: "データ取得処理中リトライ完了")
                        // 未接続状態のため完了にする
                        prossesingSb?.MeasurementResultDataStatus = .Complete
                        // 処理中カウント初期化
                        prossesingSb?.ProssesingConnectCount = 0
                        // 処理中リトライカウント初期化
                        prossesingSb!.ProssesingConnectRetryCount = 0
                    }
                }
            }
            else{
                CommonUtil.Print(className: self.className, message: "データ取得処理中・未接続")
                // 未接続状態のため完了にする
                prossesingSb?.MeasurementResultDataStatus = .Complete
                // 処理中カウント初期化
                prossesingSb?.ProssesingConnectCount = 0
                // 処理中リトライカウント初期化
                prossesingSb!.ProssesingConnectRetryCount = 0
            }
            //test
            writeData = dateString + "," + "return"

            csvWriteData.append("\n")
            csvWriteData.append(writeData)
                
            // ファイル書き込み
            self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
            
            return
        }
        */
        // 全てデータ取得完了
        if completeCount == self.self.CRPSmartBandManageDic.count{
            //CommonUtil.Print(className: self.className, message: "データ取得完了")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "completed")
            for manage in self.CRPSmartBandManageDic.values{
                // 全て未完状態にする
                manage.MeasurementResultDataStatus = .Incomplete
            }
            // データ取得未完
            incompleteSb = self.CRPSmartBandManageDic.values.first
        }
        
        // データ取得未完
        if incompleteSb != nil{
            //CommonUtil.Print(className: self.className, message: "データ取得未完")
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "incompleted")
            if let discovery = incompleteSb!.WatchBleService.GetConnectDiscovery() {
                CommonUtil.Print(className: self.className, message: "デバイス:\(incompleteSb!.WatchBleService.GetDeviceNameKey() ?? "")")
                state = discovery.remotePeripheral.state
            }
            
            if state == .connected{
                CommonUtil.Print(className: self.className, message: "データ取得未完・接続中")
                // データ取得処理中
//                incompleteSb?.MeasurementResultDataStatus = .Prossesing
                //データ取得するデバイスに接続
                incompleteSb?.WatchBleService.ConnectDiscovery()
                //test
                writeData = dateString + "," + "HeartRateStart"

                csvWriteData.append("\n")
                csvWriteData.append(writeData)
                    
                // ファイル書き込み
                self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "HeartRateStart")
            }
            else{
                //CommonUtil.Print(className: self.className, message: "データ取得未完・未接続")
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "incompleted not connected")
                // 未接続状態のため接続開始
                if incompleteSb!.WatchSettingInfo.IsWatchSettings{
                    // ウォッチ設定中
                    
                    if incompleteSb!.IncompleteDisconnectRetryCount <= WatchConst.Retry.IncompleteDisconnectRetryEndCount {
                        
                        if incompleteSb!.IncompleteDisconnectRetryCount > 0{
                            //CommonUtil.Print(className: self.className, message: "データ取得未完・接続 リトライ\(incompleteSb!.IncompleteDisconnectRetryCount)回目")
                            //システムログ作成、送信
                            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "retry to connect count:\(incompleteSb!.IncompleteDisconnectRetryCount)")
                        }
                        // ウォッチ スキャンデバイスタイマーStart
                        //incompleteSb?.StartWatchScanDeviceTimer()
                        
                        //ウォッチ再接続
                        incompleteSb?.WatchBleService.ReConnect()
                        
                        // 未完リトライカウント インクリメント
                        incompleteSb!.IncompleteDisconnectRetryCount+=1
                        
                        //test
                        //test
                        writeData = dateString + "," + "ReconnectStart"

                        csvWriteData.append("\n")
                        csvWriteData.append(writeData)
                            
                        // ファイル書き込み
                        self.fileUtil.WritingToFile(text: csvWriteData,fileName: receiveFileName)
                        //システムログ作成、送信
                        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "reconnectstart")
                    }
                    else{
                        //CommonUtil.Print(className: self.className, message: "データ取得未完・接続 リトライ完了")
                        //システムログ作成、送信
                        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "incompleted not connected give up to retry")
                        // ウォッチ スキャンデバイスタイマーStop
                        //incompleteSb?.StopWatchScanDeviceTimer()
                        // 未接続状態のため完了にする
                        incompleteSb?.MeasurementResultDataStatus = .Complete
                        // 未完リトライカウント初期化
                        incompleteSb!.IncompleteDisconnectRetryCount = 0
                    }
                }
            }
        }
    }
/*
    func setWatchRestartCount() -> [Int]{
        var ProssesingConnectRetryCountArray : [Int] = []
        switch self.CRPSmartBandGetDataMonitoring {
        case 1:
            ProssesingConnectRetryCountArray.append(3)
            ProssesingConnectRetryCountArray.append(3)
            break
        case 2:
            ProssesingConnectRetryCountArray.append(2)
            ProssesingConnectRetryCountArray.append(0)
            break
        case 3:
            ProssesingConnectRetryCountArray.append(1)
            ProssesingConnectRetryCountArray.append(0)
            break
        case 4:
            ProssesingConnectRetryCountArray.append(1)
            ProssesingConnectRetryCountArray.append(0)
            break
        case 5:
            ProssesingConnectRetryCountArray.append(1)
            ProssesingConnectRetryCountArray.append(0)
            break
        case 6:
            ProssesingConnectRetryCountArray.append(0)
            ProssesingConnectRetryCountArray.append(0)
            break
        default:
            ProssesingConnectRetryCountArray.append(0)
            ProssesingConnectRetryCountArray.append(0)
            break
        }
        return ProssesingConnectRetryCountArray
    }
 */
}
