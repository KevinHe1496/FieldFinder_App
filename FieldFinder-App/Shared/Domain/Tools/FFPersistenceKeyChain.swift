//
//  FFPersistenceKeyChain.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 8/5/25.
//
import Foundation

@propertyWrapper
class FFPersistenceKeyChain {
   
    private var key: String
    
    init(key: String) {
        self.key = key
    }
    
    
    var wrappedValue: String {
        get {
            return KeyChainFF().loadPK(key: self.key)
        }
        
        set {
            KeyChainFF().savePK(key: self.key, value: newValue)
        }
    }
}
