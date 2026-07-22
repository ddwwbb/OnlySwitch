//
//  SwitchManager.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2021/12/14.
//

import Foundation
import AppKit
import LaunchAtLogin
import Switches
import Defines

final class SwitchManager: @unchecked Sendable {
    static let shared = SwitchManager()
    
    private var shownSwitchMap = [SwitchType: SwitchProvider?]()
    
    @MainActor var barVMList: [SwitchBarVM] {
        let sortedSwitchMap = shownSwitchMap.sorted() {$0.key.rawValue < $1.key.rawValue}
        var switchBarVMs = [SwitchBarVM]()
        for (_, value) in sortedSwitchMap {
            if let aswitch = value {
                let switchBarVM = SwitchBarVM(switchOperator: aswitch)
                switchBarVMs.append(switchBarVM)
            }
        }
        return switchBarVMs
    }
    
    var shownSwitchCount:Int {
        shownSwitchMap.count
    }
    
    func register(aswitch: SwitchProvider) {
        shownSwitchMap[aswitch.type] = aswitch
        NotificationCenter.default.post(name: .changeSettings, object: nil)
    }
    
    func unregister(for type: SwitchType) {
        shownSwitchMap.removeValue(forKey: type)
        shownSwitchMap[type]? = nil
        NotificationCenter.default.post(name: .changeSettings, object: nil)
    }
    
    func getSwitch(of type: SwitchType) -> SwitchProvider? {
        return shownSwitchMap[type] ?? nil
    }
    
    func shortcutsBarVMList() -> [ShortcutsBarVM] {
        let shortcuts = Preferences.shared.shortcutsDic
        var list = [ShortcutsBarVM]()
        guard let shortcuts = shortcuts, shortcuts.count > 0 else {
            return list
        }
        
        let sortedDic = shortcuts.sorted{
            return $0.key > $1.key
        }
        
        for (name, toggle) in sortedDic {
            if toggle {
                list.append(ShortcutsBarVM(name: name))
            }
        }
        
        return list
    }

    @MainActor
    func registerSwitchesShouldShow() {
        let state = getAllSwitchState()
        for type in SwitchType.allCases {
            let bitwise = type.rawValue
            let shouldShow = (state & bitwise == 0) ? false : true
            if shouldShow {
                self.register(aswitch: type.getNewSwitchInstance())
            }
        }
    }
    
    func getAllSwitchState() -> UInt64 {
        if let stateStr = UserDefaults.standard.string(forKey: UserDefaults.Key.SwitchState) {
            let state = UInt64(stateStr) ?? 16383 // binary 11111111111111
            return state
        } else {
            UserDefaults.standard.set("16383", forKey: UserDefaults.Key.SwitchState)
            UserDefaults.standard.synchronize()
            return 16383
        }
    }
}
