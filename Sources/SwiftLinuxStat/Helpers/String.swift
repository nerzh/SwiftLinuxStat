//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.06.2020.
//

import Foundation

extension String {

    func clean() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    mutating func cleanSelf() {
        self = self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
