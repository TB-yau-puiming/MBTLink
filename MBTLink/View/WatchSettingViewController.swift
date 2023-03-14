//
// WatchSettingViewController.swift
// ウォッチ設定
//
// MBTLink
//

import UIKit
import CRPSmartBand

class WatchSettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
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
    // LANCEBAND2,3関連
    /// LANCEBAND2,3管理サービス
    public var WatchManageService : WatchManageService!
    /// LANCEBAND2,3管理辞書
    public var WatchManageDic : [String : WatchManageService]!
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( WatchSettingViewController.self)).split(separator: "-")[0])
    /// ウォッチサービス
    private var watchService = WatchService()
    /// ウォッチ設定中かどうか
    private var isWatchSettings : Bool = false
    /// ウォッチ辞書
    private var watchDic : [String:CBPeripheral] = [:]
    /// ペアリング可否
    private var doPairing : Bool = false
    /// ウォッチ設定TableView
    private var watchSettingTvc : WatchSettingTableViewController!
    /// 選択中のデバイス名
    private var selectDeviceName : String? = ""
    /// 選択中のペリフェラル
    private var selectPeripheral : CBPeripheral?
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // back -> 戻るに変更
        let backbutton = UIBarButtonItem()
        backbutton.title = StringsConst.BACK
        navigationItem.backBarButtonItem = backbutton
        
        //ウォッチ設定TableView
        self.watchSettingTvc = (self.children[0] as! WatchSettingTableViewController)
        
        self.isWatchSettings = self.WatchManageService.WatchSettingInfo.IsWatchSettings
        // ウォッチ設定中or未設定
        self.watchSettings(isSettings: self.isWatchSettings)
        // デリゲート設定
        self.deviceScanTableView.delegate = self
        self.deviceScanTableView.dataSource = self
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CommonUtil.Print(className: self.className, message: "viewWillAppear表示")
        
        // デリゲート設定
        self.WatchManageService.WatchBleService.delegate = self
        // インジケーター開始
        self.indicator.startAnimating()
        //ウォッチ スキャンデバイスタイマーStart
        self.WatchManageService.StartWatchScanDeviceTimer()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // タイマーを停止する
        self.WatchManageService.StopWatchScanDeviceTimer()
        self.WatchManageService.StopGetMacAddressTimer()
        //self.CRPSmartBandManageService.StopWatchScanDeviceTimer()
        // インジケーター終了
        self.indicator.stopAnimating()
        
        if self.isWatchSettings{
            // 設定情報保存
                // ウォッチ設定中かどうか
                self.WatchManageService.WatchSettingInfo.IsWatchSettings = self.isWatchSettings
                // デバイス名
                self.WatchManageService.WatchSettingInfo.WatchDeviceName = self.watchSettingTvc.GetDeviceName()
                // MACアドレス
                self.WatchManageService.WatchSettingInfo.WatchMacAddress = self.watchSettingTvc.GetMacAddress()
                // 電話が通知設定中かどうか
                self.WatchManageService.WatchSettingInfo.IsCallNotificationSettings = self.watchSettingTvc.GetCallNotificationSetting()
                // SMSが通知設定中かどうか
                self.WatchManageService.WatchSettingInfo.IsSmsNotificationSettings = self.watchSettingTvc.GetSmsNotificationSetting()
                // LINEが通知設定中かどうか
                self.WatchManageService.WatchSettingInfo.IsLineNotificationSettings = self.watchSettingTvc.GetLineNotificationSetting()
                // 自動計測 計測時間
                self.WatchManageService.WatchSettingInfo.MeasurementInterval = self.watchSettingTvc.GetMeasurementInterval()
            // 設定情報登録
            self.WatchManageService.SaveWatchSettingData(deviceNameKey: self.watchSettingTvc.GetDeviceName())
        }
        
        // 遷移元に値を戻す
        let preNc = self.parent as! UINavigationController
        let preVc = preNc.children[1] as! WatchSettingManageViewController
        preVc.WatchManageDic = self.WatchManageDic
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //タッチが始まった場合
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // ビュー階層内のファーストレスポンダを探索して resignFirstResponder() を呼ぶ
        self.view.endEditing(true)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// ペアリング開始ボタン押下
    @IBAction func clickPairingButton(_ sender: Any) {
        
        var message : String = ""
        
        if self.isWatchSettings{
            //ウォッチ設定中
            //アラート生成
            //UIAlertControllerのスタイルがalert
            message.append("ペアリング情報がアプリから削除されますが、iOSの設定に残る場合があります。")
            message.append("\n")
            message.append("「設定」-「Bluetooth」を開き「自分のデバイス」に削除済みのデバイスが表示されている場合は、iアイコンをタップしデバイスの登録を解除するか、Bluetooth機能を一度無効にし再度有効にしてください。")

            let alert: UIAlertController = UIAlertController(title: "ペアリングを解除しますか？", message:  message, preferredStyle:  UIAlertController.Style.alert)
        
            // 解除ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "解除", style: UIAlertAction.Style.default, handler:{
                // 解除ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                    CommonUtil.Print(className: self.className, message: "解除")
                
                    let deviceName : String = self.watchSettingTvc.GetDeviceName()
                
                    // ウォッチ管理辞書からデバイス削除
                    self.WatchManageDic.removeValue(forKey:deviceName)
                    // デバイス登録解除
                    self.WatchManageService.WatchBleService.UnbindDevice()
                    // 設定デバイス削除
                    self.WatchManageService.RemoveWatchSettingData()
                    // ウォッチ未設定
                    self.watchSettings(isSettings: false)
                    self.deviceScanTableView.reloadData()
                    //ウォッチ スキャンデバイスタイマーStart
                    self.WatchManageService.StartWatchScanDeviceTimer()
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
        }
        else{
            // ウォッチ未設定
            if self.doPairing {
                //アラート生成
                //UIAlertControllerのスタイルがalert
                let deviceName : String? = self.selectDeviceName
                message  = "\(deviceName ?? "") とペアリングしてよろしいですか？"
                let alert: UIAlertController = UIAlertController(title: "確認", message:  message, preferredStyle:  UIAlertController.Style.alert)
            
                // OKボタンの処理
                let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    // OKボタンが押された時の処理をクロージャ実装する
                    (action: UIAlertAction!) -> Void in
                        CommonUtil.Print(className: self.className, message: "OK")
                    
                        // ウォッチ管理辞書にデバイス追加
                        self.WatchManageDic.updateValue(self.WatchManageService, forKey: self.selectDeviceName!)
                        // 機器に接続
                        self.WatchManageService.WatchBleService.SetDeviceName(value: self.selectDeviceName)
                        self.WatchManageService.WatchBleService.SetConnectPeripheral(peripheral: self.selectPeripheral)
                        self.WatchManageService.WatchBleService.ConnectPeripheral()
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
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Private Methods
    /// ウォッチ設定
    private func watchSettings(isSettings : Bool){
        if isSettings{
            //設定中
            self.statusLabel.text = "設定済み"
            self.pairingButton.setTitle("ペアリング解除", for: .normal)
            
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
            // 自動測定 測定間隔
            self.watchSettingTvc.SetMeasurementInterval(value: self.WatchManageService.WatchSettingInfo.MeasurementInterval)
        }
        else{
            //未設定
            self.statusLabel.text = "未接続"
            self.pairingButton.setTitle("ペアリング開始", for: .normal)
            
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
                // 自動測定 測定間隔
                self.watchSettingTvc.SetMeasurementInterval(value: 1)
            // ウォッチ未設定
            self.isWatchSettings = false
            // ペアリング可否
            self.doPairing = false
            // 選択中のデバイス
            self.selectDeviceName = ""
            self.selectPeripheral = nil
        }
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
        
        if cell.textLabel!.text!.contains(self.selectDeviceName!) {
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
        self.selectDeviceName = Array(self.watchDic.keys)[indexPath.row]
        self.selectPeripheral = Array(self.watchDic.values)[indexPath.row]
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

// MARK: - YCBLEサービス関連
extension WatchSettingViewController : YCBleDelegate{
    
    /// ウォッチスキャン成功
    func successToScanWatch(deviceName: String?,peripherals: [CBPeripheral]) {
        CommonUtil.Print(className: self.className, message: "successToScanWatch")
        
        for peripheral in peripherals{
            
            let name : String = peripheral.name!
            
            if self.isWatchSettings {
                //ウォッチ設定中
                if let watchSettingsDeviceName = self.WatchManageService.WatchSettingInfo.WatchDeviceName {
                    
                    if name.contains(watchSettingsDeviceName){
                        self.WatchManageService.WatchBleService.SetConnectPeripheral(peripheral: peripheral)
                        self.WatchManageService.WatchBleService.ConnectPeripheral()
                        
                        return
                    }
                }
            }
            
            if self.WatchManageDic.keys.contains(name) == false{
                if self.watchDic.keys.contains(name) == false{
                    self.watchDic[name] = peripheral
                    self.deviceScanTableView.reloadData()
                }
            }
        }
        self.isWatchSettings = false
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// ウォッチ接続成功
    func successToWatchConnect(deviceName : String) {
        CommonUtil.Print(className: self.className, message: "successToWatchConnect")
        
        // ウォッチスキャンデバイスタイマ停止する
        self.WatchManageService.StopWatchScanDeviceTimer()
        // ウォッチ設定中
        self.watchSettings(isSettings: true)
        self.isWatchSettings = true
        // デバイス名設定
        self.watchSettingTvc.SetDeviceName(value: self.WatchManageService.WatchBleService.GetDeviceName())
        // デバイスのMACアドレス取得
        self.WatchManageService.StartGetMacAddressTimer()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// MACアドレス取得完了
    func getMacAddressComplete(deviceName : String, macAddress: String) {
        CommonUtil.Print(className: self.className, message: "getMacAddressComplete")
        
        // タイマを停止する
        self.WatchManageService.StopGetMacAddressTimer()
        // デバイスのMACアドレス設定
        self.watchSettingTvc.SetMacAddress(value: macAddress)
        self.WatchManageService.WatchBleService.SetMacAddress(value: macAddress)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 脈拍監視モード設定完了
    func settingHeartModeComplete(deviceName: String, code: Error_Code) {
        // メッセージ表示
        var title : String = ""
        if code == Error_Ok{
            title = "✅設定完了"
        }
        else{
            title = "❎設定失敗"
        }
        self.showAlertAutoClose(title: title, message: "", closeTime: 1)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 履歴データ取得完了
    func syncHistoryDataComplete(deviceName : String, historyType: Int, rows: [[String : Any]]) {
        // 処理なし
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
