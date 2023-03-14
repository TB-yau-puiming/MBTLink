//
//  UserSettingData.swift
//  MBTLink
//
//  Created by school on 2022/03/04.
//

import Foundation.NSObject

class UserSettingData:NSObject, NSCoding  {
    
    /// personalID
    var personalID : String?
    /// serialNumber
    var serialNumber : String?
    /// dataServerURL
    var dataServerURL : String?
    
    init(personalID: String?, serialNumber: String?, dataServerURL: String?) {
        self.personalID = personalID
        self.serialNumber = serialNumber
        self.dataServerURL = dataServerURL
    }
    
    func encode(with coder: NSCoder) {
        // personalID
        coder.encode(self.personalID, forKey: "personalID")
        // serialNumber
        coder.encode(self.serialNumber, forKey: "serialNumber")
        // dataServerURL
        coder.encode(self.dataServerURL, forKey: "dataServerURL")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "UserSettingData" , functionName: #function , message: "")
    }
    
    required init?(coder: NSCoder) {
        // personalID
        self.personalID = (coder.decodeObject(forKey: "personalID") as? String) ?? ""
        // serialNumber
        self.serialNumber = (coder.decodeObject(forKey: "serialNumber") as? String) ?? ""
        // dataServerURL
        self.dataServerURL = (coder.decodeObject(forKey: "dataServerURL") as? String) ?? ""
    }
    

}
