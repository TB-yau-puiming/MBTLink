//
// MeasuringInstrumentDetailViewController.swift
// 測定機器設定子画面
//
// MBTLink
//

import UIKit
import CoreBluetooth

class MeasuringInstrumentDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - UI部品
    /// 状態
    @IBOutlet weak var statusLabel: UILabel!
    /// ペアリングボタン
    @IBOutlet weak var pairingButton: UIButton!
    /// TableView
    @IBOutlet weak var tableView: UITableView!
    /// シリアルナンバータイトル
    @IBOutlet weak var serialNumberTitleLabel: UILabel!
    /// シリアルナンバー
    @IBOutlet weak var serialNumberLabel: UILabel!
    /// UUID
    @IBOutlet weak var uuidLabel: UILabel!
    /// 測定間隔タイトル
    @IBOutlet weak var measuringIntervalTitleLabel: UILabel!
    /// 測定間隔テキスト
    @IBOutlet weak var measuringIntervalText: UITextField!
    /// 接続可能なデバイスタイトル
    @IBOutlet weak var connectableDeviceTitleLabel: UILabel!
    /// インジケーター
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    /// 測定間隔PickerView
    var measuringIntervalPickerView = UIPickerView()
    
    // MARK: - Public変数
    /// 測定機器管理
    public var MeasuringInstrumentManage : MeasuringInstrumentManageService!
    /// データ通信サービス
    public var DcService : DataCommunicationService!
    /// デバイス名
    public var DeviceName : String = ""
    /// タイトル名
    public var TitleName : String = ""
    
    // MARK: - Private変数
    ///メソッド実行数カウント
    private var successToScanDeviceCount : Int = 30
    /// クラス名
    private let className = String(String(describing: ( MeasuringInstrumentDetailViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// BLEサービス
    private var bleService : BleService!
    /// 測定機器サービス
    private var measuringInstrumentService  : MeasuringInstrumentBaseService!
    /// 環境センサ・シリアルナンバー辞書
    private var envSensorSerialNumberDic = [String:CBPeripheral]()
    /// デバイス設定中かどうか
    private var isDeviceSettings : Bool = false
    /// ペアリング可否
    private var doPairing : Bool = false
    /// ペアリング中
    private var isPairingNow : Bool = false
    /// 選択中のシリアルナンバー
    private var selectSerialNumber : String? = ""
    /// 選択中のペリフェラル
    private var selectPeripheral : CBPeripheral?
    /// 測定間隔Array
    private let measuringIntervalArray : [String] = [StringsConst.THREE_MINUTES,StringsConst.FIVE_MINUTES,StringsConst.TEN_MINUTES,StringsConst.THIRTY_MINUTES]
    
    /// 接続中デバイス名
    private var deviceNamePairing : String? = ""
    ///シリアル番号
    private var serialNum : String = ""
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        serialNumberLabel.adjustsFontSizeToFitWidth = true
        uuidLabel.adjustsFontSizeToFitWidth = true
        // 測定間隔ラベルの設定
        self.measuringIntervalTitleLabel.layer.borderWidth = 2.0
        self.measuringIntervalTitleLabel.layer.borderColor = UIColor.black.cgColor
        self.measuringIntervalTitleLabel.layer.cornerRadius = 20.0      // 角の半径
        self.measuringIntervalTitleLabel.clipsToBounds = true           // この設定を入れないと角丸にならない
        // 測定間隔PickerViewの設定
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title:StringsConst.DECISION,style: .done, target: self, action: #selector(didTapDoneButton))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        // 測定間隔テキスト インプットビュー設定
        self.measuringIntervalText.inputView = self.measuringIntervalPickerView
        self.measuringIntervalText.inputAccessoryView = toolbar
        
        // 設定情報保存
        // 設定中かどうか
        self.isDeviceSettings = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.IsSettings
        // デバイス名
        self.DeviceName = ((self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.DeviceName != nil) ? self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.DeviceName! : "")
        // シリアルナンバー
        self.serialNumberLabel.text = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.SerialNumber
        // UUID
        self.uuidLabel.text = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.Uuid
        // 測定間隔
        self.measuringIntervalText.text = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.MeasuringInterval
        // 接続中デバイス名
        self.deviceNamePairing = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.DeviceNamePairing
        
        // サービスの初期化
        self.bleService = nil
        
        switch self.DeviceName{
        case EnvSensorConst.DeviceName:
            // 環境センサー
            self.measuringInstrumentService = EnvSensorService()
            // BLEサービス初期化
            self.bleService = MeasuringInstrumentManage.BleService.copy()
            // ペアリングステータスの変更
            self.bleService.SetPairingStatus(bool: false)
            // デバイス未設定の場合のみサービスを設定する
            if self.isDeviceSettings == false {
                // ペアリングスキャン用のUUID設定
                self.setupUUID()
            }
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case WeightScaleConst.DeviceName:
            // 体重計
            self.measuringInstrumentService = WeightScaleService()
            // BLEサービス初期化
            self.bleService = MeasuringInstrumentManage.BleService.copy()
            // ペアリングステータスの変更
            self.bleService.SetPairingStatus(bool: false)
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 血圧計
            self.measuringInstrumentService = BloodPressuresMonitorService()
            // BLEサービス初期化
            self.bleService = MeasuringInstrumentManage.BleService.copy()
            // ペアリングステータスの変更
            self.bleService.SetPairingStatus(bool: false)
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case ThermometerConst.DeviceName:
            // 体温計
            self.measuringInstrumentService = ThermometerService()
            // BLEサービス初期化
            self.bleService = MeasuringInstrumentManage.BleService.copy()
            // ペアリングステータスの変更
            self.bleService.SetPairingStatus(bool: false)
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case PulseOximeterConst.DeviceName:
            // パルスオキシメータ
            self.measuringInstrumentService = PulseOximeterService()
            // BLEサービス初期化
            self.bleService = MeasuringInstrumentManage.BleService.copy()
            // ペアリングステータスの変更
            self.bleService.SetPairingStatus(bool: false)
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        default:
            break
        }
        
        // セントラルマネージャーの初期化
        self.bleService.SetupBluetoothService()

        // 測定間隔
        if self.DeviceName == PulseOximeterConst.DeviceName{
            // パルスオキシメーター
            if self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.MeasuringInterval == "" {
                self.measuringIntervalText.text = StringsConst.THREE_MINUTES
            }
            else{
                self.measuringIntervalText.text = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.MeasuringInterval
            }
        }
        else{
            self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.MeasuringInterval = ""
            self.measuringIntervalText.text = ""
        }
        // 画面部品初期設定
        self.screenPartsInitial()
        // デバイス設定中or未設定
        self.deviceSettings(isSettings: self.isDeviceSettings)
        // ナビゲーションタイトル
        
        let navbarTitle = UILabel()
            navbarTitle.text = self.TitleName
            navbarTitle.font = UIFont.boldSystemFont(ofSize: 17)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
            
        self.navigationItem.titleView = navbarTitle
        //self.navigationItem.largeTitleDisplayMode = .automatic
        
        // デリゲート設定
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.bleService.delegate = self
        self.measuringIntervalPickerView.delegate = self
        self.measuringIntervalPickerView.dataSource = self
        
        // BleServiceのコンソール出力処理
        CommonUtil.Print(className: self.className, message: "===測定機器設定子画面 viewDidLoad終了時点 BleServiceログ出力開始===")
        CommonUtil.Print(className: self.className, message: "\(self.DeviceName)のBleService")
        self.bleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "===測定機器設定子画面 viewDidLoad終了時点 BleServiceログ出力終了===")

        // インジケーター開始
        self.indicator.startAnimating()
        
        if self.DeviceName == EnvSensorConst.DeviceName {
            //BLEスキャン開始
            self.bleService.StartBleScan()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //CommonUtil.Print(className: self.className, message: "viewWillAppear表示")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        // 測定間隔PickerView選択設定
        self.measuringIntervalPickerView.selectRow(self.measuringIntervalArray.lastIndex(of: self.measuringIntervalText.text!) ?? 0, inComponent: 0, animated: false)
    }

    /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // インジケーター終了
        self.indicator.stopAnimating()
        
        if self.DeviceName == EnvSensorConst.DeviceName {
            //BLEスキャンSTOP
            self.bleService.StopBleScan()
        }
            
        // 遷移元に値を戻す
        let preNc = self.parent as! UINavigationController
        let preVc = preNc.children[1] as! MeasuringInstrumentSettingTableViewController

        // 設定情報保存
        self.setMeasuringInstrumentManage()

        // 設定情報登録
        switch self.DeviceName{
        case EnvSensorConst.DeviceName:
            // 環境センサー
            preVc.EnvSensorManage = self.MeasuringInstrumentManage
            break
        case WeightScaleConst.DeviceName:
            // 体重計
            preVc.WeightScaleManage = self.MeasuringInstrumentManage
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 血圧計
            preVc.BpmManage = self.MeasuringInstrumentManage
            break
        case ThermometerConst.DeviceName:
            // 体温計
            preVc.ThermometerManage = self.MeasuringInstrumentManage
            break
        case PulseOximeterConst.DeviceName:
            // パルスオキシメータ
            preVc.PulseOximeterManage = self.MeasuringInstrumentManage
            break
        default:
            break
        }

        // インスタンス破棄
        self.bleService = nil
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ペアリングボタン押下
    @IBAction func clickPairingButton(_ sender: Any) {
        
        var message : String = ""
        
        /// 各サービス取得
        // デバイスインフォメーション
        let deviceInfoService = self.bleService.GetDeviceInfoService()
        // バッテリー
        let batteryService = self.bleService.GetBatteryService()
        // 書き込み
        let writeService = self.bleService.GetWriteService()
        
        if self.DeviceName == EnvSensorConst.DeviceName {
            // 環境センサー
            if self.isDeviceSettings{
                //デバイス設定中
                //アラート生成
                //UIAlertControllerのスタイルがalert
                let alert: UIAlertController = UIAlertController(title: StringsConst.UNPAIR_MESSAGE, message:  message, preferredStyle:  UIAlertController.Style.alert)
            
                // 解除ボタンの処理
                let confirmAction: UIAlertAction = UIAlertAction(title: StringsConst.UNPAIR, style: UIAlertAction.Style.default, handler:{
                    // 解除ボタンが押された時の処理をクロージャ実装する
                    (action: UIAlertAction!) -> Void in
                        CommonUtil.Print(className: self.className, message: "解除")
                    
                    // デバイス切断
                    self.bleService.DisconnectPeripheral()
                    // 処理待ちフラグをtrueにする
                    deviceInfoService.isProcessPending = true
                    // 設定デバイス削除
                    self.MeasuringInstrumentManage.RemoveMeasuringInstrumentSettingData()
                    // デバイス未設定
                    self.deviceSettings(isSettings: false)
                    
                    // 接続中デバイス名初期化
                    self.deviceNamePairing = ""
                    
                    // TableViewリロード
                    self.tableView.reloadData()
                    
                    // ペアリングスキャン用のUUID設定
                    self.setupUUID()
                    
                    //BLEスキャン開始
                    self.bleService.StartBleScan()
                    
                    // データ送信用JSON作成
                    let rssi = self.bleService.GetRssi() ?? nil
                    var rssiStr = ""
                    if let rssiInt = rssi {
                        rssiStr = String(rssiInt)
                    }
                    let json = self.measuringInstrumentService.CreatePairingDataJson(deviceId: EnvSensorConst.DeviceId, deviceAddress: "", batteryLevel: "", rssi: rssiStr, sendDataType: DataCommunicationService.SendDataTypeOther.Pairing.rawValue, deviceType: DataCommunicationService.DeviceType.EnvSensor.rawValue)
                    ///ペアリング情報の送信
                    DataCommunicationService.postSendPairing(data: json)
                    
                    // Top画面のデバイス切断
                    self.disConnectTopViewDevice()
  
                })
            
                // キャンセルボタンの処理
                let cancelAction: UIAlertAction = UIAlertAction(title: StringsConst.CANCEL, style: UIAlertAction.Style.cancel, handler:{
                    // キャンセルボタンが押された時の処理をクロージャ実装する
                    (action: UIAlertAction!) -> Void in
                        CommonUtil.Print(className: self.className, message: "キャンセル")
                })

                //UIAlertControllerにキャンセルボタンと解除ボタンをActionを追加
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)

                //実際にAlertを表示する
                present(alert, animated: true, completion: nil)
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "unpair")
            }
            else{
                // 測定機器未設定
                if self.doPairing {
                    //アラート生成
                    //UIAlertControllerのスタイルがalert
                    let serialNumber : String? = self.selectSerialNumber
                    if StringsConst.LANGUAGE == "日本語"{
                        let messagetext = String(StringsConst.PAIR_MESSAGE)
                        message  = (serialNumber ?? "") + messagetext
                    }else if StringsConst.LANGUAGE == "English"{
                        let messagetext = String(StringsConst.PAIR_MESSAGE)
                        message  = messagetext + (serialNumber ?? "") + StringsConst.QUESTION_MARK
                    }
                    let alert: UIAlertController = UIAlertController(title: StringsConst.CONFIRM, message:  message, preferredStyle:  UIAlertController.Style.alert)
                
                    // OKボタンの処理
                    let confirmAction: UIAlertAction = UIAlertAction(title: StringsConst.OK, style: UIAlertAction.Style.default, handler:{
                        // OKボタンが押された時の処理をクロージャ実装する
                        (action: UIAlertAction!) -> Void in
                            CommonUtil.Print(className: self.className, message: "OK")
                        
                        self.statusLabel.text = StringsConst.CONNECTING
                            // ペアリング中
                            self.isPairingNow = true
                            // 機器に接続
                            self.bleService.SetConnectPeripheral(peripheral: self.selectPeripheral)
                            self.bleService.ConnectPeripheral()
                        
                            // データ送信用JSON作成
                            let rssi = self.bleService.GetRssi() ?? nil
                            var rssiStr = ""
                            if let rssiInt = rssi {
                                rssiStr = String(rssiInt)
                            }
                            let json = self.measuringInstrumentService.CreatePairingDataJson(deviceId: EnvSensorConst.DeviceId, deviceAddress: self.serialNum, batteryLevel: "", rssi: rssiStr, sendDataType: DataCommunicationService.SendDataTypeOther.Pairing.rawValue, deviceType: DataCommunicationService.DeviceType.EnvSensor.rawValue)
                            ///ペアリング情報の送信
                            DataCommunicationService.postSendPairing(data: json)
                    })
                
                    // キャンセルボタンの処理
                    let cancelAction: UIAlertAction = UIAlertAction(title: StringsConst.CANCEL, style: UIAlertAction.Style.cancel, handler:{
                        // キャンセルボタンが押された時の処理をクロージャ実装する
                        (action: UIAlertAction!) -> Void in
                            CommonUtil.Print(className: self.className, message: "キャンセル")
                    })

                    //UIAlertControllerにキャンセルボタンとOKボタンをActionを追加
                    alert.addAction(cancelAction)
                    alert.addAction(confirmAction)

                    //実際にAlertを表示する
                    present(alert, animated: true, completion: nil)
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "to pair")
                }
            }
        }
        else{
            if self.isDeviceSettings{
                // デバイス切断
                self.bleService.DisconnectPeripheral()
                
                // 処理待ちフラグをtrueにする
                if (self.DeviceName == PulseOximeterConst.DeviceName){
                    // パルスオキシメーター
                    deviceInfoService.isProcessPending = true
                } else {
                    // 体重計・体温計・血圧計
                    batteryService.isProcessPending = true
                    deviceInfoService.isProcessPending = true
                    writeService.isProcessPending = true
                }

                // 設定デバイス削除
                self.MeasuringInstrumentManage.RemoveMeasuringInstrumentSettingData()
                
                // デバイス未設定
                self.deviceSettings(isSettings: false)
                
                // 接続中デバイス名初期化
                self.deviceNamePairing = ""
                
                // ペアリングデータ送信
                sendPairingData(deviceName: self.DeviceName, deviceAddress: "", uuid: "", battery: "")
                
                // Top画面のデバイス切断
                self.disConnectTopViewDevice()
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "unpair")
            }
            else{
                if self.isPairingNow {
                    // スキャンSTOP
                    self.bleService.StopBleScan()
                    // デバイス未設定
                    self.deviceSettings(isSettings: false)
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "stop scanning")
                }
                else{
                    // 書き込みデータ（日時）作成
                    let nowDateTime = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
                    let writeData = ConvertUtil.WriteDataForDateTime(str: nowDateTime)
                    self.bleService.SetWriteData(writeData: writeData)
                    
                    self.statusLabel.text = StringsConst.SEARCHING
                    self.pairingButton.setTitle(StringsConst.STOP_SCANNING, for: .normal)

                    // 接続デバイス名の初期化
                    switch self.DeviceName{
                    case EnvSensorConst.DeviceName:
                        self.bleService.SetDeviceNamePairing(deviceNamePairing: EnvSensorConst.DeviceName)
                    case WeightScaleConst.DeviceName:
                        self.bleService.SetDeviceNamePairing(deviceNamePairing: WeightScaleConst.DeviceName)
                    case BloodPressuresMonitorConst.DeviceName:
                        self.bleService.SetDeviceNamePairing(deviceNamePairing: BloodPressuresMonitorConst.DeviceName)
                    case ThermometerConst.DeviceName:
                        self.bleService.SetDeviceNamePairing(deviceNamePairing: ThermometerConst.DeviceName)
                    case PulseOximeterConst.DeviceName:
                        self.bleService.SetDeviceNamePairing(deviceNamePairing: PulseOximeterConst.DeviceName)
                    default:
                        self.bleService.SetDeviceNamePairing(deviceNamePairing: "")
                    }
                    
                    // ペアリングスキャン用のUUID設定
                    self.setupUUID()
                    // ペアリング中
                    self.isPairingNow = true
                    //BLEスキャン開始
                    self.bleService.StartBleScan()
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "start scanning")
                }
            }
        }
        
        // BleServiceのコンソール出力処理
        CommonUtil.Print(className: self.className, message: "===測定機器設定子画面 clickPairingButton終了時点 BleServiceログ出力開始===")
        CommonUtil.Print(className: self.className, message: "\(self.DeviceName)のBleService")
        self.bleService.loggingBleServiceContents()
        CommonUtil.Print(className: self.className, message: "===測定機器設定子画面 clickPairingButton終了時点 BleServiceログ出力終了===")
    }

    // 画面の設定情報を測定機器設定サービスに反映
    private func setMeasuringInstrumentManage(){
        // 設定情報保存
        // 設定中かどうか
        self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.IsSettings = self.isDeviceSettings
        // デバイス名
        self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.DeviceName = self.DeviceName
        // シリアルナンバー
        self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.SerialNumber = self.serialNumberLabel.text
        // UUID
        self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.Uuid = self.uuidLabel.text
        // 測定間隔
        self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.MeasuringInterval = self.measuringIntervalText.text
        // 接続中デバイス名
        self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.DeviceNamePairing = self.deviceNamePairing
        // 設定情報登録
        self.MeasuringInstrumentManage.SaveMeasuringInstrumentSettingData()

        // bleサービス内の接続中デバイス名
        self.MeasuringInstrumentManage.BleService.SetDeviceNamePairing(deviceNamePairing: ((self.deviceNamePairing != nil) ? self.deviceNamePairing! : ""))
        // bleサービス名のペアリングステータス
        self.MeasuringInstrumentManage.BleService.SetPairingStatus(bool: self.isDeviceSettings)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Private Methods
    /// デバイス設定
    private func deviceSettings(isSettings : Bool){
        
        if isSettings{
            //設定中
            self.statusLabel.text = StringsConst.CONFIGURED
            self.pairingButton.setTitle(StringsConst.UNPAIRING, for: .normal)
            
            if self.DeviceName == EnvSensorConst.DeviceName {
                // 環境センサー
                // 表示
                self.serialNumberTitleLabel.isHidden = false
                self.serialNumberLabel.isHidden = false
                // 非表示
                self.tableView.isHidden = true
                self.connectableDeviceTitleLabel.isHidden = true
                self.indicator.isHidden = true
            }
            // シリアルナンバー
            self.serialNumberLabel.text = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.SerialNumber
            // UUID
            self.uuidLabel.text = self.MeasuringInstrumentManage.MeasuringInstrumentSettingInfo.Uuid
        }
        else{
            //未設定
            self.statusLabel.text = StringsConst.NOT_CONNECTED
            self.pairingButton.setTitle(StringsConst.START_PAIRING, for: .normal)
            
            if self.DeviceName == EnvSensorConst.DeviceName {
                // 環境センサー
                // 表示
                self.tableView.isHidden = false
                self.connectableDeviceTitleLabel.isHidden = false
                self.indicator.isHidden = false
                // 非表示
                self.serialNumberTitleLabel.isHidden = true
                self.serialNumberLabel.isHidden = true
                
            }
            // シリアルナンバー
            self.serialNumberLabel.text = ""
            // UUID
            self.uuidLabel.text = ""
            // デバイス未設定
            self.isDeviceSettings = false
            // ペアリング可否
            self.doPairing = false
            // ペアリング中
            self.isPairingNow = false
            // 選択中のデバイス
            self.selectSerialNumber = ""
            self.selectPeripheral = nil
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 画面部品初期設定
    private func screenPartsInitial(){
        self.serialNumberTitleLabel.text = StringsConst.BD_ADDRESS_OR_SERIAL_NUMBER
        // 非表示
        self.measuringIntervalTitleLabel.isHidden = true
        self.measuringIntervalText.isHidden = true
        self.uuidLabel.isHidden = true
        
        if self.DeviceName == EnvSensorConst.DeviceName {
            // 環境センサー
            self.serialNumberTitleLabel.text = StringsConst.SERIAL_NUMBER
            // 表示
            self.connectableDeviceTitleLabel.isHidden = false
            self.indicator.isHidden = false
            self.tableView.isHidden = false
            // 非表示
            self.serialNumberTitleLabel.isHidden = true
            self.serialNumberLabel.isHidden = true
        }
        else{
            // 非表示
            self.connectableDeviceTitleLabel.isHidden = true
            self.indicator.isHidden = true
            self.tableView.isHidden = true
            
            if self.DeviceName == PulseOximeterConst.DeviceName{
                // パルスオキシメータ
                self.serialNumberTitleLabel.text = StringsConst.DEVICE_ID
                // 表示
                self.measuringIntervalTitleLabel.isHidden = false
                self.measuringIntervalText.isHidden = false
                self.uuidLabel.isHidden = false
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Table view イベント関連
    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.envSensorSerialNumberDic.count
    }

    /// 各セルを生成して返却します。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = EnvSensorConst.DeviceName
        cell.detailTextLabel?.text = Array(self.envSensorSerialNumberDic.keys)[indexPath.row]
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return cell
    }

    /// セルが選択された時に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at:indexPath)
        // チェックマークを入れる
        cell?.accessoryType = .checkmark
        //ペアリング可能
        self.doPairing = true
        // 選択中デバイス
        self.selectSerialNumber = Array(self.envSensorSerialNumberDic.keys)[indexPath.row]
        self.selectPeripheral = Array(self.envSensorSerialNumberDic.values)[indexPath.row]
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// セルの選択が外れた時に呼び出される
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at:indexPath)
        // チェックマークを外す
        cell?.accessoryType = .none
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    // ペアリング情報送信処理
    func sendPairingData(deviceName : String, deviceAddress : String, uuid : String, battery : String){
        // データ送信用JSON作成
        let rssi = self.bleService.GetRssi() ?? nil
        var rssiStr = ""
        if let rssiInt = rssi {
            rssiStr = String(rssiInt)
        }
        let json : Data?
        switch deviceName {
        case WeightScaleConst.DeviceName:
            json = self.measuringInstrumentService.CreatePairingDataJson(deviceId: WeightScaleConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: battery, rssi: rssiStr, sendDataType: DataCommunicationService.SendDataTypeOther.Pairing.rawValue, deviceType: DataCommunicationService.DeviceType.WeightScale.rawValue)
            break
        case BloodPressuresMonitorConst.DeviceName:
            json = self.measuringInstrumentService.CreatePairingDataJson(deviceId: BloodPressuresMonitorConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: battery, rssi: rssiStr, sendDataType: DataCommunicationService.SendDataTypeOther.Pairing.rawValue, deviceType: DataCommunicationService.DeviceType.BloodPressuresMonitor.rawValue)
            break
        case ThermometerConst.DeviceName:
            json = self.measuringInstrumentService.CreatePairingDataJson(deviceId: ThermometerConst.DeviceId, deviceAddress: deviceAddress, batteryLevel: battery, rssi: rssiStr, sendDataType: DataCommunicationService.SendDataTypeOther.Pairing.rawValue, deviceType: DataCommunicationService.DeviceType.Thermometer.rawValue)
            break
        case PulseOximeterConst.DeviceName:
            json = self.measuringInstrumentService.CreatePairingDataJson(deviceId: PulseOximeterConst.DeviceId, deviceAddress: uuid, batteryLevel: "", rssi: rssiStr, sendDataType: DataCommunicationService.SendDataTypePulseOximeter.Pairing.rawValue, deviceType: DataCommunicationService.DeviceType.PulseOximeter.rawValue)
            break
        default:
            json = nil
            break
        }
        ///ペアリング情報の送信
        if let jsonData = json {
            DataCommunicationService.postSendPairing(data: jsonData)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}

// MARK: - PickerView イベント関連
extension MeasuringInstrumentDetailViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    // ドラムロールの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 1
    }

    // ドラムロールの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.measuringIntervalArray.count
    }

    // ドラムロールの各タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.measuringIntervalArray[row]
    }

    // ドラムロール選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.measuringIntervalText.text = self.measuringIntervalArray[row]
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// PickerViewの完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        self.measuringIntervalText.endEditing(true)
        self.measuringIntervalText.text = "\(self.measuringIntervalArray[self.measuringIntervalPickerView.selectedRow(inComponent: 0)])"
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}

