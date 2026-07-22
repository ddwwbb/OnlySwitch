//
//  KeepAwakeSettingView.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2022/8/12.
//

import SwiftUI

struct KeepAwakeSettingView: View {
    @StateObject var vm = KeepAwakeSettingVM()
    
    var body: some View {
        Form {
            // MARK: - Clamshell Section
            Section {
                Toggle(isOn: $vm.preventClamshellSleep) {
                    Text("Prevent sleep when lid closed:".localized())
                }
            } header: {
                Text("Clamshell".localized())
            } footer: {
                Text("Requires power adapter. On battery power, closing the lid still puts the Mac to sleep.".localized())
            }

            // MARK: - Duration Section
            Section {
                Toggle(isOn: $vm.scheduleMode) {
                    HStack {
                        Text("Keep Awake Until After:".localized())
                        Spacer()
                        Picker("", selection: $vm.currentDuration) {
                            ForEach(vm.durationSet, id: \.self) { duration in
                                Text(vm.converTimeDescription(duration: duration)).tag(duration)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 120)
                    }
                }
            } header: {
                Text("Duration".localized())
            }
            
            // MARK: - Schedule Section
            Section {
                Toggle(isOn: $vm.afterMode) {
                    Text("Daily Schedule:".localized())
                }
                
                DatePicker(
                    "from:".localized(),
                    selection: $vm.startDate,
                    displayedComponents: .hourAndMinute
                )
                
                DatePicker(
                    "to:".localized(),
                    selection: $vm.endDate,
                    displayedComponents: .hourAndMinute
                )
                
            } header: {
                Text("Schedule".localized())
            } footer: {
                if vm.isTomorrow {
                    Text("Tomorrow".localized())
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct KeepAwakeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        KeepAwakeSettingView()
    }
}
