//
//  Utils.swift
//  SceneSwitcher
//
//  Created by Nick Stull on 4/18/25.
//
import Foundation

extension String {
    func snakeified() -> String {
        let allowed = self.lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        return allowed
    }
}

