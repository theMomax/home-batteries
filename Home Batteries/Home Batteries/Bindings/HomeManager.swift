/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A singleton for holding the home manager.
*/

import HomeKit
import Combine

/// - Tag: HomeManager
class HomeManger: NSObject, ObservableObject, HMHomeManagerDelegate {
    
    @Published var value: HMHomeManager
    
    override init() {
        self.value = HomeStore.shared.homeManager
        super.init()
        
        self.value.delegate = self
    }
    
    deinit {
        self.value.delegate = nil
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard manager == self.value else { return }
        self.value = manager
    }

    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        guard manager == self.value else { return }
        self.value = manager
    }

    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        guard manager == self.value else { return }
        self.value = manager
    }

    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        guard manager == self.value else { return }
        self.value = manager
    }

    func homeManager(_ manager: HMHomeManager, didReceiveAddAccessoryRequest request: HMAddAccessoryRequest) {
        guard manager == self.value else { return }
        self.value = manager
    }
    
}
