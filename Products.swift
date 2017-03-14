//
//  Products.swift
//  AirGuitar
//
//  Created by Lucas Luz on 01/12/15.
//  Copyright © 2015 Lucas Luz. All rights reserved.
//

import Foundation

public enum Products {
  
  /// MARK: - Supported Product Identifiers
  public static let AppleWatchConnectivity = "1062018119"
  
  // All of the products assembled into a set of product identifiers.
  fileprivate static let productIdentifiers: Set<ProductIdentifier> = [Products.AppleWatchConnectivity]
  
  /// Static instance of IAPHelper that for rage products.
  public static let store = IAPHelper(productIdentifiers: Products.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
