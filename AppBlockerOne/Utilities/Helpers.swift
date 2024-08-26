//
//  Helpers.swift
//  AppBlockerOne
//
//  Created by Fajar Dirham on 8/15/24.
//

import Foundation

let plainJSONEncoder = JSONEncoder()
let plainJSONDecoder = JSONDecoder()

func encodeJSONObj<T: Encodable>(_ obj: T) throws -> String{
    let data = try plainJSONEncoder.encode(obj)
    return String(data: data, encoding: .utf8) ?? "Encoding failed"
}

func decodeJSONObj<T: Decodable>(_ inJSONStr: String) throws -> T {
    let dataJson = inJSONStr.data(using: .utf8)!
    let product = try plainJSONDecoder.decode(T.self, from: dataJson)
    return product
}

var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

func debugPrint(_ message: String){
#if DEBUG
    print(message)
#else
    return
#endif
}
