//
// WatchSettingCRPSmartBandViewController.swift
// ウォッチCRPSmartBand設定
//
// MBTLink
//

import UIKit
import CRPSmartBand

class WatchSettingCRPSmartBandViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    // MARK: - UI部品
    /// 状態
    @IBOutlet weak var statusLabel: UILabel!
    /// デバイススキャンTableView
    @IBOutlet weak var deviceScanTableView: UITableView!
    /// ペアリングボタン
    @IBOutlet weak var pairingButton: UIButton!
    /// インジケーター
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    /// ウォッチ設定コンテナView
    @IBOutlet weak var watchSettingContainerView: UIView!
    
    // MARK: - Public変数
    /// CRPSmartBand管理サービス
    public var WatchManageService : CRPSmartBandManageService!
    /// CRPSmartBand管理辞書
    public var WatchManageDic : [String : CRPSmartBandManageService]!
    // MARK: - Private変数
    /// メソッド実行カウント
    private var successToScanWatchCount : Int = 30
    /// クラス名
    private let className = String(String(describing: ( WatchSettingCRPSmartBandViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    /// ウォッチサービス
    private var watchService = WatchService()
    /// ウォッチ設定中かどうか
    private var isWatchSettings : Bool = false
    /// ウォッチ辞書
    private var watchDic : [String:CRPDiscovery] = [:]
    /// ペアリング可否
    private var doPairing : Bool = false
    /// ウォッチ設定TableView
    private var watchSettingTvc : WatchSettingCRPSmartBandTableViewController!
    /// 選択中のデバイス名
    private var selectDeviceNameKey : String? = ""
    /// 選択中のDiscovery
    private var selectDiscovery : CRPDiscovery?
    /// CRPSmartbandサービス
    private let crpSmartbandService = CRPSmartBandService()
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // back -> 戻るに変更
        let backbutton = UIBarButtonItem()
        backbutton.title = StringsConst.BACK
        navigationItem.backBarButtonItem = backbutton
        
        //ウォッチ設定TableView
        self.watchSettingTvc = (self.children[0] as! WatchSettingCRPSmartBandTableViewController)
        
        self.isWatchSettings = self.WatchManageService.WatchSettingInfo.IsWatchSettings
        // ウォッチ設定中or未設定
        self.watchSettings(isSettings: self.isWatchSettings)
        // デリゲート設定
        self.deviceScanTableView.delegate = self
        self.deviceScanTableView.dataSource = self
        // BLE接続のセットアップ
        self.WatchManageService.WatchBleService.SetupBluetoothService()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //CommonUtil.Print(className: self.className, message: "viewWillAppear表示")
        
        // デリゲート設定
        self.WatchManageService.WatchBleService.delegate = self
        // インジケーター開始
        self.indicator.startAnimating()
        
        if self.isWatchSettings == false{
            //ウォッチ スキャンデバイスタイマーStart
            self.WatchManageService.StartWatchScanDeviceTimer()
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // タイマーを停止する
        self.WatchManageService.StopWatchScanDeviceTimer()
        // インジケーター終了
        self.indicator.stopAnimating()
        
        if self.isWatchSettings{
            // 設定情報保存
            let name = self.watchSettingTvc.GetDeviceName()
            let macAddress = self.watchSettingTvc.GetMacAddress()
            let deviceNameKey = "\(name) \(macAddress)"
    
            // ウォッチ設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsWatchSettings = self.isWatchSettings
            // デバイス名
            self.WatchManageService.WatchSettingInfo.WatchDeviceName = name
            // MACアドレス
            self.WatchManageService.WatchSettingInfo.WatchMacAddress = macAddress
            // 電話が通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsCallNotificationSettings = self.watchSettingTvc.GetCallNotificationSetting()
            // SMSが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsSmsNotificationSettings = self.watchSettingTvc.GetSmsNotificationSetting()
            // LINEが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsLineNotificationSettings = self.watchSettingTvc.GetLineNotificationSetting()
            // qqが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsQqNotificationSettings = self.watchSettingTvc.GetQqNotificationSetting()
            // weChatが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsWeChatNotificationSettings = self.watchSettingTvc.GetWeChatNotificationSetting()
            // faceBookが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsFaceBookNotificationSettings = self.watchSettingTvc.GetFaceBookNotificationSetting()
            // twitterが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsTwitterNotificationSettings = self.watchSettingTvc.GetTwitterNotificationSetting()
            // skypeが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsSkypeNotificationSettings = self.watchSettingTvc.GetSkypeNotificationSetting()
            // instagramが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsInstagramNotificationSettings = self.watchSettingTvc.GetInstagramNotificationSetting()
            // whatsAppが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsWhatsAppNotificationSettings = self.watchSettingTvc.GetWhatsAppNotificationSetting()
            // kakaoTalkが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsKakaoTalkNotificationSettings = self.watchSettingTvc.GetKakaoTalkNotificationSetting()
            // gmailが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsGmailNotificationSettings = self.watchSettingTvc.GetGmailNotificationSetting()
            // messengerが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsMessengerNotificationSettings = self.watchSettingTvc.GetMessengerNotificationSetting()
            // othersが通知設定中かどうか
            self.WatchManageService.WatchSettingInfo.IsOthersNotificationSettings = self.watchSettingTvc.GetOthersNotificationSetting()
            // 血圧測定するかどうか
            self.WatchManageService.WatchSettingInfo.BloodPressureMeasure = self.watchSettingTvc.GetBloodPressureMeasure()
            // SpO2測定するかどうか
            self.WatchManageService.WatchSettingInfo.SpO2Measure = self.watchSettingTvc.GetSpO2Measure()
            // 自動計測 計測時間
            self.WatchManageService.WatchSettingInfo.MeasurementInterval = self.watchSettingTvc.GetMeasurementInterval()
            // 歩数計測 送信時間
            self.WatchManageService.WatchSettingInfo.StepSendInterval = self.watchSettingTvc.GetStepSendInterval()
            // 歩幅
            self.WatchManageService.WatchSettingInfo.StepLength = self.watchSettingTvc.GetStepLength()
            // 設定情報登録
            self.WatchManageService.SaveWatchSettingData(deviceNameKey: deviceNameKey)
        }
    
        // 遷移元に値を戻す
        let preNc = self.parent as! UINavigationController
        let preVc = preNc.children[1] as! WatchSettingManageViewController
        preVc.CRPSmartBandManageDic = self.WatchManageDic
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //タッチが始まった場合
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // ビュー階層内のファーストレスポンダを探索して resignFirstResponder() を呼ぶ
        self.view.endEditing(true)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.ACTION , className: self.className , functionName: #function , message: "")
    }
    /// ペアリング開始ボタン押下
    @IBAction func clickPairingButton(_ sender: Any) {
        
        var message : String = ""
        
        if self.isWatchSettings{
            //ウォッチ設定中
            //アラート生成
            //UIAlertControllerのスタイルがalert
            message.append(StringsConst.WATCH_UNPAIR_MESSAGE_A)
            message.append("\n")
            message.append(StringsConst.WATCH_UNPAIR_MESSAGE_B)

            let alert: UIAlertController = UIAlertController(title: StringsConst.UNPAIR_MESSAGE, message:  message, preferredStyle:  UIAlertController.Style.alert)
        
            // 解除ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: StringsConst.UNPAIR, style: UIAlertAction.Style.default, handler:{
                // 解除ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                    CommonUtil.Print(className: self.className, message: "解除")
                
                    let name : String = self.watchSettingTvc.GetDeviceName()
                    let macAddress : String = self.watchSettingTvc.GetMacAddress()
                    let deviceNameKey = "\(name) \(macAddress)"
                
                    // ウォッチ管理辞書からデバイス削除
                    self.WatchManageDic.removeValue(forKey:deviceNameKey)
                    // デバイス登録解除
                    self.WatchManageService.WatchBleService.UnbindDevice()
                    // 設定デバイス削除
                    self.WatchManageService.RemoveWatchSettingData()
                    self.WatchManageService.WatchBleService.ResetFirmwareVersion()
                    // ウォッチ未設定
                    self.watchSettings(isSettings: false)
                    self.saveWatchSettingViewData()
                    self.deviceScanTableView.reloadData()
                
                    // UserDefaultsにペアリング情報を設定
                    self.setUserDefaults()
                
                    //ウォッチ スキャンデバイスタイマーStart
                    self.WatchManageService.StartWatchScanDeviceTimer()
                    ///ウォッチペアリング情報の送信
                    // データ送信用JSON作成
                    let firmwareVersion = self.WatchManageService.WatchBleService.GetFirmwareVersion()
                    let json = self.crpSmartbandService.CreatePairingSendDataJson(firmwareVersion: firmwareVersion,  deviceId: name, deviceAddress: "", sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Pairing.rawValue)
                    DataCommunicationService.postSendPairing(data: json)
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
            // ウォッチ未設定
            if self.doPairing {
                //アラート生成
                //UIAlertControllerのスタイルがalert
                let deviceName : String? = self.selectDeviceNameKey
                if StringsConst.LANGUAGE == "日本語"{
                    let messagetext = String(StringsConst.PAIR_MESSAGE)
                    message  = (deviceName ?? "") + messagetext
                }else if StringsConst.LANGUAGE == "English"{
                    let messagetext = String(StringsConst.PAIR_MESSAGE)
                    message  = messagetext + (deviceName ?? "") + StringsConst.QUESTION_MARK
                }
                let alert: UIAlertController = UIAlertController(title: StringsConst.CONFIRM, message:  message, preferredStyle:  UIAlertController.Style.alert)
            
                // OKボタンの処理
                let confirmAction: UIAlertAction = UIAlertAction(title: StringsConst.OK, style: UIAlertAction.Style.default, handler:{
                    // OKボタンが押された時の処理をクロージャ実装する
                    (action: UIAlertAction!) -> Void in
                        CommonUtil.Print(className: self.className, message: "OK")
                    
                        // ウォッチ管理辞書にデバイス追加
                        self.WatchManageDic.updateValue(self.WatchManageService, forKey: self.selectDeviceNameKey!)
                        // 機器に接続
                        self.WatchManageService.WatchBleService.SetDeviceName(value: self.selectDiscovery?.localName)
                        self.WatchManageService.WatchBleService.SetMacAddress(value: self.selectDiscovery?.mac)
                        self.WatchManageService.WatchBleService.SetConnectDiscovery(discovery: self.selectDiscovery)
                        self.WatchManageService.WatchBleService.ConnectDiscovery()
                        self.WatchManageService.WatchBleService.IsWatchSetting(bool: true)
                        
                        // UserDefaultsにペアリンング情報を設定
                        self.setUserDefaults()
/*
                        ///ウォッチペアリング情報の送信
                        let deviceName = self.WatchManageService.WatchBleService.GetDeviceName() ?? ""
                        let macAddress = self.WatchManageService.WatchBleService.GetMacAddress() ?? ""
                    let firmwareVersion = self.WatchManageService.WatchBleService.GetFirmwareVersion()
                    print(firmwareVersion)
                        // データ送信用JSON作成
                        let json = self.crpSmartbandService.CreatePairingSendDataJson(deviceId: deviceName, deviceAddress: macAddress, sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Pairing.rawValue)
                        DataCommunicationService.postSendPairing(data: json)
 */
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
    
    // MARK: - Private Methods
    /// ウォッチ設定
    private func watchSettings(isSettings : Bool){
        if isSettings{
            //設定中
            self.statusLabel.text = StringsConst.CONFIGURED
            self.pairingButton.setTitle(StringsConst.UNPAIRING, for: .normal)
            
            // デバイススキャンTableView 非表示
            self.deviceScanTableView.isHidden = true
            // ウォッチ設定TableView 表示
            self.watchSettingContainerView.isHidden = false
            
            // ウォッチ設定TableView 設定
            // デバイス名
            self.watchSettingTvc.SetDeviceName(value: self.WatchManageService.WatchSettingInfo.WatchDeviceName)
            // MACアドレス
            self.watchSettingTvc.SetMacAddress(value: self.WatchManageService.WatchSettingInfo.WatchMacAddress)
            // 通知設定・通話
            self.watchSettingTvc.SetCallNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsCallNotificationSettings)
            // 通知設定・SMS
            self.watchSettingTvc.SetSmsNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsSmsNotificationSettings)
            // 通知設定・LINE
            self.watchSettingTvc.SetLineNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsLineNotificationSettings)
            // 通知設定・qq
            self.watchSettingTvc.SetQqNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsQqNotificationSettings)
            // 通知設定・weChat
            self.watchSettingTvc.SetWeChatNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsWeChatNotificationSettings)
            // 通知設定・faceBook
            self.watchSettingTvc.SetFaceBookNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsFaceBookNotificationSettings)
            // 通知設定・twitter
            self.watchSettingTvc.SetTwitterNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsTwitterNotificationSettings)
            // 通知設定・skype
            self.watchSettingTvc.SetSkypeNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsSkypeNotificationSettings)
            // 通知設定・instagram
            self.watchSettingTvc.SetInstagramNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsInstagramNotificationSettings)
            // 通知設定・whatsApp
            self.watchSettingTvc.SetWhatsAppNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsWhatsAppNotificationSettings)
            // 通知設定・kakaoTalk
            self.watchSettingTvc.SetKakaoTalkNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsKakaoTalkNotificationSettings)
            // 通知設定・gmail
            self.watchSettingTvc.SetGmailNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsGmailNotificationSettings)
            // 通知設定・messenger
            self.watchSettingTvc.SetMessengerNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsMessengerNotificationSettings)
            // 通知設定・others
            self.watchSettingTvc.SetOthersNotificationSetting(value: self.WatchManageService.WatchSettingInfo.IsOthersNotificationSettings)
            // 血圧測定するかどうか
            self.watchSettingTvc.SetBloodPressureMeasure(value: self.WatchManageService.WatchSettingInfo.BloodPressureMeasure)
            // SpO2測定するかどうか
            self.watchSettingTvc.SetSpO2Measure(value: self.WatchManageService.WatchSettingInfo.SpO2Measure)
            // 自動測定 測定間隔
            self.watchSettingTvc.SetMeasurementInterval(value: self.WatchManageService.WatchSettingInfo.MeasurementInterval)
            // 歩数測定 送信間隔
            self.watchSettingTvc.SetStepSendInterval(value: self.WatchManageService.WatchSettingInfo.StepSendInterval)
            // 歩幅
            self.watchSettingTvc.SetStepLength(value: self.WatchManageService.WatchSettingInfo.StepLength)
        }
        else{
            //未設定
            self.statusLabel.text = StringsConst.NOT_CONNECTED
            self.pairingButton.setTitle(StringsConst.START_PAIRING, for: .normal)
            
            // デバイススキャンTableView 表示
            self.deviceScanTableView.isHidden = false
            // ウォッチ設定TableView 非表示
            self.watchSettingContainerView.isHidden = true
            // ウォッチArray初期化
            self.watchDic.removeAll()
            // ウォッチ設定TableView 初期化
            // デバイス名
            self.watchSettingTvc.SetDeviceName(value: "")
            // MACアドレス
            self.watchSettingTvc.SetMacAddress(value: "")
            // 通知設定・通話
            self.watchSettingTvc.SetCallNotificationSetting(value: false)
            // 通知設定・SMS
            self.watchSettingTvc.SetSmsNotificationSetting(value: false)
            // 通知設定・LINE
            self.watchSettingTvc.SetLineNotificationSetting(value: false)
            // 通知設定・qq
            self.watchSettingTvc.SetQqNotificationSetting(value: false)
            // 通知設定・weChat
            self.watchSettingTvc.SetWeChatNotificationSetting(value: false)
            // 通知設定・faceBook
            self.watchSettingTvc.SetFaceBookNotificationSetting(value: false)
            // 通知設定・twitter
            self.watchSettingTvc.SetTwitterNotificationSetting(value: false)
            // 通知設定・skype
            self.watchSettingTvc.SetSkypeNotificationSetting(value: false)
            // 通知設定・instagram
            self.watchSettingTvc.SetInstagramNotificationSetting(value: false)
            // 通知設定・whatsApp
            self.watchSettingTvc.SetWhatsAppNotificationSetting(value: false)
            // 通知設定・kakaoTalk
            self.watchSettingTvc.SetKakaoTalkNotificationSetting(value: false)
            // 通知設定・gmail
            self.watchSettingTvc.SetGmailNotificationSetting(value: false)
            // 通知設定・messenger
            self.watchSettingTvc.SetMessengerNotificationSetting(value: false)
            // 通知設定・others
            self.watchSettingTvc.SetOthersNotificationSetting(value: false)
            // 血圧測定するかどうか
            self.watchSettingTvc.SetBloodPressureMeasure(value: true)
            // SpO2測定するかどうか
            self.watchSettingTvc.SetSpO2Measure(value: true)
            // 自動測定 測定間隔
            self.watchSettingTvc.SetMeasurementInterval(value: 5)
            // 歩数測定 送信間隔
            self.watchSettingTvc.SetStepSendInterval(value: 5)
            // 歩幅
            self.watchSettingTvc.SetStepLength(value: 70)
            
            // ウォッチ未設定
            self.isWatchSettings = false
            // ペアリング可否
            self.doPairing = false
            // 選択中のデバイス
            self.selectDeviceNameKey = ""
            self.selectDiscovery = nil
        }
        self.watchSettingTvc.picker()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// アラートメッセージ表示自動クローズ
    private func showAlertAutoClose(title : String, message : String, closeTime : Double) {
        // アラート作成
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
             
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + closeTime, execute: {
                    alert.dismiss(animated: true, completion: nil)
            })
        })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // ペアリング情報をUserDefaultsへ書き込み
    func setUserDefaults(){
        let preNc = self.parent as! UINavigationController
        let preVc = preNc.children[1] as! WatchSettingManageViewController
        // 前画面(ウォッチ管理画面）に管理中のウォッチ情報を渡す
        preVc.CRPSmartBandManageDic = self.WatchManageDic
        // 書き込み
        preVc.saveWatchSettingData()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // 画面の設定情報をUserDefaultsへ書き込み
    func saveWatchSettingViewData(){
        // 設定情報保存
        let name = self.watchSettingTvc.GetDeviceName()
        let macAddress = self.watchSettingTvc.GetMacAddress()
        let deviceNameKey = "\(name) \(macAddress)"

        // ウォッチ設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsWatchSettings = self.isWatchSettings
        // デバイス名
        self.WatchManageService.WatchSettingInfo.WatchDeviceName = name
        // MACアドレス
        self.WatchManageService.WatchSettingInfo.WatchMacAddress = macAddress
        // 電話が通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsCallNotificationSettings = self.watchSettingTvc.GetCallNotificationSetting()
        // SMSが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsSmsNotificationSettings = self.watchSettingTvc.GetSmsNotificationSetting()
        // LINEが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsLineNotificationSettings = self.watchSettingTvc.GetLineNotificationSetting()
        // qqが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsQqNotificationSettings = self.watchSettingTvc.GetQqNotificationSetting()
        // weChatが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsWeChatNotificationSettings = self.watchSettingTvc.GetWeChatNotificationSetting()
        // faceBookが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsFaceBookNotificationSettings = self.watchSettingTvc.GetFaceBookNotificationSetting()
        // twitterが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsTwitterNotificationSettings = self.watchSettingTvc.GetTwitterNotificationSetting()
        // skypeが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsSkypeNotificationSettings = self.watchSettingTvc.GetSkypeNotificationSetting()
        // instagramが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsInstagramNotificationSettings = self.watchSettingTvc.GetInstagramNotificationSetting()
        // whatsAppが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsWhatsAppNotificationSettings = self.watchSettingTvc.GetWhatsAppNotificationSetting()
        // kakaoTalkが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsKakaoTalkNotificationSettings = self.watchSettingTvc.GetKakaoTalkNotificationSetting()
        // gmailが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsGmailNotificationSettings = self.watchSettingTvc.GetGmailNotificationSetting()
        // messengerが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsMessengerNotificationSettings = self.watchSettingTvc.GetMessengerNotificationSetting()
        // othersが通知設定中かどうか
        self.WatchManageService.WatchSettingInfo.IsOthersNotificationSettings = self.watchSettingTvc.GetOthersNotificationSetting()
        // 血圧測定するかどうか
        self.WatchManageService.WatchSettingInfo.BloodPressureMeasure = self.watchSettingTvc.GetBloodPressureMeasure()
        // SpO2測定するかどうか
        self.WatchManageService.WatchSettingInfo.SpO2Measure = self.watchSettingTvc.GetSpO2Measure()
        
        // 自動計測 計測時間
        self.WatchManageService.WatchSettingInfo.MeasurementInterval = self.watchSettingTvc.GetMeasurementInterval()
        // 歩数計測 送信時間
        self.WatchManageService.WatchSettingInfo.StepSendInterval = self.watchSettingTvc.GetStepSendInterval()
        // 歩幅
        self.WatchManageService.WatchSettingInfo.StepLength = self.watchSettingTvc.GetStepLength()
        // 設定情報登録
        self.WatchManageService.SaveWatchSettingData(deviceNameKey: deviceNameKey)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Table view イベント関連
    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.watchDic.count
    }
    
    /// 各セルを生成して返却します。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = Array(self.watchDic.keys)[indexPath.row]
        cell.detailTextLabel?.text = ""
        
        if cell.textLabel!.text!.contains(self.selectDeviceNameKey!) {
            // 選択済みの場合
            // チェックマークを入れる
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
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
        self.selectDeviceNameKey = Array(self.watchDic.keys)[indexPath.row]
        self.selectDiscovery = Array(self.watchDic.values)[indexPath.row]
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
}

// MARK: - CRPSmartBandBleサービス関連
extension WatchSettingCRPSmartBandViewController : CRPSmartBandBleDelegate{
    /// BLE検出可能
    func blePowerOn() {
        //CommonUtil.Print(className: self.className, message: "blePowerOn")
        //ウォッチ スキャンデバイスタイマーStart
        //self.WatchManageService.StartWatchScanDeviceTimer()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "blePowerOn")
    }
    /// ウォッチスキャン成功
    func successToScanWatch(deviceNameKey : String?, discoverys: [CRPDiscovery]) {
        //CommonUtil.Print(className: self.className, message: "successToScanWatch")
        
        for discovery in discoverys{
            
            if let name = discovery.localName, let macAddress = discovery.mac{
                
                let discoveryDeviceNameKey = "\(name) \(macAddress)"
                
                if name.contains(WatchConst.WatchDeviceName.CRPSmartBand), !(macAddress.isEmpty) {
                
                    if self.isWatchSettings {
                        //ウォッチ設定中
                        if let watchSettingsDeviceName = self.WatchManageService.WatchSettingInfo.WatchDeviceName,
                           let watchSettingsMacAddress = self.WatchManageService.WatchSettingInfo.WatchMacAddress{
                            
                            let watchSettingsDeviceNameKey = "\(watchSettingsDeviceName) \(watchSettingsMacAddress)"
                            
                            if discoveryDeviceNameKey == watchSettingsDeviceNameKey{
                                self.WatchManageService.WatchBleService.SetConnectDiscovery(discovery: discovery)
                                self.WatchManageService.WatchBleService.ConnectDiscovery()
                                
                                return
                            }
                        }
                    }
                    
                    if self.WatchManageDic.keys.contains(discoveryDeviceNameKey) == false{
                        if self.watchDic.keys.contains(discoveryDeviceNameKey) == false{
                            self.watchDic[discoveryDeviceNameKey] = discovery
                            self.deviceScanTableView.reloadData()
                        }
                    }
                }
            }
        }
        self.isWatchSettings = false
        if successToScanWatchCount == 30{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "successToScanWatch")
            successToScanWatchCount = 0
        }else{
            successToScanWatchCount += 1
        }
    }
    /// ウォッチ接続成功
    func successToWatchConnect(discovery : CRPDiscovery){
        //CommonUtil.Print(className: self.className, message: "successToWatchConnect")
        
        let name :String = discovery.localName!
        let macAddress : String = discovery.mac!
            
        // ウォッチスキャンデバイスタイマ停止する
        self.WatchManageService.StopWatchScanDeviceTimer()
        // ウォッチ設定中
        self.watchSettings(isSettings: true)
        self.isWatchSettings = true
        // デバイス名設定
        self.watchSettingTvc.SetDeviceName(value:name)
        // デバイスのMACアドレス設定
        self.watchSettingTvc.SetMacAddress(value: macAddress)
        // ウォッチの時刻合わせ
        self.WatchManageService.WatchBleService.setRealTime()
        // ウォッチ言語設定
        self.WatchManageService.WatchBleService.setLanguage(lang: WatchConst.H76DeviceLanguage.JP)
        // 歩幅設定
        self.WatchManageService.WatchBleService.setStepLength(length:self.WatchManageService.WatchSettingInfo.StepLength)
        // 24時間心拍数データ記録間隔設定(5分)
        self.WatchManageService.WatchBleService.set24HeartRateInterval(interval: 1)
        // ファームウェアバージョン取得
        self.WatchManageService.WatchBleService.GetFirmware()
        //　ファームウェアバージョン取得待ち
        DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + 3) {
        ///ウォッチペアリング情報の送信
        let deviceName = self.WatchManageService.WatchBleService.GetDeviceName() ?? ""
        let macAddressa = self.WatchManageService.WatchBleService.GetMacAddress() ?? ""
        let firmwareVersion = self.WatchManageService.WatchBleService.GetFirmwareVersion()
        // データ送信用JSON作成
            let json = self.crpSmartbandService.CreatePairingSendDataJson(firmwareVersion: firmwareVersion, deviceId: deviceName, deviceAddress: macAddressa, sendDataType: DataCommunicationService.SendDataTypeSmartWatch.Pairing.rawValue)
        DataCommunicationService.postSendPairing(data: json)
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "successToWatchConnect")
    }
    
    /// 心拍数データ取得完了
    func getHeartRateDataComplete(deviceNameKey : String, heartRate: Int){
        // 処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 血圧データ取得完了
    func getBloodDataComplete(deviceNameKey : String, heartRate: Int, sbp: Int, dbp: Int){
        // 処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// SPO2データ取得完了
    func getSpo2DataComplete(deviceNameKey : String, o2: Int){
        // 処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 取得サイクル完了
    func getDataCycleComplete(deviceNameKey: String) {
        // 処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
