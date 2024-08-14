//
//  NewGroupView.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/13/24.
//

import SwiftUI

struct NewGroupView: View {
    @State var isKeyboardOpen: Bool = false
    
    @State private var groupName: String = ""
    @State private var appsSelected: String = "TODO"
    @State private var isBlockEnabled: Bool = false
    @State private var isStrictBlock: Bool = false
    @State private var maxOpensPerDay: Int16 = 5
    @State private var durationPerOpenM: Int16 = 5
    @State private var openMethod: String = "Tap 5 times"
    @State private var startTimeRawInt: Int16 = 0
    @State private var endTimeRawInt: Int16 = 2359


    var body: some View {
        Color.bg
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 16) {
                    SettingGroupView("Group Name") {
                        TextField("E.g Socials", text: $groupName)
                            .labelsHidden()
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.interactable))
                            .foregroundColor(.black)
                    }
                    SettingGroupView("Apps") {
                        TextField("TODO", text: $appsSelected)
                            .labelsHidden()
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.interactable))
                            .foregroundColor(.black)
                    }
                    SettingGroupView("Block settings", spacing: 12) {
                        BooleanSettingsView("Blocking enabled", value: $isBlockEnabled)
                        BooleanSettingsView("Strict block", value: $isStrictBlock)
                        NumberSettingsView("Maximum opens per day", value: $maxOpensPerDay,  min: 0, max: 100)
                        NumberSettingsView("Duration per open (minutes)", value: $durationPerOpenM, min: 1, max: 120)
                        PickerSettingsView("Open method", value: $openMethod, optionsList: ["Tap 5 times", "None"])
                    }
                    SettingGroupView("Block schedule", spacing: 12) {
                        TimeSettingView("Start", rawIntValue: $startTimeRawInt )
                        TimeSettingView("End", rawIntValue: $endTimeRawInt )
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .toolbar {
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
                    }
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
    @Binding var value: Int16
    var min: Int16?
    var max: Int16?
    
    var formatter: Formatter
    
    init(_ name: String, value: Binding<Int16>){
        self.name  = name
        self._value = value
        self.formatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    }
    
    init(_ name: String, value: Binding<Int16>, min: Int16?, max: Int16?){
        self.name  = name
        self._value = value
        self.formatter = {
            let formatter = BoundFormatter()
            if max != nil {
                formatter.setMax(Int(max!) )
            }
            if min != nil {
                formatter.setMin(Int(min!))
            }
            return formatter
        }()
        self.min = min
        self.max = max
    }

    var body: some View {
        HStack{
            Text(name)
            Spacer()
            TextField(name, value: $value, formatter: self.formatter, prompt: Text("..."))
                .multilineTextAlignment(.center)
                .labelsHidden()
                .frame(width: 65, height: 32)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.interactable))
                .keyboardType(.numberPad)
                .onChange(of: value) {
                    if max != nil {
                        if value > max! {
                            value = max!
                        }
                    }
                    if min != nil {
                        if value < min! {
                            value = min!
                        }
                    }
                }
        }
    }
}

struct PickerSettingsView: View {
    let name: String
    @Binding var value: String
    var optionsList: Array<String>
    
    
    init(_ name: String, value: Binding<String>, optionsList: Array<String>){
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
                        Text(optionsList[idx]).tag(optionsList[idx])
                    }
                }
            } label: {
                Text(value)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .frame(width: 130, height: 32)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.interactable))
            }
        }
    }
}

struct TimeSettingView: View {
    @Binding var rawIntValue: Int16
    let name: String
    
    init(_ name: String, rawIntValue: Binding<Int16>){
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
            DatePicker(name, selection: dateValue, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.interactable))
        }
    }
    
    private func convertRawIntToDate(rawInt: Int16) -> Date{
        // Stringify rawIntValue
        var strValue: String = String(rawIntValue)
        let deficit = strValue.count - 4
        if deficit > 0 {
            for _ in 0...deficit {
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
    
    private func convertDateToRawInt(inDate: Date) -> Int16 {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: inDate)
        let hourStr = String(dateComponents.hour!)
        let minStr = String(dateComponents.minute!)
        
        return Int16("\(hourStr)\(minStr)") ?? 0
    }
}

#Preview {
    NewGroupView()
}
