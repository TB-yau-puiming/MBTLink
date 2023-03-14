//
// LocationInfoSettingTableViewController.swift
// 位置情報設定
//
//  MBTLink
//

import UIKit
import CoreLocation

class LocationInfoSettingTableViewController: UITableViewController, UITextFieldDelegate{
    // MARK: - UI部品

    @IBOutlet weak var locationInfoSendMethod: UISegmentedControl!
    // 位置情報を送信する
    @IBOutlet weak var locationInfoSendSwitch: UISwitch!
    // 位置情報送信 開始時刻
    @IBOutlet weak var locationInfoSendStartText: UITextField!
    // 位置情報送信 終了時刻
    @IBOutlet weak var locationInfoSendEndText: UITextField!
    // 位置情報受信レベル
    @IBOutlet weak var locationInfoReceiveLevelText: UITextField!
    // 最短送信間隔
    @IBOutlet weak var shortestSendIntervalText: UITextField!

    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( LocationInfoSettingTableViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// ロケーションマネジャー
//    private var locationManager: CLLocationManager!
    /// ファイル操作クラス
    private var fileUtil = FileUtil()
    // データ通信サービス
    var dcService: DataCommunicationService!
//    /// 受信タイマー
//    private var receiveTimer: Timer!
//    /// 送信タイマー
//    private var sendTimer : Timer!

    /// カウント
    private var count: Int! = 0
    /// 位置情報ファイル名
    private var locationFileName : String!
    /// 位置情報書き込みデータ
    private var writeData : String! = ""
    /// 位置情報送信 開始時刻
    private var locationInfoSendStart : String = "09:00"
    /// 位置情報送信 終了時刻
    private var locationInfoSendEnd : String = "17:00"
    /// 最短送信間隔
    private var shortestSendInterval : String = StringsConst.FIVE_MINUTES
    /// 位置情報受信レベル
    private var locationInfoReceiveLevel : String! = StringsConst.LOW
    ///
    private var locationInfoSendMethodNum : Int = 1
    ///位置情報送信　開始時刻のpicker
    var timePicker_Start: UIDatePicker = UIDatePicker()
    ///位置情報送信　終了時刻のpicker
    var timePicker_End: UIDatePicker = UIDatePicker()
    ///最短送信間隔のpicker
    var shortestSendIntervalPicker: UIPickerView = UIPickerView()
    let shortestSendInterval_List: [String] = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60"]
    ///位置情報レベルのpicker
    var locationInfoReceiveLevelPicker: UIPickerView = UIPickerView()
    let locationInfoReceiveLevel_List: [String] = [StringsConst.LOW,StringsConst.MEDIUM,StringsConst.HIGH]
    ///dataPickerの判定用変数
    var targetPicker: Int = 0
    var doneItem = UIBarButtonItem(title: StringsConst.DONE, style: .done, target: self, action: #selector(done))
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
//        //位置情報取得の設定
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        self.locationManager.distanceFilter = 50
//
//        // バックグラウンドでの位置情報更新を許可
//        self.locationManager.allowsBackgroundLocationUpdates = true
        // ナビゲーションタイトル
        
        let navbarTitle = UILabel()
        navbarTitle.text = StringsConst.Location_Notification_Settings
            navbarTitle.font = UIFont.boldSystemFont(ofSize: 17)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = navbarTitle
        
        // スイッチイベントの登録
        self.locationInfoSendSwitch.addTarget(self, action: #selector(changeSwitch), for: UIControl.Event.valueChanged)
        
//        // 位置情報ファイル保存ディレクトリ作成
//        self.fileUtil.CreateDirectory(atPath: CommonConst.ReceiveDir)
//
//        // 位置情報ファイル送信ディレクトリ作成
//        self.fileUtil.CreateDirectory(atPath: CommonConst.SendDir)
        
        //設定情報読み出し
        let info = LocationInfoSettingTableViewController.loadLocationInfoSettingData()
        if info != nil {
            CommonUtil.Print(className: self.className, message: "位置情報を送信する：\(String(info!.IsLocationInfoSend))")
            CommonUtil.Print(className: self.className, message: "位置情報送信 開始時刻：\(info!.LocationInfoSendStart)")
            CommonUtil.Print(className: self.className, message: "位置情報送信 終了時刻：\(info!.LocationInfoSendEnd)")
            
            CommonUtil.Print(className: self.className, message: "最短送信間隔（分）：\(info!.ShortestSendInterval)")
            
            CommonUtil.Print(className: self.className, message: "位置情報受信レベル：\(info!.LocationInfoReceiveLevel)")
            CommonUtil.Print(className: self.className, message: "位置情報送信方式：\(info!.LocationInfoSendMethodNum)")
            //前の保存値を反映
            locationInfoSendSwitch.isOn = info?.IsLocationInfoSend ?? false
            locationInfoSendStartText.text = info?.LocationInfoSendStart ?? ""
            locationInfoSendStart = locationInfoSendStartText.text!
            locationInfoSendEndText.text = info?.LocationInfoSendEnd ?? ""
            locationInfoSendEnd = locationInfoSendEndText.text!
            locationInfoReceiveLevelText.text = NSLocalizedString(info?.LocationInfoReceiveLevel ?? "", comment: "")
            locationInfoReceiveLevel = locationInfoReceiveLevelText.text!
            shortestSendIntervalText.text = (info?.ShortestSendInterval ?? "") +  StringsConst.MINUTES
            shortestSendInterval = (info?.ShortestSendInterval ?? "")
            //shortestSendIntervalText.text!
            locationInfoSendMethodNum = info?.LocationInfoSendMethodNum ?? 1
            locationInfoSendMethod.selectedSegmentIndex = locationInfoSendMethodNum
            if locationInfoSendMethod.selectedSegmentIndex == 0{
                locationInfoSendStartText.isEnabled = false;
                locationInfoSendEndText.isEnabled = false;
            }else if locationInfoSendMethod.selectedSegmentIndex == 1{
                locationInfoSendStartText.isEnabled = true;
                locationInfoSendEndText.isEnabled = true;
            }
        }
        
        //picker設定
        picker()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

//        // タイマーを停止する
//        if self.receiveTimer != nil && self.receiveTimer.isValid {
//            self.receiveTimer.invalidate()
//        }
//
//        if self.sendTimer != nil && self.sendTimer.isValid {
//            self.sendTimer.invalidate()
//        }
        self.shortestSendInterval = self.shortestSendIntervalText.text!.replacingOccurrences(of: StringsConst.MINUTES, with: "")
        // 設定情報保存
        LocationInfoSettingTableViewController.saveLocationInfoSettingData(locationInfoSendSwitch: self.locationInfoSendSwitch.isOn, locationInfoSendStart: self.locationInfoSendStart, locationInfoSendEnd: self.locationInfoSendEnd, shortestSendInterval: self.shortestSendInterval, locationInfoReceiveLevel: self.locationInfoReceiveLevel, locationInfoSendMethodNum: self.locationInfoSendMethodNum)
        //logMessage = LogUtil.createSystemLog(className: self.className , functionName: #function , message: "callout saveLocationInfoSettingData")
        //self.dcService.postSendLogMsg(msg: logMessage, deviceID: "", deviceAdr: "", deviceType: 0)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //piker設定
    func picker(){
        //位置情報送信開始時刻の設定
        timePicker_Start.tag = 1
        //キーボードをtimePickerに変更
        timePicker_Start.datePickerMode = UIDatePicker.Mode.time
        //pickerを中央に配置
        if #available(iOS 13.4, *) {
            timePicker_Start.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        timePicker_Start.timeZone = NSTimeZone.local
        ///時間を24時間表記に変更
        timePicker_Start.locale = Locale.current
        //pickerの初期値を設定
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        timePicker_Start.date = format.date(from: locationInfoSendStart)!
        //最小単位（分）を設定
        timePicker_Start.minuteInterval = 1
        timePicker_Start.addTarget(self, action: #selector(dataChange), for: .valueChanged)
        //決定ボタン作成
        let toolber = UIToolbar(frame: CGRect(x: 30, y: 30,width: view.frame.size.width, height: 35))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        var doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        doneItem.isEnabled = false
        toolber.setItems([cancelItem, spaceItem, doneItem], animated: true)
        //開始時刻のインプットビューを設定
        locationInfoSendStartText.inputView = timePicker_Start
        locationInfoSendStartText.inputAccessoryView = toolber
        
        //位置情報終了時刻の設定
        timePicker_End.tag = 2
        //キーボードをtimePickerに変更
        timePicker_End.datePickerMode = UIDatePicker.Mode.time
        //pickerを中央に配置
        if #available(iOS 13.4, *) {
            timePicker_End.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        timePicker_End.timeZone = NSTimeZone.local
        ///時間を24時間表記に変更
        timePicker_End.locale = Locale.current
        //pickerの初期値を設定
        format.dateFormat = "HH:mm"
        timePicker_End.date = format.date(from: locationInfoSendEnd)!
        //最小単位（分）を設定
        timePicker_End.minuteInterval = 1
        timePicker_End.addTarget(self, action: #selector(dataChange), for: .valueChanged)
        //決定ボタン作成
        let toolber_End = UIToolbar(frame: CGRect(x: 30, y: 30,width: view.frame.size.width, height: 35))
        let spaceItem_End = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem_End = UIBarButtonItem(title: StringsConst.DONE, style: .done, target: self, action: #selector(done))
        let cancelItem_End = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolber_End.setItems([cancelItem_End, spaceItem_End, doneItem_End], animated: true)
        //終了時刻のインプットビューを設定
        locationInfoSendEndText.inputView = timePicker_End
        locationInfoSendEndText.inputAccessoryView = toolber
        
        //最短送信間隔の設定
        shortestSendIntervalPicker.delegate = self
        shortestSendIntervalPicker.dataSource = self
        shortestSendIntervalPicker.tag = 3
        //pickerの初期値を設定
        self.shortestSendIntervalPicker.selectRow(self.shortestSendInterval_List.lastIndex(of: shortestSendInterval) ?? 0, inComponent: 0, animated: false)
        //shortestSendIntervalPicker.selectRow(4, inComponent: 0, animated: false)
        print(shortestSendIntervalPicker.selectedRow(inComponent: 0))
        //選択行をハイライト
        shortestSendIntervalPicker.showsSelectionIndicator = true
        //決定ボタン作成
        let toolber_shortestSendInterval = UIToolbar(frame: CGRect(x: 30, y: 30,width: view.frame.size.width, height: 35))
        let spaceItem_shortestSendInterval = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem_shortestSendInterval = UIBarButtonItem(title: StringsConst.DONE, style: .done, target: self, action: #selector(done))
        let cancelItem_shortestSendInterval = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolber_shortestSendInterval.setItems([cancelItem_shortestSendInterval, spaceItem_shortestSendInterval, doneItem_shortestSendInterval], animated: true)
        //最短送信間隔のインプットビューを設定
        shortestSendIntervalText.inputView = shortestSendIntervalPicker
        shortestSendIntervalText.inputAccessoryView = toolber_shortestSendInterval
        
        //位置情報レベルの設定
        locationInfoReceiveLevelPicker.delegate = self
        locationInfoReceiveLevelPicker.dataSource = self
        locationInfoReceiveLevelPicker.tag = 4
        //pickerの初期値を設定
        self.locationInfoReceiveLevelPicker.selectRow(self.locationInfoReceiveLevel_List.lastIndex(of: locationInfoReceiveLevel) ?? 0, inComponent: 0, animated: false)
        //選択行をハイライト
        locationInfoReceiveLevelPicker.showsSelectionIndicator = true
        //決定ボタン作成
        let toolber_locationInfoReceiveLevel = UIToolbar(frame: CGRect(x: 30, y: 30,width: view.frame.size.width, height: 35))
        let spaceItem_locationInfoReceiveLevel = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem_locationInfoReceiveLevel = UIBarButtonItem(title: StringsConst.DONE, style: .done, target: self, action: #selector(done))
        let cancelItem_locationInfoReceiveLevel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolber_locationInfoReceiveLevel.setItems([cancelItem_locationInfoReceiveLevel, spaceItem_locationInfoReceiveLevel, doneItem_locationInfoReceiveLevel], animated: true)
        //位置情報レベルのインプットビューを設定
        locationInfoReceiveLevelText.inputView = locationInfoReceiveLevelPicker
        locationInfoReceiveLevelText.inputAccessoryView = toolber_locationInfoReceiveLevel
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    @IBAction private func dataChange(_ sender: UIDatePicker){
        //日付フォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        //決定ボタンを非活性
        doneItem.isEnabled = false
        if sender.tag == 1 {
            targetPicker = 1
            
            let startTime = "\(formatter.string(from: timePicker_Start.date))"
            let sendStart = Int32(startTime.replacingOccurrences(of: ":", with: ""))
            let sendEnd = Int32(self.locationInfoSendEnd.replacingOccurrences(of: ":", with: ""))
            //開始時刻が終了時刻より早ければデータを変更する
            if sendStart! < sendEnd! {
                //self.locationInfoSendStart = "\(formatter.string(from: timePicker_Start.date))"
                //locationInfoSendStartText.text = self.locationInfoSendStart
                //決定ボタンを活性化
                doneItem.isEnabled = true
            }
        }else if sender.tag == 2 {
            targetPicker = 2
            
            let endTime = "\(formatter.string(from: timePicker_End.date))"
            let sendStart = Int32(self.locationInfoSendStart.replacingOccurrences(of: ":", with: ""))
            let sendEnd = Int32(endTime.replacingOccurrences(of: ":", with: ""))
            //開始時刻が終了時刻より早ければデータを変更する
            if sendStart! < sendEnd! {
                //self.locationInfoSendEnd = "\(formatter.string(from: timePicker_End.date))"
                //locationInfoSendEndText.text = self.locationInfoSendEnd
                //決定ボタンを活性化
                doneItem.isEnabled = true
            }
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    @objc func done(){
        //日付フォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        //取得したpickerの中身を保存用
        var getText: String
        //決定ボタンを非活性
        doneItem.isEnabled = false
        if targetPicker != 0 {
            if targetPicker == 1 {
                //位置情報送信開始項目のdoneボタン処理
                locationInfoSendStartText.endEditing(true)

                let startTime = "\(formatter.string(from: timePicker_Start.date))"
                let sendStart = Int32(startTime.replacingOccurrences(of: ":", with: ""))
                let sendEnd = Int32(self.locationInfoSendEnd.replacingOccurrences(of: ":", with: ""))
                ///dataChangeで一度チェックをしたので必要ないかも
                if sendStart! <= sendEnd! {
                    self.locationInfoSendStart = "\(formatter.string(from: timePicker_Start.date))"
                    locationInfoSendStartText.text = self.locationInfoSendStart
                }
                //ピッカーの表示値を変更
                timePicker_Start.date = formatter.date(from: locationInfoSendStart)!
                targetPicker = 0
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "location info send start")
            }else if targetPicker == 2 {
                //位置情報送信終了項目のdoneボタン処理
                locationInfoSendEndText.endEditing(true)
                
                let endTime = "\(formatter.string(from: timePicker_End.date))"
                let sendStart = Int32(self.locationInfoSendStart.replacingOccurrences(of: ":", with: ""))
                let sendEnd = Int32(endTime.replacingOccurrences(of: ":", with: ""))
                //開始時刻が終了時刻より早ければデータを変更する
                if sendStart! <= sendEnd! {
                    self.locationInfoSendEnd = "\(formatter.string(from: timePicker_End.date))"
                    locationInfoSendEndText.text = self.locationInfoSendEnd
                }
                //ピッカーの表示値を変更
                timePicker_End.date = formatter.date(from: locationInfoSendEnd)!
                targetPicker = 0
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "location info send end")
            }else if targetPicker == 3 {
                //送信間隔のdoneボタン処理
                shortestSendIntervalText.endEditing(true)
                //選択内容をテキスト表示
                getText = "\(shortestSendInterval_List[shortestSendIntervalPicker.selectedRow(inComponent: 0)])"
                shortestSendIntervalText.text = getText + StringsConst.MINUTES
                self.shortestSendInterval = "\(shortestSendInterval_List[shortestSendIntervalPicker.selectedRow(inComponent: 0)])"
                //位置情報送信間隔のタイマー時間を設定
                if let locationInterval = Double(getText) {
                    CommonConst.locationSendData.locationSendTimerInterval = locationInterval
                }
                // タイマーを再起動する
                restartLocationSendTimer()
                targetPicker = 0
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "send interval")
            }else if targetPicker == 4 {
                //位置情報受信レベルのdoneボタン処理
                locationInfoReceiveLevelText.endEditing(true)
                //選択内容をテキスト表示
                locationInfoReceiveLevelText.text = "\(locationInfoReceiveLevel_List[locationInfoReceiveLevelPicker.selectedRow(inComponent: 0)])"
                self.locationInfoReceiveLevel = locationInfoReceiveLevelText.text!
                //位置情報精度を変更
                self.dcService.locationService.SetReceiveLevel(receiveLevel: self.locationInfoReceiveLevel)
                targetPicker = 0
                //システムログ作成、送信
                LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "location receive level")
            }
            //userdefault設定値保存
            LocationInfoSettingTableViewController.saveLocationInfoSettingData(locationInfoSendSwitch: self.locationInfoSendSwitch.isOn, locationInfoSendStart: self.locationInfoSendStart, locationInfoSendEnd: self.locationInfoSendEnd, shortestSendInterval: self.shortestSendInterval, locationInfoReceiveLevel: self.locationInfoReceiveLevel, locationInfoSendMethodNum: self.locationInfoSendMethodNum)
        }
    }
    
    ///キャンセルボタンイベント
    @objc func cancel(){
        view.endEditing(true)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// スイッチ選択イベント
    @objc func changeSwitch(_ sender: UISwitch){
        //位置情報送信フラグを反映
        CommonConst.locationSendData.locationSendFlg = sender.isOn
        //userdefault設定値保存
        LocationInfoSettingTableViewController.saveLocationInfoSettingData(locationInfoSendSwitch: self.locationInfoSendSwitch.isOn, locationInfoSendStart: self.locationInfoSendStart, locationInfoSendEnd: self.locationInfoSendEnd, shortestSendInterval: self.shortestSendInterval, locationInfoReceiveLevel: self.locationInfoReceiveLevel, locationInfoSendMethodNum: self.locationInfoSendMethodNum)
        
        if sender.isOn {
            //CommonUtil.Print(className: self.className, message: "on")

            
            self.locationInfoSendStart = self.locationInfoSendStartText.text!
            self.locationInfoSendEnd = self.locationInfoSendEndText.text!
            self.shortestSendInterval = self.shortestSendIntervalText.text!.replacingOccurrences(of: StringsConst.MINUTES, with: "")
            self.locationInfoReceiveLevel = self.locationInfoReceiveLevelText.text!
            
            
            
            //位置情報送信を開始する
            self.dcService.startLocationSendTimer()
            
            // 位置情報受信タイマーStart
//            self.startReceiveTimer()
            
            // 位置情報送信タイマーStart
//            self.startSendTimer()
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "on")
        }
        else{
            //CommonUtil.Print(className: self.className, message: "off")
            
//            // タイマーを停止する
//            if self.receiveTimer != nil && self.receiveTimer.isValid {
//                self.receiveTimer.invalidate()
//            }
//            if self.sendTimer != nil && self.sendTimer.isValid {
//                self.sendTimer.invalidate()
//            }
            
            // タイマーを停止する
            self.dcService.stopLocationSendTimer()
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "off")
        }
    }

    @IBAction func locationInfoSendMethodChanged(_ sender: Any) {
        if locationInfoSendMethod.selectedSegmentIndex == 0{
            
            CommonUtil.Print(className: self.className, message: "常時通知")
            locationInfoSendMethodNum = 0
            locationInfoSendStartText.isEnabled = false;
            locationInfoSendEndText.isEnabled = false;
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Always")
        }else if locationInfoSendMethod.selectedSegmentIndex == 1{
            CommonUtil.Print(className: self.className, message: "時刻指定")
            locationInfoSendMethodNum = 1
            locationInfoSendStartText.isEnabled = true;
            locationInfoSendEndText.isEnabled = true;
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Specify Time")
        }
        LocationInfoSettingTableViewController.saveLocationInfoSettingData(locationInfoSendSwitch: self.locationInfoSendSwitch.isOn, locationInfoSendStart: self.locationInfoSendStart, locationInfoSendEnd: self.locationInfoSendEnd, shortestSendInterval: self.shortestSendInterval, locationInfoReceiveLevel: self.locationInfoReceiveLevel, locationInfoSendMethodNum: self.locationInfoSendMethodNum)
        tableView.reloadData()
    }
    // MARK: - Table view イベント関連
    /// Viewのセクション数を返却
    override func numberOfSections(in tableView: UITableView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 1
    }

    /// Viewの各セクションの行数を返却
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 6
    }
    /*
    /// フッターの文章を設定
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        var footer:String = ""
        
        footer.append(StringsConst.LOCATION_INFO_SETTING_FOOTER_A)
        footer.append("\n")
        footer.append(StringsConst.LOCATION_INFO_SETTING_FOOTER_B)
        footer.append("\n")
        footer.append(StringsConst.LOCATION_INFO_SETTING_FOOTER_C)
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return footer
    }
    */
    /// フッダーの高さを設定
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")

        switch section{
        
        case 0:
            return 180
            //return UITableView.automaticDimension
 
        default:
            return 0
        }
    }

    /// セクションのフッダー
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let sectionFooter = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 180))

        let sectionText = UILabel()
        //let maxSize = CGSize(width: self.view.frame.width - 30, height: CGFloat.greatestFiniteMagnitude)
        //let size = sectionText.sizeThatFits(maxSize)
        sectionText.frame = CGRect.init(x: 15, y: -15, width: sectionFooter.frame.width-30, height: sectionFooter.frame.height)
        //sectionText.frame = CGRect.init(x: 15, y: 5, width: sectionHeader.frame.width-30, height: CGFloat.greatestFiniteMagnitude)
        //sectionText.frame = CGRect(origin: CGPoint(x:15, y: 5), size: size)
        sectionText.font = .systemFont(ofSize: 14)
        sectionText.minimumScaleFactor = 0.5
        sectionText.lineBreakMode = .byWordWrapping
        sectionText.numberOfLines = 0
        sectionText.adjustsFontSizeToFitWidth = true
        sectionText.textColor = .gray
        //sectionText.textColor = .systemGray
        sectionFooter.backgroundColor = .systemGray6
        //sectionFooter.backgroundColor = .systemYellow
        if (section == 0) {
            sectionText.text = StringsConst.LOCATION_INFO_SETTING_FOOTER_A + "\n" + StringsConst.LOCATION_INFO_SETTING_FOOTER_B + "\n"+StringsConst.LOCATION_INFO_SETTING_FOOTER_C
        }else{
            sectionText.text = ""
        }
        sectionFooter.addSubview(sectionText)
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return sectionFooter
    }
    
    
    /// セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //CommonUtil.Print(className: self.className, message: "\(indexPath.row)番目のセルが選ばれました")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "choosing the cell in no.\(indexPath.row)")
    }
   override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       if locationInfoSendMethod.selectedSegmentIndex == 0 {
       if indexPath.row == 2{
       cell.backgroundColor = UIColor.gray
       }
       if indexPath.row == 3{
       cell.backgroundColor = UIColor.gray
       }
       }else {
           cell.backgroundColor = UIColor.clear
       }
       //システムログ作成、送信
       //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
 
