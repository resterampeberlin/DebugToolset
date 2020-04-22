//
//  UITestTools.swift
//  DebugToolset
//
//  Created by Markus Nickels on 20.04.20.
//  Copyright © 2020 Resterampe Berlin. All rights reserved.
//

import Foundation

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)

extension View {
    public func accessibility(_ object: Any, identifier: String) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        return accessibility(identifier: String(describing: type(of: object))+"."+identifier)
    }
}
