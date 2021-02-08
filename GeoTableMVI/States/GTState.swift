//
//  GTState.swift
//  GeoTableMVI
//
//  Created by Jacob on 17/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public enum GTStateType
{
    case AllCountriesState
    case SelectedCountryState
    case ErrorState
}

public class GTState
{
    weak var stateDelegate: GTStateChangesDelegate?
    public let StateType: GTStateType
    
    init(_ type: GTStateType, _ delegate: GTStateChangesDelegate)
    {
        self.StateType = type
        self.stateDelegate = delegate
    }
    
    public func OnStateLoadedInDelegate()
    {
        stateDelegate?.UpdateChanges()
    }
}
