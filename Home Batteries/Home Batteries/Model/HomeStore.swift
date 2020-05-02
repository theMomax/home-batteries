/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A singleton for holding the home manager.
*/

import HomeKit
import Combine

/// - Tag: HomeStore
class HomeStore: NSObject, ObservableObject, HMHomeManagerDelegate {
    
    static let shared = HomeStore()
    
    let homeManager = HMHomeManager()
    
    @Published var homes: [Home] = []
    
    override init() {
        super.init()
        self.homeManager.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard manager == self.homeManager else { return }
        print("updated homes")
        self.homes = manager.homes.map({ home in Home(home)})
    }
    
    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        guard manager == self.homeManager else { return }
        print("added home")
        self.homes.append(Home(home))
    }
    
    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        guard manager == self.homeManager else { return }
        print("removed home")
        self.homes.removeAll(where: { h in
            return home.uniqueIdentifier == h.home.uniqueIdentifier
        })
    }
}
