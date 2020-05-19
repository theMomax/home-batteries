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
    
    @Published var selected: Home?
    
    override init() {
        self.value = HomeStore.shared.homeManager
        self.selected = nil
        super.init()
        
        self.value.delegate = self
    }
    
    deinit {
        self.value.delegate = nil
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard manager == self.value else { return }
        self.value = manager
        if let h = HomeStore.shared.homeManager.homes.filter({h in h.isPrimary}).first {
            self.selected = Home(h)
        } else {
            self.selected = nil
        }
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
