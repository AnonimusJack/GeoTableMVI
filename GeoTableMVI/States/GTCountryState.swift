//
//  GTCountryState.swift
//  GeoTableMVI
//
//  Created by Jacob on 17/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public class GTCountryState: GTState
{
    public var BorderingCountries: [GTCountry]
    public let SelectedCountry: GTCountry
    
    init(delegate: GTStateChangesDelegate, selectedCountry: GTCountry)
    {
        self.SelectedCountry = selectedCountry
        self.BorderingCountries = Array(SelectedCountry.Bordering)
        super.init(.SelectedCountryState, delegate)
    }
}