    // MARK: - Private Methods
    /// 位置情報受信タイマーStart
//    private func startReceiveTimer(){
        
        // 位置情報受信レベル
//        switch self.locationInfoReceiveLevel{
//        case "低":
//            // 3km以内（低）
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//        case "中":
//            // 100m以内（中）
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        case "高":
//            // 最高精度（高）
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        default:
//            // デフォルト
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        }
                                            
        // 位置情報受信タイマー設定
//        self.receiveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(locationUpdate), userInfo: nil, repeats: true)
//        self.receiveTimer.fire()
//    }
    
    /// 位置情報送信タイマーStart
//    private func startSendTimer(){
//
//        // 送信間隔ごとにsendDataを実行する
//        let timeinterval :Double = Double(self.shortestSendInterval.replacingOccurrences(of: "分", with: "")) ?? 1
//
//        self.sendTimer = Timer.scheduledTimer(timeInterval: timeinterval*60, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
//        self.sendTimer.fire()
//    }
    
    /// 位置情報ファイル名取得
    private func getLocationFileName() -> String{
        
        let dateString = DateUtil.GetDateFormatConvert(format: "yyyyMMddHHmmss")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return "locationInfo_" + dateString + ".txt"
    }
    /// myReceiveTimerでループ実行する処理
//    @objc func locationUpdate() {
//
//        // stop -> start で位置情報更新させる
//        self.locationManager.stopUpdatingLocation()
//        self.locationManager.startUpdatingLocation()
//
//        CommonUtil.Print(className: self.className, message: DateUtil.GetDateFormatConvert(format: "yyyy年MM月dd日 HH:mm:ss"))
//    }
    
    /// 位置情報送信
