//
//  NewGroupView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI
import FamilyControls

struct AppGroupSettingsView: View, KeyboardReadable {
    @Environment(AppGroupSettingsModel.self) private var sm
    @State private var errorAlertMsg: String = ""
    @Environment(\.presentationMode) var presentationMode
    let onSave: () -> (Bool, String?)
    let navTitle: String
    
    private var isShowAlert: Binding<Bool> {
        Binding(get: {
            return !errorAlertMsg.isEmpty
        }, set: {
            if !$0 {
                errorAlertMsg = ""
            }
        })
    }

    
    private var showStrictBlockOption: Bool {
        return sm.s_blockingEnabled
    }
    
    private var showTemporaryOpenGroup: Bool {
        return !sm.s_strictBlock && sm.s_blockingEnabled
    }

    private var showScheduleGroup: Bool {
        return sm.s_blockingEnabled
    }

    var body: some View {
        @Bindable var sm = sm
        
        Color.bg
            .ignoresSafeArea()
            .overlay {
                ScrollView {
                    VStack(spacing: 35) {
                        SettingGroupView("Group Name") {
                            TextField("group name", text: $sm.groupName, prompt: Text("e.g Socials").foregroundStyle(.fgFaint))
                                .labelsHidden()
                                .padding()
                                .settingBlockBG()
                                .foregroundColor(.black)
                        }
                        SettingGroupView("Apps") {
                            AppSelectionSettingView(faSelection: $sm.faSelection)
                        }
                        SettingGroupView("Block", spacing: 12) {
                            BooleanSettingsView("Blocking enabled", value: $sm.s_blockingEnabled.animation(Animation.smooth(duration: 0.4)))
                            if showStrictBlockOption{
                                BooleanSettingsView("Strict block", value: $sm.s_strictBlock.animation(Animation.smooth(duration: 0.4)))
                            }
                        }
                        if showTemporaryOpenGroup {
                            SettingGroupView("Temporary open", spacing: 12) {
                                NumberSettingsView("Maximum opens per day", value: $sm.s_maxOpensPerDay)
                                NumberSettingsView("Duration per open (minutes)", value: $sm.s_durationPerOpenM)
                                OpenMethodsPickerSettingsView("Open method", value: $sm.s_openMethod, optionsList: OpenMethods.allCases)
                            }
                        }
                        if showScheduleGroup {
                            SettingGroupView("Schedule", spacing: 12) {
                                TimeSettingView("Start", rawIntValue: $sm.s_blockSchedule_start )
                                TimeSettingView("End", rawIntValue: $sm.s_blockSchedule_end )
                            }
                            .padding(.bottom, 30)
                        }
                        Button(action: {}) {
                            Text("Delete")
                                .foregroundStyle(Color.danger)
                        }
                        Spacer()
                    }
                    .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                        if !newIsKeyboardVisible {
                            sm.handleKeyboardClose()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                sm.rollbackLocalChanges()
                                presentationMode.wrappedValue.dismiss()
                            }){
                                Text("Cancel")
                                    .foregroundStyle(Color.danger)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                let saveRes = onSave()
                                let isSuccess = saveRes.0
                                if !isSuccess {
                                    errorAlertMsg = saveRes.1 ?? "Empty error"
                                }
                                else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            
                            }){
                                Text("Save")
                                    .foregroundStyle(Color.accent)
                            }
                            .alert(errorAlertMsg, isPresented: isShowAlert) {}
                        }
                        ToolbarItemGroup(placement: .keyboard) {
                            HStack{
                                Spacer()
                                Button("Done") {
                                    // Dismiss keyboard
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil
                                    )
                                }
                            }
                            .foregroundStyle(.accent)
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .navigationTitle(navTitle)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
    }
}

struct SettingGroupView<Content: View>: View {
    let groupName: String
    @ViewBuilder let content: Content
    var spacing: CGFloat
    
    init(_ groupName: String, @ViewBuilder content: ()-> Content) {
        self.content = content()
        self.groupName = groupName
        self.spacing = 6
    }
    
    init(_ groupName: String, spacing: CGFloat, @ViewBuilder content: ()-> Content) {
        self.content = content()
        self.groupName = groupName
        self.spacing = spacing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing){
            Text(groupName)
                .fontWeight(.bold)
            content
        }
    }
}

