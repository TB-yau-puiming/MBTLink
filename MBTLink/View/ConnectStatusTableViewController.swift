//
// ConnectStatusTableViewController.swift
// 接続状態TableView
//
// MBTLink
//
import UIKit

class ConnectStatusTableViewController: UITableViewController {
    
    // MARK: - UI部品
    /// 接続状態TableView
    @IBOutlet var connectStatusTableView: UITableView!
    
    // MARK: - Private変数
    /// トップ画面ViewController
    private var topVc : TopViewController!
    /// クラス名
    private let className = String(String(describing: ( ConnectStatusTableViewController.self)).split(separator: "-")[0])
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //トップ画面ViewController
        self.topVc = (self.parent as! TopViewController)
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    // MARK: - Public Methods
    /// 接続状態TableViewリロード
    func TableViewReloadData(){
        self.connectStatusTableView.reloadData()
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    // MARK: - Table view イベント関連
    /// セルの数を返す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        if self.topVc == nil{
            return 0
        }
        else{
            return self.topVc.WatchDeviceArray.count
        }
    }
    
    // 各セルを生成して返却します。
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var message : String = ""
        var state :CBPeripheralState = CBPeripheralState.disconnected
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        // デバイス名
        let deviceName = self.topVc.WatchDeviceArray[indexPath.row]
        cell.textLabel?.text = deviceName
        // 接続状態
        if self.topVc.WatchManageDic.keys.contains(deviceName){
            // LANCEBAND
            let manage = self.topVc.WatchManageDic[deviceName]

            if let peripheral = manage!.WatchBleService.GetConnectPeripheral() {
                state = peripheral.state
            }
            else{
                state = CBPeripheralState.disconnected
            }
        }
        else if self.topVc.CRPSmartBandManageDic.keys.contains(deviceName){
            // CRPSmartBand
            let manage = self.topVc.CRPSmartBandManageDic[deviceName]

            if let discovery = manage!.WatchBleService.GetConnectDiscovery() {
                state = discovery.remotePeripheral.state
            }
            else{
                state = CBPeripheralState.disconnected
            }
        }
        
        if state == CBPeripheralState.connected{
            message = StringsConst.CONNECTED
        }
        else{
            message = StringsConst.NOT_CONNECTED
        }

        cell.detailTextLabel?.text = message
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return cell
    }
    
    // ヘッダーに設定するViewを設定する
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
            
        //ヘッダーにするビューを生成
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120)
        view.backgroundColor = UIColor.white
            
        //ヘッダーに追加するラベルを生成
        let headerLabel = UILabel()
        headerLabel.frame =  CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30)
        headerLabel.text = StringsConst.WATCH_CONNECTION_STATUS
        headerLabel.textColor = UIColor.black
        headerLabel.textAlignment = NSTextAlignment.left
        view.addSubview(headerLabel)
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return view
    }
}
