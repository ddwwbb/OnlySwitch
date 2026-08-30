//
//  SettingVM.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2021/12/11.
//

import Foundation
import SwiftUI
import ComposableArchitecture

enum SettingsItem: String, CaseIterable {
    case General = "General"
    case Customize = "Customize"
    case Shortcuts = "Shortcuts"
    case AirPods = "AirPods"
    case Authenticator = "Authenticator"
    case PomodoroTimer = "Pomodoro Timer"
    case HideMenubarIcons = "Hide Menu Bar Icons"
    case KeepAwake = "Keep Awake"
    case DimScreen = "Dim Screen"
    case NightShift = "Night Shift"
    case KeyLight = "Key Light"
    case iOSRemote = "iOS Remote"
    case About = "About"
}

@MainActor
class SettingsVM: ObservableObject {

    static let shared = SettingsVM()

    @Published var settingItems: [SettingsItem]

    @Published var selection: SettingsItem? = .General

    var keyLightStore = Store(
        initialState: KeyLightFeature.State()) {
            KeyLightFeature()
                ._printChanges()
        }

    var remoteAccessStore = Store(
        initialState: RemoteAccessSettingsFeature.State(
            preferences: RemoteAccessPreferencesClient.liveValue.load()
        )
    ) {
        RemoteAccessSettingsFeature()
    }

    init() {
        settingItems = SettingsItem.allCases
    }

    func toggleSliderbar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(name: .toggleSplitSettingsWindow, object: nil)
        }
    }
}