//    @objc func sendData(){
//        if self.count > 0 {
            
//            let dateNow = Int32(DateUtil.GetDateFormatConvert(format: "HHmm"))
//            let locationInfoSendStart = Int32(self.locationInfoSendStart.replacingOccurrences(of: ":", with: ""))
//            let locationInfoSendEnd = Int32(self.locationInfoSendEnd.replacingOccurrences(of: ":", with: ""))
//
//            CommonUtil.Print(className: self.className, message: "Start:" + String(locationInfoSendStart!))
//            CommonUtil.Print(className: self.className, message: "End:" + String(locationInfoSendEnd!))
//            CommonUtil.Print(className: self.className, message: "Now:" + String(dateNow!))
//
//            // 開始時刻 = 終了時刻 → 24時間送信
//            if self.locationInfoSendStart == self.locationInfoSendEnd ||
//                (locationInfoSendStart! <= dateNow! && dateNow! <= locationInfoSendEnd! ){
//
//                // 位置情報受信タイマーStop
////                self.receiveTimer.invalidate()
//                if self.receiveTimer != nil && self.receiveTimer.isValid {
//                    self.receiveTimer.invalidate()
//                }
//
//                // 受信ディレクトリ→送信ディレクトリに移動
//                let atPath = CommonConst.ReceiveDir + "/" + self.locationFileName
//                let toPath = CommonConst.SendDir + "/" + self.locationFileName
//
//                self.fileUtil.CopyItem(atPath: atPath, toPath: toPath)
//                self.fileUtil.RemoveItem(atPath: atPath)
//
//                // 位置情報ファイル名
//                self.locationFileName =  self.getLocationFileName()
//
//                // 位置情報データクリア
//                self.writeData = ""
//
//                // 位置情報受信タイマーStart
//                self.startReceiveTimer()
//
//                CommonUtil.Print(className: self.className, message: "Move Send File")
//            }
//        }
        
