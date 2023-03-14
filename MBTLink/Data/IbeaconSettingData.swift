//
//  IbeaconSettingData.swift
//  MBTLink
//
//  Created by 開発用 treebell 002 on 2022/01/11.
//

import Foundation.NSObject

class IbeaconSettingData: NSObject, NSCoding {

    /// name
    var Name : String?
    /// uuid
    var Uuid : String?
    /// majorId
    var MajorId : String?
    /// minorId
    var MinorId : String?
    
    
    init(Name: String?, Uuid: String?, MajorId: String?, MinorId: String?) {
        self.Name = Name
        self.Uuid = Uuid
        self.MajorId = MajorId
        self.MinorId = MinorId
    }
    
    required init?(coder: NSCoder) {
        // name
        self.Name = (coder.decodeObject(forKey: "iBeaconName") as? String) ?? ""
        // uuid
        self.Uuid = (coder.decodeObject(forKey: "iBeaconUuid") as? String) ?? ""
        // majorId
        self.MajorId = (coder.decodeObject(forKey: "iBeaconMajorId") as? String) ?? ""
        // minorId
        self.MinorId = (coder.decodeObject(forKey: "iBeaconMinorId") as? String) ?? ""
    }
    
    func encode(with coder: NSCoder) {
        // name
        coder.encode(self.Name, forKey: "iBeaconName")
        // uuid
        coder.encode(self.Uuid, forKey: "iBeaconUuid")
        // majorId
        coder.encode(self.MajorId, forKey: "iBeaconMajorId")
        // minorId
        coder.encode(self.MinorId, forKey: "iBeaconMinorId")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: "IbeaconSettingData" , functionName: #function , message: "")
    }
}
