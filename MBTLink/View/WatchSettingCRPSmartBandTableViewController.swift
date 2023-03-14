//
// WatchSettingCRPSmartBandTableViewController.swift
// ウォッチ設定CRPSmartBandTableView
//
// MBTLink
//
import UIKit

class WatchSettingCRPSmartBandTableViewController: UITableViewController,UITextFieldDelegate{
    
    // MARK: - UI部品
    /// MACアドレス
    @IBOutlet weak var macAddressLabel: UILabel!
    /// デバイス名
    @IBOutlet weak var deviceNameLabel: UILabel!
    /// 自動測定 測定間隔ラベル
    @IBOutlet weak var measurementIntervalLabel: UILabel!
    /// 自動測定 測定間隔テキスト（入力用）
    @IBOutlet weak var measurementIntervalText: UITextField!
    /// 歩数測定 送信間隔ラベル
    @IBOutlet weak var stepSendIntervalLabel: UILabel!
    /// 歩数測定 送信間隔テキスト（入力用）
    @IBOutlet weak var stepSendIntervalText: UITextField!
    // 歩幅ラベル
    @IBOutlet weak var stepLengthLabel: UILabel!
    // 歩幅テキスト（入力用）
    @IBOutlet weak var stepLengthText: UITextField!
    
    /// 血圧自動測定
    @IBOutlet weak var bloodPressureSwitch: UISwitch!
    /// SpO2自動測定
    @IBOutlet weak var spO2Switch: UISwitch!
    
    /// 通知設定・着信
    @IBOutlet weak var callNotificationSettingSwitch: UISwitch!
    /// 通知設定・SMS
    @IBOutlet weak var smsNotificationSettingSwitch: UISwitch!
    /// 通知設定・LINE
    @IBOutlet weak var lineNotificationSettingSwitch: UISwitch!
    ///通知設定・qq
    @IBOutlet weak var qqNotificationSettingSwitch: UISwitch!
    ///通知設定・wechat
    @IBOutlet weak var weChatNotificationSettingSwitch: UISwitch!
    ///通知設定・faceBook
    @IBOutlet weak var faceBookNotificationSettingSwitch: UISwitch!
    ///通知設定・twitter
    @IBOutlet weak var twitterNotificationSettingSwitch: UISwitch!
    ///通知設定・スカイプ
    @IBOutlet weak var skypeNotificationSettingSwitch: UISwitch!
    ///通知設定・instagram
    @IBOutlet weak var instagramNotificationSettingSwitch: UISwitch!
    ///通知設定・whatsApp
    @IBOutlet weak var whatsAppNotificationSettingSwitch: UISwitch!
    ///通知設定・kakaoTalk
    @IBOutlet weak var kakaoTalkNotificationSettingSwitch: UISwitch!
    ///通知設定・gmail
    @IBOutlet weak var gmailNotificationSettingSwitch: UISwitch!
    ///通知設定・messenger
    @IBOutlet weak var messengerNotificationSettingSwitch: UISwitch!
    ///通知設定・others
    @IBOutlet weak var othersNotificationSettingSwitch: UISwitch!
    // MARK: - Public変数
    /// CRPSmartBand管理サービス
    public var WatchManageService : CRPSmartBandManageService!
    // MARK: - Private変数
    /// ウォッチ設定ViewController
    private var watchSettingVc : WatchSettingCRPSmartBandViewController!
    