//        // 処理回数の表示をカウントアップ
//        self.count += 1
//
//        CommonUtil.Print(className: self.className, message: "File Send:" + String(self.count))
//    }
    
    // 位置情報設定登録
    static func saveLocationInfoSettingData(locationInfoSendSwitch : Bool, locationInfoSendStart : String, locationInfoSendEnd : String, shortestSendInterval : String, locationInfoReceiveLevel : String, locationInfoSendMethodNum : Int) {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "(LocationInfoSettingTableViewController)" , functionName: #function , message: "")
        let locationInfoSettingData = LocationInfoSettingData(locationInfoSendSwitch, locationInfoSendStart, locationInfoSendEnd, shortestSendInterval, locationInfoReceiveLevel, locationInfoSendMethodNum)
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: locationInfoSettingData,requiringSecureCoding: false)
            else {
                return
        }
        UserDefaults.standard.set(data, forKey: "LocationInfoSettingData")
    }
    
    // 位置情報設定読み出し
    static func loadLocationInfoSettingData() -> LocationInfoSettingData? {
        //システムログ作成、送信
        //アプリクラッシュ
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "(LocationInfoSettingTableViewController)" , functionName: #function , message: "")
        guard let data = UserDefaults.standard.data(forKey: "LocationInfoSettingData") else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? LocationInfoSettingData
    }
    
