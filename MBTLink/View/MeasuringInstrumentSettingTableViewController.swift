//
// MeasuringInstrumentSettingTableViewController.swift
// MBTLink
//
// 測定機器設定
//

import UIKit

class MeasuringInstrumentSettingTableViewController: UITableViewController {
    // MARK: - UI部品
    /// 環境センサー設定ラベル
    @IBOutlet weak var envSensorSettingLable: UILabel!
    /// 体重計設定ラベル
    @IBOutlet weak var weightScaleSettingLable: UILabel!
    /// 血圧計設定ラベル
    @IBOutlet weak var bloodPressuresMonitorSettingLable: UILabel!
    /// 体温計設定ラベル
    @IBOutlet weak var thermometerSettingLable: UILabel!
    /// パルスオキシメーター設定ラベル
    @IBOutlet weak var pulseOximeterSettingLable: UILabel!
    
    // MARK: - Public変数
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
    /// データ通信サービス
    public var DcService : DataCommunicationService!
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( MeasuringInstrumentSettingTableViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るに変更
        let backbutton = UIBarButtonItem()
        backbutton.title = StringsConst.BACK
        navigationItem.backBarButtonItem = backbutton
        
        // ナビゲーションタイトル
        
        let navbarTitle = UILabel()
        navbarTitle.text = StringsConst.Measuring_Device_Settings
            navbarTitle.font = UIFont.boldSystemFont(ofSize: 17)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = navbarTitle
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CommonUtil.Print(className: self.className, message: "viewWillAppear表示")
        
        // 設定ラベル
        /// 環境センサー
        if EnvSensorManage.MeasuringInstrumentSettingInfo.IsSettings{
            self.envSensorSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.Setting
        }
        else{
            self.envSensorSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.NonSetting
        }
        
        /// 体重計
        if WeightScaleManage.MeasuringInstrumentSettingInfo.IsSettings{
            self.weightScaleSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.Setting
        }
        else{
            self.weightScaleSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.NonSetting
        }
        
        /// 血圧計
        if BpmManage.MeasuringInstrumentSettingInfo.IsSettings{
            self.bloodPressuresMonitorSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.Setting
        }
        else{
            self.bloodPressuresMonitorSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.NonSetting
        }
            
        /// 体温計
        if ThermometerManage.MeasuringInstrumentSettingInfo.IsSettings{
            self.thermometerSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.Setting
        }
        else{
            self.thermometerSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.NonSetting
        }
        
        /// パルスオキシメーター
        if PulseOximeterManage.MeasuringInstrumentSettingInfo.IsSettings{
            self.pulseOximeterSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.Setting
        }
        else{
            self.pulseOximeterSettingLable.text = MeasuringInstrumentConst.MeasuringInstrumentSetting.NonSetting
        }
        
        CommonUtil.Print(className: self.className, message: "===測定機器設定画面 viewWillAppear終了時点 BleServiceログ出力開始===")
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
        CommonUtil.Print(className: self.className, message: "===測定機器設定画面 viewWillAppear終了時点 BleServiceログ出力終了===")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    // MARK: - Table view イベント関連
    /// Viewのセクション数を返却
    override func numberOfSections(in tableView: UITableView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 2
    }
    
    /// Viewの各セクションの行数を返却
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        switch section{
        case 0:
            return 1
            
        case 1:
            return 4
        
        default:
            return 0
        }
    }

    /// ヘッダーの高さを設定
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        switch section{
        case 0:
            return 40
            
        case 1:
            return 40
        
        default:
            return 0
        }
    }


    /// セクションのヘッダー
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        let sectionText = UILabel()
        sectionText.frame = CGRect.init(x: 15, y: 0, width: sectionHeader.frame.width-30, height: sectionHeader.frame.height)
        sectionText.font = .systemFont(ofSize: 14)
        sectionText.minimumScaleFactor = 0.5
        sectionText.lineBreakMode = .byWordWrapping
        sectionText.numberOfLines = 0
        sectionText.adjustsFontSizeToFitWidth = true
        sectionText.textColor = .gray
        //sectionText.textColor = .systemGray
        sectionHeader.backgroundColor = .systemGray6
        if (section == 0) {
            sectionText.text = StringsConst.ENVIRONMENT_SENSOR_SETTINGS
        }else if (section == 1) {
            sectionText.text = StringsConst.DEVICE_SETTINGS
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

    /// フッダーの高さを設定
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")

        switch section{
        
        case 0:
            return 40
            //return UITableView.automaticDimension
 
        default:
            return 0
        }
    }
    /// セクションのフッダー
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let sectionFooter = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        let sectionText = UILabel()
        //let maxSize = CGSize(width: self.view.frame.width - 30, height: CGFloat.greatestFiniteMagnitude)
        //let size = sectionText.sizeThatFits(maxSize)
        sectionText.frame = CGRect.init(x: 15, y: 0, width: sectionFooter.frame.width-30, height: sectionFooter.frame.height)
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
            sectionText.text = StringsConst.MEASURING_INSTRUMENT_SETTING_FOOTER_A
        }else{
            sectionText.text = ""
        }
        sectionFooter.addSubview(sectionText)
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return sectionFooter
    }
  /*  /// フッターの文章を設定
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        
        var footer:String = ""
        
        if section == 0 {
            footer.append(StringsConst.MEASURING_INSTRUMENT_SETTING_FOOTER_A)
        }
 
        return footer
    }
*/
    /// 各ボタン押下時遷移先設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? MeasuringInstrumentDetailViewController else {
                    fatalError("Failed to prepare MeasuringInstrumentDetailViewController.")
                }
                
                // データ通信サービス
                destination.DcService = self.DcService
                
                if indexPath.section == 0 {
                    // 環境センサー
                    destination.DeviceName = EnvSensorConst.DeviceName
                    destination.TitleName = NSLocalizedString(EnvSensorConst.TitleName, comment: "")
                    destination.MeasuringInstrumentManage = self.EnvSensorManage
                    //システムログ作成、送信
                    LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Environment Sensor")
                }
                else{
                    switch indexPath.row{
                    case 0:
                        // 体重計
                        destination.DeviceName = WeightScaleConst.DeviceName
                        destination.TitleName = NSLocalizedString(WeightScaleConst.TitleName, comment: "")
                        destination.MeasuringInstrumentManage = self.WeightScaleManage
                        //システムログ作成、送信
                        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Weight Scale")
                        break
                    case 1:
                        // 血圧計
                        destination.DeviceName = BloodPressuresMonitorConst.DeviceName
                        destination.TitleName = NSLocalizedString(BloodPressuresMonitorConst.TitleName, comment: "")
                        destination.MeasuringInstrumentManage = self.BpmManage
                        //システムログ作成、送信
                        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Blood Pressure Monitor")
                        break
                    case 2:
                        // 体温計
                        destination.DeviceName = ThermometerConst.DeviceName
                        destination.TitleName = NSLocalizedString(ThermometerConst.TitleName, comment: "")
                        destination.MeasuringInstrumentManage = self.ThermometerManage
                        //システムログ作成、送信
                        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Thermometer")
                        break
                    case 3:
                        // パルスオキシメーター
                        destination.DeviceName = PulseOximeterConst.DeviceName
                        destination.TitleName = NSLocalizedString(PulseOximeterConst.TitleName, comment: "")
                        destination.MeasuringInstrumentManage = self.PulseOximeterManage
                        //システムログ作成、送信
                        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "Pulse Oximeter")
                        break
                    default:
                        destination.DeviceName = ""
                        break
                    }
                }
            }
        }
    }
}
