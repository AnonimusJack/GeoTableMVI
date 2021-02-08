//
//  GTCountry.swift
//  GeoTableMVI
//
//  Created by Jacob on 15/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation
import RealmSwift

public class GTCountry: Object
{
    public enum Property: String
    {
        case Name
        case NativeName
        case Alpha3Code
        case Area
        case Bordering
    }
    @objc dynamic var Name: String = ""
    @objc dynamic var NativeName: String = ""
    @objc dynamic var Alpha3Code: String = ""
    @objc dynamic var Area: Double = 0
    dynamic var Bordering = List<GTCountry>()
    
    override init() { super.init() }
    init(json: [String : Any])
    {
        super.init()
        self.Name = json["name"] as? String ?? ""
        self.NativeName = json["nativeName"] as? String ?? ""
        self.Alpha3Code = json["alpha3Code"] as? String ?? ""
        self.Area = json["area"] as? Double ?? 0
    }
    
    public override static func primaryKey() -> String?
    {
        return "Name"
    }
}