// MARK: - BLEサービス関連
extension MeasuringInstrumentDetailViewController : BleDelegate{
    /// BLE検出可能
    func blePowerOn(deviceName : String) {
        //CommonUtil.Print(className: self.className, message: "blePowerOn")
        
        if self.DeviceName == EnvSensorConst.DeviceName {
            // 環境センサー
            // BLEスキャン開始
            self.bleService.StartBleScan()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "blePowerOn")
    }
    
    /// デバイススキャン成功
    func successToScanDevice(peripheral : CBPeripheral, deviceName : String){
        
        if self.DeviceName == EnvSensorConst.DeviceName{
            // 環境センサー
            if self.isDeviceSettings || self.selectSerialNumber == ""{
                // 機器に接続
                self.bleService.ConnectPeripheral()
            }
        }
        else{
            if self.isDeviceSettings || self.isPairingNow{
                // 機器に接続
                self.bleService.ConnectPeripheral()
            }
        }
        if successToScanDeviceCount == 30{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
            successToScanDeviceCount = 0
        }else{
            successToScanDeviceCount += 1
        }
    }

    /// デバイス接続成功
    func successToDeviceConnect(peripheral : CBPeripheral, deviceName: String) {
        //CommonUtil.Print(className: self.className, message: "successToDeviceConnect")
        
        if self.DeviceName == EnvSensorConst.DeviceName {
            // 環境センサー
            if self.isPairingNow {
                // 測定機器設定中
                self.deviceSettings(isSettings: true)
                self.isDeviceSettings = true
                // シリアルナンバー設定
                self.serialNumberLabel.text = self.selectSerialNumber
                // UUID設定
                self.uuidLabel.text = peripheral.identifier.uuidString
            }
        }

        // 接続した機器名を保持
        self.deviceNamePairing = peripheral.name
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// デバイス接続失敗
    func failToDeviceConnect(deviceName: String) {
        //処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// デバイス接続切断
    func deviceDisconnect(deviceName: String) {
        //処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
        
    /// データ読み取り完了
    func complete(peripheral : CBPeripheral, deviceName : String, data: Data) {
        CommonUtil.Print(className: self.className, message: "complete")
        
        var bdAddress:String = ""
        var batteryLevel:String = ""
        
        /// 各サービス取得
        // デバイスインフォメーション
        let deviceInfoService = self.bleService.GetDeviceInfoService()
        // バッテリー
        let batteryService = self.bleService.GetBatteryService()
        // 書き込み
        let writeService = self.bleService.GetWriteService()
        
        if self.isDeviceSettings == false {
            if deviceName == EnvSensorConst.DeviceName {
                // 環境センサー
                let serialNumber = self.measuringInstrumentService.GetSerialNumber(data: data)
                self.serialNum = serialNumber
                
                if self.envSensorSerialNumberDic.keys.contains(serialNumber) == false {
                    self.envSensorSerialNumberDic.updateValue(peripheral, forKey: serialNumber)
                }

                // シリアルナンバー設定
                bdAddress = self.measuringInstrumentService.GetBDAddress(data: data)
                
                // 環境センサーはペアリング時にバッテリーを取得できないため空値
                batteryLevel = ""
                    
                self.tableView.reloadData()
                // デバイス切断
                self.bleService.DisconnectPeripheral()
                self.bleService.SetConnectPeripheral(peripheral: nil)
                // デバイススキャン開始
                self.bleService.StartBleScan()
            }
            else{
                // 測定機器設定中
                self.deviceSettings(isSettings: true)
                self.isDeviceSettings = true
                // シリアルナンバー設定
                if deviceName != PulseOximeterConst.DeviceName{
                    bdAddress  = self.measuringInstrumentService.GetBDAddress(data: data)
                    self.serialNumberLabel.text = bdAddress
                } else {
                    bdAddress = peripheral.identifier.uuidString
                }
                // バッテリーレベル取得
                batteryLevel = String(self.bleService.GetBatteryLevel())

                // UUID設定
                self.uuidLabel.text = peripheral.identifier.uuidString
                ///デバイスのペアリングをendにする
//                self.bleService = nil
            }
            // ペアリングデータ送信
            sendPairingData(deviceName: deviceName, deviceAddress: bdAddress, uuid: peripheral.identifier.uuidString, battery: batteryLevel)
        }
        // 必要なサービスの処理が全て終了している場合、機器との切断処理を行う
        if(deviceInfoService.isProcessPending == false
           && batteryService.isProcessPending == false
           && writeService.isProcessPending == false){
            
            // Top画面のデバイス接続
            self.connectTopViewDevice()
            
            // 接続を切断
            self.bleService.DisconnectPeripheral()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // Top画面のデバイス接続処理
    func connectTopViewDevice(){
        // Top画面を取得
        let topNc = self.parent as! UINavigationController
        let topVc = topNc.children[0] as! TopViewController
        
        // 設定情報保存
        self.setMeasuringInstrumentManage()
        
        // Topのデバイス接続処理
        switch self.DeviceName{
        case EnvSensorConst.DeviceName:
            // 環境センサ接続処理
            topVc.connectEnvSensor(manage: self.MeasuringInstrumentManage)
            break
        case WeightScaleConst.DeviceName:
            // 体重計接続処理
            topVc.connectWeightScale(manage: self.MeasuringInstrumentManage)
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 血圧計接続処理
            topVc.connectBloodPressuresMonitor(manage: self.MeasuringInstrumentManage)
            break
        case ThermometerConst.DeviceName:
            // 体温計接続処理
            topVc.connectThermometer(manage: self.MeasuringInstrumentManage)
            break
        case PulseOximeterConst.DeviceName:
            // パルスオキシメーター接続処理
            topVc.connectPulseOximeter(manage: self.MeasuringInstrumentManage)
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    // Top画面のデバイス切断処理
    func disConnectTopViewDevice(){
        // Top画面を取得
        let topNc = self.parent as! UINavigationController
        let topVc = topNc.children[0] as! TopViewController
        
        // 設定情報保存
        self.setMeasuringInstrumentManage()
        
        // Topのデバイス切断処理
        switch self.DeviceName{
        case EnvSensorConst.DeviceName:
            // 環境センサ切断処理
            topVc.disConnectEnvSensor()
            break
        case WeightScaleConst.DeviceName:
            // 体重計切断処理
            topVc.disConnectWeightScale()
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 血圧計切断処理
            topVc.disConnectBloodPressuresMonitor()
            break
        case ThermometerConst.DeviceName:
            // 体温計切断処理
            topVc.disConnectThermometer()
            break
        case PulseOximeterConst.DeviceName:
            // パルスオキシメーター切断処理
            topVc.disConnectPulseOximeter()
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // ペアリングスキャン用のUUIDを設定
    func setupUUID(){
        // サービスUUIDの初期化
        self.bleService.clearService()
        
        switch self.DeviceName{
        case EnvSensorConst.DeviceName:
            // 環境センサ
            // インフォメーションサービスの設定
            self.bleService.SetDeviceInfoService(
                serviceUUID       : CBUUID(string : EnvSensorConst.BleService.DeviceInformationService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: EnvSensorConst.BleService.DeviceInformationService.Characteristic.SerialNumberString.kUUID)]
                , properties        :BleService.Properties.Read.rawValue
            )
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case WeightScaleConst.DeviceName:
            // 体重計
            // バッテリーサービスの設定
            self.bleService.SetBatteryService(
                serviceUUID         : CBUUID(string : WeightScaleConst.BleService.BatteryService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
                , properties        :BleService.Properties.Read.rawValue)
            // インフォメーションサービスの設定
            self.bleService.SetDeviceInfoService(
                serviceUUID       : CBUUID(string : WeightScaleConst.BleService.DeviceInformationService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.DeviceInformationService.Characteristic.SystemId.kUUID)]
                , properties        :BleService.Properties.Read.rawValue
            )
            // 書き込みサービスの設定
            self.bleService.SetWriteService(
                serviceUUID       : CBUUID(string : WeightScaleConst.BleService.WeightScaleService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: WeightScaleConst.BleService.WeightScaleService.Characteristic.DateTime.kUUID)]
                , properties        :BleService.Properties.Write.rawValue)
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case BloodPressuresMonitorConst.DeviceName:
            // 血圧計
            // バッテリーサービスの設定
            self.bleService.SetBatteryService(
                serviceUUID         : CBUUID(string : BloodPressuresMonitorConst.BleService.BatteryService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
                , properties        :BleService.Properties.Read.rawValue)
            // インフォメーションサービスの設定
            self.bleService.SetDeviceInfoService(
                serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.DeviceInformationService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.DeviceInformationService.Characteristic.SystemId.kUUID)]
                , properties        :BleService.Properties.Read.rawValue
            )
            // 書き込みサービスの設定
            self.bleService.SetWriteService(
                serviceUUID       : CBUUID(string : BloodPressuresMonitorConst.BleService.BloodPressure.Service.kUUID)
                , characteristicUUID: [CBUUID(string: BloodPressuresMonitorConst.BleService.BloodPressure.Characteristic.DateTime.kUUID)]
                , properties        :BleService.Properties.Write.rawValue)
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case ThermometerConst.DeviceName:
            // 体温計
            // バッテリーサービスの設定
            self.bleService.SetBatteryService(
                serviceUUID         : CBUUID(string : ThermometerConst.BleService.BatteryService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.BatteryService.Characteristic.BatteryLevel.kUUID)]
                , properties        :BleService.Properties.Read.rawValue)
            // インフォメーションサービスの設定
            self.bleService.SetDeviceInfoService(
                serviceUUID       : CBUUID(string : ThermometerConst.BleService.DeviceInformationService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.DeviceInformationService.Characteristic.SystemId.kUUID)]
                , properties        :BleService.Properties.Read.rawValue
            )
            // 書き込みサービスの設定
            self.bleService.SetWriteService(
                serviceUUID       : CBUUID(string : ThermometerConst.BleService.ThermometerService.Service.kUUID)
                , characteristicUUID: [CBUUID(string: ThermometerConst.BleService.ThermometerService.Characteristic.DateTime.kUUID)]
                , properties        :BleService.Properties.Write.rawValue
            )
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        case PulseOximeterConst.DeviceName:
            // パルスオキシメータ
            // インフォメーションサービスの設定
            self.bleService.SetDeviceInfoService(
                serviceUUID       : CBUUID(string : PulseOximeterConst.BleService.PulseOximeter.Service.kUUID)
                , characteristicUUID: [CBUUID(string: PulseOximeterConst.BleService.PulseOximeter.Characteristic.kUUID)]
                , properties        :BleService.Properties.Read.rawValue
            )
            // 書き込みサービスreturnフラグの設定
            self.bleService.SetWriteServiceReturnFlg(writeServiceReturnFlg: false)
            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
