//
//  GTAllCountriesState.swift
//  GeoTableMVI
//
//  Created by Jacob on 17/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public class GTAllCountriesState: GTState, GTAsyncDataReceiver
{
    public var CountriesData: [GTCountry] = []
    public var IsLoading: Bool = true
    
    init(delegate: GTStateChangesDelegate)
    {
        super.init(.AllCountriesState, delegate)
        GTCountryDataRepository.RequestData(asyncHandler: self)
    }
    
    public func HandleSuccess(data: [GTCountry])
    {
        CountriesData = data
        IsLoading = false
        DispatchQueue.main.async {
            self.stateDelegate?.UpdateChanges()
        }
    }
    
    public func HandleError(error: GTError)
    {
        DispatchQueue.main.async {
            self.stateDelegate?.ChangeState(GTErrorState(delegate: self.stateDelegate!, error: error))
        }
    }
}
