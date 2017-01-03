//
//  Utility.swift
//  DemoProject
//
//  Created by North Overby on 1/2/17.
//  Copyright © 2017 Makeblock. All rights reserved.
//

import Foundation

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}
