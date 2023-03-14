//
// WatchSettingManageViewController.swift
// ウォッチ管理
//
// MBTLink
//

import UIKit

class WatchSettingManageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - UI部品
    /// ウォッチ設定TableView
    @IBOutlet weak var watchSettingTableView: UITableView!
    
    /// ウォッチ追加ボタン
    @IBOutlet weak var addWatchButton: UIButton!

    // MARK: - Public変数
    /// ウォッチデバイスArray
    public var WatchDeviceArray = [String]()
    /// LANCEBAND管理辞書
    public var WatchManageDic : [String : WatchManageService]!
    /// CRPSmartBand管理辞書
    public var CRPSmartBandManageDic : [String : CRPSmartBandManageService]!
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( WatchSettingManageViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    /// セル選択インデックス
    private var cellSelectIndex : Int = 0

    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()

        // back -> 戻るに変更
        let backbutton = UIBarButtonItem()
        backbutton.title = StringsConst.BACK
        navigationItem.backBarButtonItem = backbutton
        
        // ナビゲーションタイトル
        
        let navbarTitle = UILabel()
        navbarTitle.text = StringsConst.Wearable_Device_Settings
            navbarTitle.font = UIFont.boldSystemFont(ofSize: 17)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = navbarTitle
        
        // デリゲート設定
        self.watchSettingTableView.delegate = self
        self.watchSettingTableView.dataSource = self
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ウォッチArray格納
        self.WatchDeviceArray.removeAll()
        // LANCEBAND
        if self.WatchManageDic.count > 0{
            for device in self.WatchManageDic.keys{
                self.WatchDeviceArray.append(device)
            }
        }
        // CRPSmartBand
        if self.CRPSmartBandManageDic.count > 0{
            for device in self.CRPSmartBandManageDic.keys{
                self.WatchDeviceArray.append(device)
            }
        }
        
        CommonUtil.Print(className: self.className, message: "viewWillAppear表示  デバイス設定数：\(self.WatchDeviceArray.count)件")
        
        // ウォッチ設定済み確認
        if (self.WatchDeviceArray.count > 0) {
            // 設定されている場合はウォッチ追加ボタンを非表示
            addWatchButton.isHidden = true
            CommonUtil.Print(className: self.className, message:"ウォッチ追加ボタン 非表示設定")
        } else {
            // 設定されていない場合はウォッチ追加ボタンを表示
            addWatchButton.isHidden = false
            CommonUtil.Print(className: self.className, message:"ウォッチ追加ボタン 表示設定")
        }
        
        self.watchSettingTableView.reloadData()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 設定デバイス登録
        CommonUtil.SaveWatchDeviceData(watchDeviceArray: self.WatchDeviceArray)
        
        // 遷移元に値を戻す
        let preNc = self.parent as! UINavigationController
        let preVc = preNc.children[0] as! TopViewController
        // ウォッチデバイスArray
        preVc.WatchDeviceArray = self.WatchDeviceArray
        // LANCEBAND管理辞書
        preVc.WatchManageDic = self.WatchManageDic
        // CRPSmartBand管理辞書
        preVc.CRPSmartBandManageDic = self.CRPSmartBandManageDic
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// セル選択、ボタン押下時遷移先設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case CommonConst.Segue.WatchTypeSelect:
            // ウォッチ種類選択画面
            guard let destination = segue.destination as? WatchTypeSelectTableViewController else {
                fatalError("Failed to prepare WatchTypeSelectTableViewController.")
            }
            // LANCEBAND管理辞書
            destination.WatchManageDic = self.WatchManageDic
            // CRPSmartBand管理辞書
            destination.CRPSmartBandManageDic = self.CRPSmartBandManageDic
            break
//        case CommonConst.Segue.WatchSetting :
//            // ウォッチ設定画面
//            guard let destination = segue.destination as? WatchSettingViewController else {
//                fatalError("Failed to prepare WatchSettingViewController.")
//            }
//
//            // ウォッチ管理辞書
//            destination.WatchManageDic = self.WatchManageDic
//
//            // ウォッチ管理サービス
//            if sender == nil{
//                destination.WatchManageService = Array(self.WatchManageDic.values)[self.cellSelectIndex]
//            }
//            else{
//                let watchManage = WatchManageService()
//                destination.WatchManageService = watchManage
//            }
//            break
        default:
            break
        }
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "wearble device selection")
    }
    
    // MARK: - Table view イベント関連
    /// セクション数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 1
    }
    /// セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return self.WatchDeviceArray.count
    }
    
    /// 各セルを生成して返却します。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.WatchDeviceArray[indexPath.row]
        cell.detailTextLabel?.text = ""
        // 矢印を入れる
        cell.accessoryType = .disclosureIndicator
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return cell
    }
    
    // セルが選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // セル選択時インデックス
        self.cellSelectIndex = indexPath.row
        
        let deviceNameKey = self.WatchDeviceArray[indexPath.row]
        if self.WatchManageDic.keys.contains(deviceNameKey){
            // LANCEBAND
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WatchSettingViewController") as! WatchSettingViewController
            // LANCEBAND管理辞書
            vc.WatchManageDic = self.WatchManageDic
            // LANCEBAND管理サービス
            vc.WatchManageService = self.WatchManageDic[deviceNameKey]
            // ウォッチ設定画面に遷移
            navigationController?.pushViewController(vc, animated: true)
        }
        else if self.CRPSmartBandManageDic.keys.contains(deviceNameKey){
            // CRPSmrtBand
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WatchSettingCRPSmartBandViewController") as! WatchSettingCRPSmartBandViewController
            // CRPSmrtBand管理辞書
            vc.WatchManageDic = self.CRPSmartBandManageDic
            // CRPSmrtBand管理サービス
            vc.WatchManageService = self.CRPSmartBandManageDic[deviceNameKey]
            // ウォッチ設定画面に遷移
            navigationController?.pushViewController(vc, animated: true)
        }
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "wearable settings")
    }
    
    // UserDefaultsへの登録処理
    func saveWatchSettingData(){
        // ウォッチArray格納
        self.WatchDeviceArray.removeAll()
        // LANCEBAND
        if self.WatchManageDic.count > 0{
            for device in self.WatchManageDic.keys{
                self.WatchDeviceArray.append(device)
            }
        }
        // CRPSmartBand
        if self.CRPSmartBandManageDic.count > 0{
            for device in self.CRPSmartBandManageDic.keys{
                self.WatchDeviceArray.append(device)
            }
        }
        
        // UserDefaultsへ登録
        CommonUtil.SaveWatchDeviceData(watchDeviceArray: self.WatchDeviceArray)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
}
