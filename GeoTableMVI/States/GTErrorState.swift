//
//  GTErrorState.swift
//  GeoTableMVI
//
//  Created by Jacob on 17/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public class GTErrorState:  GTState
{
    public let Error: GTError
    
    init(delegate: GTStateChangesDelegate, error: GTError)
    {
        self.Error = error
        super.init(.ErrorState, delegate)
    }
}
