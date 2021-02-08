//
//  GTStateChangesDelegate.swift
//  GeoTableMVI
//
//  Created by Jacob on 17/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import Foundation

public protocol GTStateChangesDelegate: class
{
    func UpdateChanges()
    func ChangeState(_ newState: GTState)
}
