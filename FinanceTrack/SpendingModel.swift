//
//  SpendingModel.swift
//  FinanceTrack
//
//  Created by vlad on 8/8/21.
//  Copyright © 2021 Vlad Lazoryk. All rights reserved.
//

import Foundation
import RealmSwift

class SpendingModel: Object {
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
}

class Limit: Object {
    @objc dynamic var limitSum = ""
    @objc dynamic var limitDate = NSDate()
    @objc dynamic var limitLastDay = NSDate()
    
}