    /// クラス名
    private let className = String(String(describing: ( WatchSettingCRPSmartBandTableViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    
    ///対象入力項目の判定値
    private var targetTag : Int = 0
    
    var doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: WatchSettingCRPSmartBandTableViewController.self, action: #selector(done))
    
    /// 自動測定 測定間隔のpicker
    var measurementIntervalPicker: UIPickerView = UIPickerView()
    let measurementInterval_List: [String] = ["5","10","15","20","25","30","35","40","45","50","55","60"]
    ///歩数測定 送信間隔のpicker
    var stepSendIntervalPicker: UIPickerView = UIPickerView()
    let stepSendInterval_List: [String] = ["5","10","15","20","25","30","35","40","45","50","55","60"]
    // 歩幅のpicker
    var stepLengthPicker: UIPickerView = UIPickerView()
    let stepLength_List:[String] = ["30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155"]
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自動測定 測定間隔ラベル 非表示
        self.measurementIntervalLabel.isHidden = true
        self.stepSendIntervalLabel.isHidden = true
        self.stepLengthLabel.isHidden = true
        
        // ナビゲーションタイトル
        
        let navbarTitle = UILabel()
        navbarTitle.text = StringsConst.Wearable_Settings
            navbarTitle.font = UIFont.boldSystemFont(ofSize: 17)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = navbarTitle

        //picker()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ウォッチ設定ViewController
        self.watchSettingVc = (self.parent as! WatchSettingCRPSmartBandViewController)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    
    // タップイベント
    @IBAction func tapTableView(_ sender: UITapGestureRecognizer) {
        // ビュー階層内のファーストレスポンダを探索して resignFirstResponder() を呼ぶ
        self.view.endEditing(true)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 血圧スイッチ選択イベント
    @IBAction func changeBloodPressureSettingSwitch(_ sender: UISwitch) {
        var switchstate : String
        if bloodPressureSwitch.isOn{
            //CRPSmartBandBleService.BloodPressureMeasure = true
            switchstate = "on"
        }else{
            //CRPSmartBandBleService.BloodPressureMeasure = false
            switchstate = "off"
        }
 
        self.watchSettingVc.saveWatchSettingViewData()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    /// SpO2スイッチ選択イベント
    @IBAction func changeSpO2SettingSwitch(_ sender: UISwitch) {
        var switchstate : String
        if spO2Switch.isOn{
            //CRPSmartBandBleService.SpO2Measure = true
            switchstate = "on"
        }else{
            //CRPSmartBandBleService.SpO2Measure = false
            switchstate = "off"
        }
   
        self.watchSettingVc.saveWatchSettingViewData()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    
    /// 通知設定・通話スイッチ選択イベント
    @IBAction func changeCallNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if callNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }

    /// 通知設定・SMSスイッチ選択イベント
    @IBAction func changeSmsNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if smsNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    /// 通知設定・LINEスイッチ選択イベント
    @IBAction func changeLineNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if lineNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・qqスイッチ選択イベント
    @IBAction func changeQqNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if qqNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・weChatスイッチ選択イベント
    @IBAction func changeWeChatNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if weChatNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・faceBookスイッチ選択イベント
    @IBAction func changeFaceBookNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if faceBookNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・twitterスイッチ選択イベント
    @IBAction func changeTwitterNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if twitterNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・instagramスイッチ選択イベント
    @IBAction func changeInstagramNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if instagramNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・skypeスイッチ選択イベント
    @IBAction func changeSkypeNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if skypeNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・whatsAppスイッチ選択イベント
    @IBAction func changeWhatsAppNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if whatsAppNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・kakaoTalk
    @IBAction func changeKakaoTalkNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if kakaoTalkNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・gmail
    @IBAction func changeGmailNotifiicationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if gmailNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・messenger
    @IBAction func changeMessengerNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if messengerNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    ///通知設定・その他
    @IBAction func changeOthersNotificationSettingSwitch(_ sender: UISwitch) {
        // 通知設定
        self.notificationSetting()
        var switchstate : String
        if othersNotificationSettingSwitch.isOn{
            switchstate = "on"
        }else{
            switchstate = "off"
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: switchstate)
    }
    
    @objc func done(){
        //取得したpickerの中身を保存用
        var getText: String
        //決定ボタンを非活性
        doneItem.isEnabled = false
        if targetTag != 0 {
//            print(targetTag)
            if targetTag == 1 {
                //自動測定 測定間隔のdoneボタン処理
                measurementIntervalText.endEditing(true)
                //選択内容をテキスト表示
                getText = "\(measurementInterval_List[measurementIntervalPicker.selectedRow(inComponent: 0)])"
                measurementIntervalText.text = getText
                self.measurementIntervalLabel.text = measurementIntervalText.text!
                targetTag = 0
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "measurement interval")
            }else if targetTag == 2 {
                //歩数測定 送信間隔のdoneボタン処理
                stepSendIntervalText.endEditing(true)
                //選択内容をテキスト表示
                getText = "\(stepSendInterval_List[stepSendIntervalPicker.selectedRow(inComponent: 0)])"
                stepSendIntervalText.text = getText
                self.stepSendIntervalLabel.text = stepSendIntervalText.text!
                targetTag = 0
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "step send interval")
            }else if targetTag == 3{
                //歩幅のdoneボタン処理
                stepLengthText.endEditing(true)
                //選択内容をテキスト表示
                getText = "\(stepLength_List[stepLengthPicker.selectedRow(inComponent: 0)])"
                stepLengthText.text = getText
                self.stepLengthLabel.text = stepLengthText.text!
                stepLengthSetting()
                targetTag = 0
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "steplength")
            }
            //userdefault設定値保存
            self.watchSettingVc.saveWatchSettingViewData()
        }
        
    }
    
    ///キャンセルボタンイベント
    @objc func cancel(){
        view.endEditing(true)
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
            return 7
        case 1:
            // 通知アプリ
            return 14
        default:
            return 0
        }
    }
    
    /// セクションのヘッダー
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        let sectionText = UILabel()
        sectionText.frame = CGRect.init(x: 5, y: 5, width: sectionHeader.frame.width-10, height: sectionHeader.frame.height-10)
        sectionText.font = .systemFont(ofSize: 14, weight: .bold)
        sectionText.minimumScaleFactor = 0.5
        sectionText.adjustsFontSizeToFitWidth = true
        sectionText.textColor = .black
        sectionHeader.backgroundColor = .systemGray6
        if (section == 0) {
            sectionText.text = StringsConst.Function
        }else if (section == 1) {
            sectionText.text = StringsConst.Notification_Application
        }else {
            sectionText.text = ""
        }
        sectionHeader.addSubview(sectionText)
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return sectionHeader
    }
    