struct BooleanSettingsView: View {
    let name: String
    @Binding var value: Bool
    
    init(_ name: String, value: Binding<Bool>){
        self.name  = name
        self._value = value
    }
    
    var body: some View {
        HStack{
            Text(name)
            Spacer()
            Toggle(name, isOn: $value)
                .labelsHidden()
                .tint(.accent)
        }
    }
}

struct NumberSettingsView: View {
    let name: String
    @Binding var value: Int
    
    init(_ name: String, value: Binding<Int>){
        self.name  = name
        self._value = value
    }
    
    var stringValue: Binding<String>{
        Binding(get: {
            return String(value)
        }, set: { newValue in
            if newValue == ""{
                value = 0
            }
            else {
                value = Int(newValue) ?? 0
            }
        })
    }

    
    var body: some View {
        HStack{
            Text(name)
            Spacer()
            TextField(name, text: stringValue, prompt: Text("...").foregroundStyle(.fgFaint))
                .multilineTextAlignment(.center)
                .labelsHidden()
                .frame(width: 65, height: 32)
                .settingBlockBG()
                .keyboardType(.numberPad)
        }
    }
}

struct OpenMethodsPickerSettingsView: View {
    let name: String
    @Binding var value: OpenMethods
    var optionsList: [OpenMethods]
    
    
    init(_ name: String, value: Binding<OpenMethods>, optionsList: [OpenMethods]){
        self.name  = name
        self._value = value
        self.optionsList = optionsList
    }
    
    var body: some View {
        HStack{
            Text(name)
            Spacer()
            Menu {
                Picker(selection: $value, label: EmptyView()) {
                    ForEach(0 ..< optionsList.count, id: \.self) { idx in
                        Text(optionsList[idx].rawValue).tag(optionsList[idx])
                    }
                }
            } label: {
                Text(value.rawValue)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .frame(width: 130, height: 32)
                    .settingBlockBG()
            }
        }
    }
}

struct TimeSettingView: View {
    @Binding var rawIntValue: Int
    let name: String
    
    init(_ name: String, rawIntValue: Binding<Int>){
        self.name = name
        self._rawIntValue = rawIntValue
    }
    
    var dateValue: Binding<Date>{
            Binding(get: {
                return convertRawIntToDate(rawInt: rawIntValue)
            }, set: {
                rawIntValue =  convertDateToRawInt(inDate: $0)
            })
        }
    
    var body: some View {
        HStack{
            Text(name)
            Spacer()
            Text(dateValue.wrappedValue, style: .time)
                .frame(width: 130, height: 32)
                .settingBlockBG()
                .overlay {
                DatePicker(name, selection: dateValue, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorMultiply(.clear)
            }
        }
    }
    
    private func convertRawIntToDate(rawInt: Int) -> Date{
        // Stringify rawIntValue
        var strValue: String = String(rawIntValue)
        let deficit = 4 - strValue.count
        if deficit > 0 {
            for _ in 0..<deficit {
                strValue = "0\(strValue)"
            }
        }
        
        let hourStr = strValue.prefix(2)
        let minStr = strValue.suffix(2)
        
        var components = DateComponents()
        components.hour = Int(hourStr) ?? 0
        components.minute = Int(minStr) ?? 0
        
        let date = Calendar.current.date(from: components) ?? .now
        
        return date
    }
    
    private func convertDateToRawInt(inDate: Date) -> Int {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: inDate)
        let hourStr = String(dateComponents.hour!)
        var minStr = String(dateComponents.minute!)
        if minStr.count < 2 {
            minStr = "0\(minStr)"
        }
        
        return Int("\(hourStr)\(minStr)") ?? 0
    }
}

struct AppGroupSettingsView_Preview: PreviewProvider {
    struct Container: View {
        @State private var sm: AppGroupSettingsModel = AppGroupSettingsModel(coreDataContext: PersistenceController.preview.container.viewContext)
        
        var body: some View {
            NavigationStack{
                AppGroupSettingsView(onSave: {return (false, "Save clicked!")}, navTitle: "Settings")
                    .environment(sm)
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