//    //位置情報送信タイマー開始
//    private func startLocationSendTimer(){
//        let message = "位置情報送信タイマー"
//        CommonUtil.Print(className: self.className, message: message + "Start")
//        if TopViewController.locationSendTimer == nil{
//            //タイマー設定
//            TopViewController.locationSendTimer = Timer.scheduledTimer(timeInterval: CommonConst.locationSendData.locationSendTimerInterval * 60, target: self, selector: #selector(locationDataSendMonitor), userInfo: nil, repeats: true)
//            print(CommonConst.locationSendData.locationSendTimerInterval * 60)
//            CommonUtil.Print(className: self.className, message: message + "設定完了")
//
//            // タイマーStart
//            TopViewController.locationSendTimer.fire()
//        }
//    }
//
//    //位置情報送信タイマー終了
//    private func stopLocationSendTimer(){
//        let message = "位置情報送信タイマー"
//        CommonUtil.Print(className: self.className, message: message + "Stop")
//
//        if TopViewController.locationSendTimer != nil && TopViewController.locationSendTimer.isValid {
//            // タイマーを停止
//            TopViewController.locationSendTimer.invalidate()
//            TopViewController.locationSendTimer = nil
//
//            CommonUtil.Print(className: self.className, message: message +  "Stop完了")
//        }
//    }
    
    //位置情報送信タイマー再起動
    private func restartLocationSendTimer(){
        //let message = "位置情報送信タイマー"
        //CommonUtil.Print(className: self.className, message: message + "Restart")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "restart location send timer")
        if TopViewController.locationSendTimer != nil && TopViewController.locationSendTimer.isValid {
            //userdefault設定値保存
            LocationInfoSettingTableViewController.saveLocationInfoSettingData(locationInfoSendSwitch: self.locationInfoSendSwitch.isOn, locationInfoSendStart: self.locationInfoSendStart, locationInfoSendEnd: self.locationInfoSendEnd, shortestSendInterval: self.shortestSendInterval, locationInfoReceiveLevel: self.locationInfoReceiveLevel, locationInfoSendMethodNum: self.locationInfoSendMethodNum)
            // タイマーを停止
            TopViewController.locationSendTimer.invalidate()
            TopViewController.locationSendTimer = nil
            // タイマーを開始
            self.dcService.startLocationSendTimer()
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "restarted location send timer")
            //CommonUtil.Print(className: self.className, message: message +  "Restart完了")
        }
    }
}

    
    // MARK: -  位置情報取得イベント関連
    // 位置情報取得成功時
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        let dateString = DateUtil.GetDateFormatConvert(format: "yyyy-MM-dd HH:mm:ss")
//
//        let location : CLLocation = locations.last!;
//        let latitudeNow :String = " 緯度：" + String(location.coordinate.latitude)
//        let longitudeNow :String = " 経度：" + String(location.coordinate.longitude)
//        let printData :String = "位置情報取得成功 " + dateString + latitudeNow + longitudeNow
//
//        print(printData)
//
//        var writeData : String = ""
//        writeData.append(dateString)
//        writeData.append(",")
//        writeData.append(String(location.coordinate.latitude))
//        writeData.append(",")
//        writeData.append(String(location.coordinate.longitude))
//
//        if self.writeData == ""{
//            self.writeData = writeData
//        }
//        else{
//            self.writeData = self.writeData + "\n" + writeData
//        }
//
//        let receiveFileName = CommonConst.ReceiveDir + "/" + self.locationFileName
//        // ファイル書き込み
//        self.fileUtil.WritingToFile(text: self.writeData,fileName: receiveFileName)
//    }
//
//    // 位置情報取得失敗時
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        CommonUtil.Print(className: self.className, message: "位置情報取得失敗")
//
//        // myLocationManager.stopUpdatingLocation()
//
//        if #available(iOS 14.0, *){
//            let status = manager.authorizationStatus
//            if (status == .notDetermined) {
//                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
//
//                    // 常に許可するように求める
//                self.locationManager.requestAlwaysAuthorization();
//            }
//        }
//        else{
//            if CLLocationManager.authorizationStatus() == .notDetermined {
//                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
//
//                self.locationManager.requestAlwaysAuthorization()
//            }
//        }
//    }
//
//    /// 位置情報認証変更
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//
//        // 位置情報の認証チェック
//        if #available(iOS 14.0, *){
//            let status = manager.authorizationStatus
//            if  status == .notDetermined {
//                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
//
//                    // 常に許可するように求める
//                self.locationManager.requestAlwaysAuthorization();
//            }
//        }
//        else{
//            if CLLocationManager.authorizationStatus() == .notDetermined {
//                CommonUtil.Print(className: self.className, message: "許可、不許可を選択してない")
//
//                self.locationManager.requestAlwaysAuthorization()
//            }
//        }
//    }

extension LocationInfoSettingTableViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        if pickerView.tag == 3 {
            return shortestSendInterval_List.count
        }else {
            return locationInfoReceiveLevel_List.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        doneItem.isEnabled = true
        if pickerView.tag == 3 {
            targetPicker = 3
            return shortestSendInterval_List[row]
        }else {
            targetPicker = 4
            return locationInfoReceiveLevel_List[row]
        }
    }


}
