//
//  GTCountryDataRepository.swift
//  GeoTableMVI
//
//  Created by Jacob on 15/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

class GTCountryDataRepository
{
    private static var Data: [GTCountry]?
    private static let countriesCount = 250


    public static func RequestData(asyncHandler: GTAsyncDataReceiver)
    {
        DispatchQueue(label: "com.geo_table.data_request", qos: .utility).async {
            autoreleasepool {
                if Data == nil || Data!.count != countriesCount
                {
                    do
                    {
                        let realm = try Realm()
                        if !requestDataFromLocal(realm)
                        {
                            return requestDataFromServer(asyncHandler)
                        }
                    }
                    catch
                    {
                        return asyncHandler.HandleError(error: .GTRealmInitializationError)
                    }
                }
                return asyncHandler.HandleSuccess(data: Data!)
            }
        }
    }
    
    private static func requestDataFromLocal(_ realm: Realm) -> Bool
    {
        Data = Array(realm.objects(GTCountry.self).freeze())
        if Data == nil || Data!.count != countriesCount
        {
            return false
        }
        return true
    }
    
    private static func requestDataFromServer(_ handler: GTAsyncDataReceiver)
    {
        let dataRequest = AF.request("https://restcountries.eu/rest/v2/all?fields=name;alpha3Code;area;borders;nativeName")
        dataRequest.responseJSON { response in
            switch response.result
            {
                case .success(let value):
                    if let result = value as Any?
                    {
                        if let processError = processJSONToCountries(json: result as! [[String : Any]])
                        {
                            handler.HandleError(error: processError)
                        }
                        else
                        {
                            do
                            {
                                var realm = try Realm()
                                if let saveError = saveToLocal(&realm)
                                {
                                    handler.HandleError(error: saveError)
                                }
                                else
                                {
                                    return handler.HandleSuccess(data: Data!)
                                }
                            }
                            catch
                            {
                                return handler.HandleError(error: .GTRealmInitializationError)
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                    return handler.HandleError(error: .GTServerError)
            }
        }
    }
    
    private static func processJSONToCountries(json: [[String : Any]]) -> GTError?
    {
        let jsonCount = json.count
        if jsonCount != 0 && jsonCount == countriesCount
        {
            Data = []
            for countryJson in json
            {
                Data!.append(GTCountry(json: countryJson))
            }
            //O(Nlog(N)) because bordering countries will not be equals to the entire array
            for countryJson in json
            {
                let currentCountry = Data!.first(where: { (country) -> Bool in country.Name == countryJson["name"] as! String})
                for countryAplhaCode in countryJson["borders"] as! [String]
                {
                    let borderingCountry = Data!.first(where: { (country) -> Bool in country.Alpha3Code == countryAplhaCode})
                    currentCountry!.Bordering.append(borderingCountry!)
                }
            }
            return nil
        }
        else
        {
            return .GTServerError
        }
    }
    
    private static func saveToLocal(_ realm: inout Realm) -> GTError?
    {
        do
        {
            try realm.write({ realm.add(Data!) })
            realm = realm.freeze()
        }
        catch
        {
            return .GTRealmWriteError
        }
        return nil
    }
}
