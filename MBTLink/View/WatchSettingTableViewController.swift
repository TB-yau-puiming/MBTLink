//
// WatchSettingTableViewController.swift
// ウォッチ設定TableView
//
// MBTLink
//
import UIKit

class WatchSettingTableViewController: UITableViewController,UITextFieldDelegate {
    // MARK: - UI部品
    /// MACアドレス
    @IBOutlet weak var macAddressLabel: UILabel!
    /// デバイス名
    @IBOutlet weak var deviceNameLabel: UILabel!
    /// 自動測定 測定間隔ラベル
    @IBOutlet weak var measurementIntervalLabel: UILabel!
    /// 自動測定 測定間隔テキスト（入力用）
    @IBOutlet weak var measurementIntervalText: UITextField!
    /// 通知設定・着信
    @IBOutlet weak var callNotificationSettingSwitch: UISwitch!
    /// 通知設定・SMS
    @IBOutlet weak var smsNotificationSettingSwitch: UISwitch!
    /// 通知設定・LINE
    @IBOutlet weak var lineNotificationSettingSwitch: UISwitch!

    // MARK: - Private変数
    /// ウォッチ設定ViewController
    private var watchSettingVc : WatchSettingViewController!
    /// クラス名
    private let className = String(String(describing: ( WatchSettingTableViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自動測定 測定間隔ラベル 非表示
        self.measurementIntervalLabel.isHidden = true
        
        // 測定間隔テキスト キーボードに完了ボタンを表示
        let toolbar: UIToolbar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let done = UIBarButtonItem(title: StringsConst.DONE,
                                   style: .done,
                                   target: self,
                                   action: #selector(didTapDoneButton))
        toolbar.items = [space, done]
        toolbar.sizeToFit()
        self.measurementIntervalText.inputAccessoryView = toolbar
        
        // 測定間隔テキスト キーボードを数値入力
        self.measurementIntervalText.keyboardType = .numberPad
        
        // 計測間隔テキスト　デリゲート設定
        self.measurementIntervalText.delegate = self
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ウォッチ設定ViewController
        self.watchSettingVc = (self.parent as! WatchSettingViewController)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// TextFieldの入力制限
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text! +  string
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        // 空白、数値のみ、入力桁数2桁
        return string.isEmpty || (string.range(of: "^[0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil && text.count < 3)
    }
    
    // タップイベント
    @IBAction func tapTableView(_ sender: UITapGestureRecognizer) {
        // ビュー階層内のファーストレスポンダを探索して resignFirstResponder() を呼ぶ
        self.view.endEditing(true)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 通知設定・通話スイッチ選択イベント
    @IBAction func changeCallNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    /// 通知設定・SMSスイッチ選択イベント
    @IBAction func changeSmsNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 通知設定・LINEスイッチ選択イベント
    @IBAction func changeLineNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Table view イベント関連
    /// セクション数を返す
    override func numberOfSections(in tableView: UITableView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 2
    }
    /// セルの数を返す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        switch section {
        case 0:
            // 機能
            return 3
        case 1:
            // 通知アプリ
            return 3
        default:
            return 0
        }
    }
    
    // MARK: - Public Methods
    /// デバイス名取得
    func GetDeviceName() -> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.deviceNameLabel.text ?? ""
    }
    /// デバイス名設定
    func SetDeviceName(value : String?){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.deviceNameLabel.text = value
    }
    
    /// MACアドレス取得
    func GetMacAddress() -> String{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.macAddressLabel.text ?? ""
    }
    /// MACアドレス設定
    func SetMacAddress(value : String?){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.macAddressLabel.text = value
    }
    
    /// 通知設定・通話の設定状態取得
    func GetCallNotificationSetting() -> Bool{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.callNotificationSettingSwitch.isOn
    }
    /// 通知設定・通話の状態設定
    func SetCallNotificationSetting(value : Bool){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.callNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・SMSの設定状態取得
    func GetSmsNotificationSetting() -> Bool{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.smsNotificationSettingSwitch.isOn
    }
    /// 通知設定・SMSの状態設定
    func SetSmsNotificationSetting(value : Bool){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.smsNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・LINEの設定状態取得
    func GetLineNotificationSetting() -> Bool{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.lineNotificationSettingSwitch.isOn
    }
    /// 通知設定・LINEの状態設定
    func SetLineNotificationSetting(value : Bool){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.lineNotificationSettingSwitch.isOn = value
    }
    
    /// 自動計測 測定間隔取得
    func GetMeasurementInterval() -> Int{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return Int(self.measurementIntervalLabel.text!)!
    }
    /// 自動計測 測定間隔設定
    func SetMeasurementInterval(value : Int) {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.measurementIntervalLabel.text = String(value)
        self.measurementIntervalText.text = String(value)
    }

    // MARK: - Private Methods
    /// 通知設定
    private func notificationSetting(){
        self.watchSettingVc.WatchManageService.WatchBleService.NotificationSetting(
            isCallSettings: self.callNotificationSettingSwitch.isOn,
            isSmsSettings: self.smsNotificationSettingSwitch.isOn,
            isLineSettings: self.lineNotificationSettingSwitch.isOn)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// キーボードの完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        
        if self.measurementIntervalText.text?.isEmpty == false{
            
            let inputNum : Int = Int(self.measurementIntervalText.text!)!
            
            // 1-60まで入力可能
            if inputNum >= 1 && inputNum <= 60{
                // 測定間隔ラベルに値格納
                self.measurementIntervalLabel.text = self.measurementIntervalText.text
                // キーボードを閉じる
                self.measurementIntervalText.resignFirstResponder()
                // ウォッチ 脈拍監視モード設定
                self.watchSettingVc.WatchManageService.WatchBleService.SettingHeartMode(heartMode: YCBleService.HeartMode.Auto.rawValue, time: inputNum)
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
