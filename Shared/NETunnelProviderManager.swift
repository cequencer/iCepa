//
//  NETunnelProviderManager.swift
//  iCepa
//
//  Created by Conrad Kramer on 2/18/16.
//  Copyright © 2016 Conrad Kramer. All rights reserved.
//

import NetworkExtension

extension NETunnelProviderManager {
    class func loadOrCreateDefaultWithCompletionHandler(completionHandler: ((NETunnelProviderManager?, NSError?) -> Void)?) {
        self.loadAllFromPreferencesWithCompletionHandler { (managers, error) -> Void in
            if let error = error {
                NSLog("Error: Could not load managers: %@", error)
                if let completionHandler = completionHandler {
                    completionHandler(nil, error)
                }
                return
            }
            
            if let managers = managers {
                if managers.indices ~= 0 {
                    if let completionHandler = completionHandler {
                        completionHandler(managers[0], nil)
                    }
                    return
                }
            }
            
            let config = NETunnelProviderProtocol()
            config.providerConfiguration = ["lol": 1]
            config.providerBundleIdentifier = CPAExtensionBundleIdentifier
            config.serverAddress = "somebridge"
            
            let manager = NETunnelProviderManager()
            manager.protocolConfiguration = config
            manager.localizedDescription = "Tor"
            
            #if os(OSX)
            let authorization: UnsafeMutablePointer<AuthorizationRef> = UnsafeMutablePointer.alloc(1)
            AuthorizationCreate(nil, nil, .Defaults, authorization)
            manager.setAuthorization(authorization.memory)
            #endif
            
            manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
                if let error = error {
                    NSLog("Error: Could not create manager: %@", error)
                }
                
                guard let completionHandler = completionHandler else { return }
                completionHandler(manager, error)
            })
        }
    }
}