 //   func tableview(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat{
 //       return 40
        
 //   }
    
    /// ヘッダーの高さ
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
                return 40
            }
    
    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header = ""
        if (section == 0){
            header = "FUNCTION"
        }
        if (section == 1){
            header = "NOTIFICATION APPLICATION"
        }
        return header
    }
     */
    
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
    
    /// 通知設定・qqの設定状態取得
    func GetQqNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.qqNotificationSettingSwitch.isOn
    }
    /// 通知設定・qqの状態設定
    func SetQqNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.qqNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・weChatの設定状態取得
    func GetWeChatNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.weChatNotificationSettingSwitch.isOn
    }
    /// 通知設定・weChatの状態設定
    func SetWeChatNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.weChatNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・faceBookの設定状態取得
    func GetFaceBookNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.faceBookNotificationSettingSwitch.isOn
    }
    /// 通知設定・faceBookの状態設定
    func SetFaceBookNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.faceBookNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・twitterの設定状態取得
    func GetTwitterNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.twitterNotificationSettingSwitch.isOn
    }
    /// 通知設定・twitterの状態設定
    func SetTwitterNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.twitterNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・skypeの設定状態取得
    func GetSkypeNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.skypeNotificationSettingSwitch.isOn
    }
    /// 通知設定・skypeの状態設定
    func SetSkypeNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.skypeNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・instagramの設定状態取得
    func GetInstagramNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.instagramNotificationSettingSwitch.isOn
    }
    /// 通知設定・instagramの状態設定
    func SetInstagramNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.instagramNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・whatsAppの設定状態取得
    func GetWhatsAppNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.whatsAppNotificationSettingSwitch.isOn
    }
    /// 通知設定・whatsAppの状態設定
    func SetWhatsAppNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.whatsAppNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・kakaoTalkの設定状態取得
    func GetKakaoTalkNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.kakaoTalkNotificationSettingSwitch.isOn
    }
    /// 通知設定・kakaoTalkの状態設定
    func SetKakaoTalkNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.kakaoTalkNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・gmailの設定状態取得
    func GetGmailNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.gmailNotificationSettingSwitch.isOn
    }
    /// 通知設定・gmailの状態設定
    func SetGmailNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.gmailNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・messengerの設定状態取得
    func GetMessengerNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.messengerNotificationSettingSwitch.isOn
    }
    /// 通知設定・messengerの状態設定
    func SetMessengerNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.messengerNotificationSettingSwitch.isOn = value
    }
    
    /// 通知設定・othersの設定状態取得
    func GetOthersNotificationSetting() -> Bool{
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.othersNotificationSettingSwitch.isOn
    }
    /// 通知設定・othersの状態設定
    func SetOthersNotificationSetting(value : Bool){
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.othersNotificationSettingSwitch.isOn = value
    }
    /// 血圧測定の設定状態取得
    func GetBloodPressureMeasure() -> Bool{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.bloodPressureSwitch.isOn
    }
    /// 血圧測定の状態設定
    func SetBloodPressureMeasure(value : Bool){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.bloodPressureSwitch.isOn = value
    }
    /// SpO2測定の設定状態取得
    func GetSpO2Measure() -> Bool{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.spO2Switch.isOn
    }
    /// SpO2測定の状態設定
    func SetSpO2Measure(value : Bool){
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.spO2Switch.isOn = value
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
    
    /// 歩数計測 送信間隔取得
    func GetStepSendInterval() -> Int{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return Int(self.stepSendIntervalLabel.text!)!
    }
    /// 歩数計測 送信間隔設定
    func SetStepSendInterval(value : Int) {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.stepSendIntervalLabel.text = String(value)
        self.stepSendIntervalText.text = String(value)
    }
  
    /// 歩幅取得
    func GetStepLength() -> Int{
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return Int(self.stepLengthLabel.text!)!
    }
    /// 歩幅設定
    func SetStepLength(value : Int) {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        self.stepLengthLabel.text = String(value)
        self.stepLengthText.text = String(value)
    }
    // MARK: - Private Methods
    /// 通知設定
    private func notificationSetting(){
        self.watchSettingVc.WatchManageService.WatchBleService.NotificationSetting(
            isCallSettings: self.callNotificationSettingSwitch.isOn,
            isSmsSettings: self.smsNotificationSettingSwitch.isOn,
            isLineSettings: self.lineNotificationSettingSwitch.isOn)
        
        // UserDefaultsに画面情報を設定
        self.watchSettingVc.saveWatchSettingViewData()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 歩幅設定
    func stepLengthSetting(){
//       self.watchSettingVc.WatchManageService.WatchBleService.setStepLength(length: self.WatchManageService.WatchSettingInfo.StepLength)
        self.watchSettingVc.WatchManageService.WatchBleService.setStepLength(length:Int(self.stepLengthLabel.text!)!)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // テキストフィールドのフォーカスが外れたときの処理
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.done()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // テキストフィールドの有効値判定
    func picker(){

        //自動測定 測定間隔の設定
        measurementIntervalPicker.delegate = self
        measurementIntervalPicker.dataSource = self
        measurementIntervalPicker.tag = 1
        //pickerの初期値を設定
        if let measurementInterval : String = measurementIntervalText.text{
            measurementIntervalText.text = measurementInterval
            print(measurementInterval)
            self.measurementIntervalPicker.selectRow(self.measurementInterval_List.lastIndex(of: measurementInterval) ?? 0, inComponent: 0, animated: false)
        }else{
            self.measurementIntervalPicker.selectRow(0, inComponent: 0, animated: false)
        }
        //選択行をハイライト
        measurementIntervalPicker.showsSelectionIndicator = true
        //決定ボタン作成
        let toolber_measurementInterval = UIToolbar(frame: CGRect(x: 30, y: 30,width: view.frame.size.width, height: 35))
        let spaceItem_measurementInterval = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem_measurementInterval = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem_measurementInterval = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolber_measurementInterval.setItems([cancelItem_measurementInterval, spaceItem_measurementInterval, doneItem_measurementInterval], animated: true)
        //自動測定 測定間隔のインプットビューを設定
        measurementIntervalText.inputView = measurementIntervalPicker
        measurementIntervalText.inputAccessoryView = toolber_measurementInterval
        
        //歩数測定 送信間隔の設定
        stepSendIntervalPicker.delegate = self
        stepSendIntervalPicker.dataSource = self
        stepSendIntervalPicker.tag = 2
        //pickerの初期値を設定
        if let stepSendInterval : String = stepSendIntervalText.text{
            stepSendIntervalText.text = stepSendInterval
            print(stepSendInterval)
            self.stepSendIntervalPicker.selectRow(self.stepSendInterval_List.lastIndex(of: stepSendInterval) ?? 0, inComponent: 0, animated: false)
        }else{
            self.stepSendIntervalPicker.selectRow(0, inComponent: 0, animated: false)
        }
        //選択行をハイライト
        stepSendIntervalPicker.showsSelectionIndicator = true
        //決定ボタン作成
        let toolber_stepSendInterval = UIToolbar(frame: CGRect(x: 30, y: 30,width: view.frame.size.width, height: 35))
        let spaceItem_stepSendInterval = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem_stepSendInterval = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem_stepSendInterval = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolber_stepSendInterval.setItems([cancelItem_stepSendInterval, spaceItem_stepSendInterval, doneItem_stepSendInterval], animated: true)
        //歩数測定 送信間隔のインプットビューを設定
        stepSendIntervalText.inputView = stepSendIntervalPicker
        stepSendIntervalText.inputAccessoryView = toolber_stepSendInterval
        
        //歩幅の設定
        stepLengthPicker.delegate = self
        stepLengthPicker.dataSource = self
        stepLengthPicker.tag = 3
        //pickerの初期値を設定
        if let stepLength : String = stepLengthText.text{
            stepLengthText.text = stepLength
            //print(stepLength)
            self.stepLengthPicker.selectRow(self.stepLength_List.lastIndex(of: stepLength) ?? 0, inComponent: 0, animated: false)
        }else{
            self.stepLengthPicker.selectRow(40, inComponent: 0, animated: false)
        }
        //選択行をハイライト
        stepLengthPicker.showsSelectionIndicator = true
        //決定ボタン作成
        let toolber_stepLength = UIToolbar(frame: CGRect(x: 30, y: 30,width: view.frame.size.width, height: 35))
        let spaceItem_stepLength = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem_stepLength = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem_stepLength = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolber_stepLength.setItems([cancelItem_stepLength, spaceItem_stepLength, doneItem_stepLength], animated: true)
        //歩幅のインプットビューを設定
        stepLengthText.inputView = stepLengthPicker
        stepLengthText.inputAccessoryView = toolber_stepLength
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
extension WatchSettingCRPSmartBandTableViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        if pickerView.tag == 1 {
            return measurementInterval_List.count
        }else if pickerView.tag == 2{
            return stepSendInterval_List.count
        }else {
            return stepLength_List.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        doneItem.isEnabled = true
        if pickerView.tag == 1 {
            targetTag = 1
            return measurementInterval_List[row]
        }else if pickerView.tag == 2{
            targetTag = 2
            return stepSendInterval_List[row]
        }else {
            targetTag = 3
            return stepLength_List[row]
        }
    }


}
