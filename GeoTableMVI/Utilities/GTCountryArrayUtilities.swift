//
//  GTCountryArrayUtilities.swift
//  GeoTableMVI
//
//  Created by Jacob on 19/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation
import RealmSwift

public class GTCountryArrayUtilities
{
    //Sort by property function
    public func SortCountries(with property: GTCountry.Property, by ascending: Bool, selectedCountry: GTCountry? = nil) -> [GTCountry]
    {
        let realm = try! Realm()
        if selectedCountry != nil
        {
            return Array(realm.object(ofType: GTCountry.self, forPrimaryKey: selectedCountry!.Name)!.Bordering.sorted(byKeyPath: property.rawValue, ascending: ascending))
        }
        return Array(realm.objects(GTCountry.self).sorted(byKeyPath: property.rawValue, ascending: ascending))
    }
}
