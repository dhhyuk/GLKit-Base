//
//  Log.swift
//  GLKit Study
//
//  Created by 김동혁 on 2017. 4. 12..
//  Copyright © 2017년 dhyuk. All rights reserved.
//

import Foundation

class Log {
    public static func d(_ tag: String, _ message: Any) {
        print("Debug \(tag) : \(message)")
    }
    
    public static func e(_ tag: String, _ message: Any) {
        print("\u{001B}[0;31mError \(tag) : \(message)")
    }
}
