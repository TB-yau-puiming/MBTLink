//
// UserSettingTableViewController.swift
// ユーザー情報設定
//
// MBTLink
//

import UIKit

class UserSettingTableViewController: UITableViewController{
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    /// クラス名
    private let className = String(String(describing: ( UserSettingTableViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()

    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var personalID: UITextField!
    @IBOutlet weak var serialNum: UITextField!
    @IBOutlet weak var dataServerURL: UITextField!
    //userDefaults key
    let key = "key" + "_" + "userSettingData"
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        initialValueSet()
        dataServerURL.autocorrectionType = .no
        
        self.personalID.delegate = self
        self.serialNum.delegate = self
        self.dataServerURL.delegate = self
        
        // ナビゲーションタイトル
        
        let navbarTitle = UILabel()
        navbarTitle.text = StringsConst.Server_Settings
            navbarTitle.font = UIFont.boldSystemFont(ofSize: 17)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
        self.navigationBar.titleView = navbarTitle
        
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
            return 3
            
        case 1:
            return 1
        
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
            return 100
            //return UITableView.automaticDimension
        case 1:
            return 30
        
        default:
            return 0
        }
    }

    /// セクションのヘッダー
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let sectionHeader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 100))

        let sectionText = UILabel()
        //let maxSize = CGSize(width: self.view.frame.width - 30, height: CGFloat.greatestFiniteMagnitude)
        //let size = sectionText.sizeThatFits(maxSize)
        sectionText.frame = CGRect.init(x: 15, y: 5, width: sectionHeader.frame.width-30, height: sectionHeader.frame.height-10)
        //sectionText.frame = CGRect.init(x: 15, y: 5, width: sectionHeader.frame.width-30, height: CGFloat.greatestFiniteMagnitude)
        //sectionText.frame = CGRect(origin: CGPoint(x:15, y: 5), size: size)
        sectionText.font = .systemFont(ofSize: 14)
        sectionText.minimumScaleFactor = 0.5
        sectionText.lineBreakMode = .byWordWrapping
        sectionText.numberOfLines = 0
        sectionText.adjustsFontSizeToFitWidth = true
        sectionText.textColor = .gray
        //sectionText.textColor = .systemGray
        sectionHeader.backgroundColor = .systemGray6
        if (section == 0) {
            sectionText.text = StringsConst.USER_SETTING_HEADER_A + "\n" + StringsConst.USER_SETTING_HEADER_B
        }else{
            sectionText.text = ""
        }
        sectionHeader.addSubview(sectionText)
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return sectionHeader
    }
    

/*
    /// ヘッダーの文章を設定
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var header:String = ""
        
        if(section == 0){
            
            header.append(StringsConst.USER_SETTING_HEADER_A)
            header.append("\n")
            header.append(StringsConst.USER_SETTING_HEADER_B)
            //header = StringsConst.USER_SETTING_HEADER_A + "\n" + StringsConst.USER_SETTING_HEADER_B
        }
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return header
    }
*/
    ///設定値クリアボタン押下イベント
    @IBAction func pushClearButton(_ sender: Any) {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        ///保存している値を削除
        UserDefaults.standard.removeObject(forKey: key)
        personalID.text = ""
        serialNum.text = ""
        dataServerURL.text = ""
        
    }
    //戻るボタン押下時
    override func viewWillDisappear(_ animated: Bool) {
        personalID.endEditing(true)
        serialNum.endEditing(true)
        dataServerURL.endEditing(true)
        ///設定値の保存
        registerSettings()
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    ///設定値の保存
    func registerSettings(){
        
        let persolanID: String = personalID.text!
        let serialNumber: String = serialNum.text!
        let serverURL: String = dataServerURL.text!
        print(persolanID + "," + serialNumber + "," + serverURL)
        let data = UserSettingData(personalID: persolanID, serialNumber: serialNumber, dataServerURL: serverURL)
        UserDefaults.standard.setUserSetting(data, key)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    //画面遷移時の初期値セット
    func initialValueSet(){
        let userSettings = UserDefaults.standard.getUserSetting(key)
        personalID.text = userSettings?.personalID
        serialNum.text  = userSettings?.serialNumber
        dataServerURL.text = userSettings?.dataServerURL
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
}

extension UserDefaults{
    
    func setUserSetting(_ Data:UserSettingData,_ key:String){
        let data = try! NSKeyedArchiver.archivedData(withRootObject: Data, requiringSecureCoding: false)
        self.set(data, forKey: key)
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "(UserSettingTableViewController)" , functionName: #function , message: "")
    }
    
    func getUserSetting(_ key:String) -> UserSettingData?{
        if let storeData = self.object(forKey: key) as? Data {
            if let unarchivedObject = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storeData) as? UserSettingData{
                return unarchivedObject
            }
        }
        //システムログ作成、送信
        //アプリクラッシュ
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "(UserSettingTableViewController)" , functionName: #function , message: "")
        return nil
    }
}

// storyboardにて最大文字数を指定できるように拡張
private var maxLengths = [UITextField: Int]()

extension UITextField {

    // storyboardの入力値を取得、設定する
    @IBInspectable var maxLength: Int {
        get {
            guard let length = maxLengths[self] else {
                return Int.max
            }

            return length
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(limitLength), for: .editingChanged)
        }
    }

    // textFieldの入力文字数を制御をする
    @objc func limitLength(textField: UITextField) {
        guard let prospectiveText = textField.text, prospectiveText.count > maxLength else {
            return
        }

        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)

        #if swift(>=4.0)
            text = String(prospectiveText[..<maxCharIndex])
        #else
            text = prospectiveText.substring(to: maxCharIndex)
        #endif

        selectedTextRange = selection
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "(UserSettingTableViewController)" , functionName: #function , message: "")

    }

}

// 許容範囲外文字を除去し、textFieldに反映させる
extension UserSettingTableViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "(UserSettingTableViewController)" , functionName: #function , message: "")
        switch textField{
        case personalID:
            guard let personalIDFixed = personalID.text else { return }
            
            personalID.text = StringUtil.fixInputStr(text: personalIDFixed)
            
        case serialNum:
            guard let serialNumFixed = serialNum.text else { return }
            
            serialNum.text = StringUtil.fixInputStr(text: serialNumFixed)
        
        case dataServerURL:
            guard let dataServerURLFixed = dataServerURL.text else { return }
            
            dataServerURL.text = StringUtil.fixInputStr(text: dataServerURLFixed)
            
        default:
            return
        }
        
    }
}

