//
//  DataModel.swift
//  Flowify
//
//  Created by Ramon Martinez on 10/2/24.
//

class DataModel {
    static let shared = DataModel()

    private var formData: [String: String] = [:]

    // update formData
    func updateData(formData: [String: String]) {
        self.formData = formData
    }

    func dictionaryLookUp(forKey key: String, in dictionary: [String: String]) -> String {
        return dictionary[key] ?? ""
    }

    // Read-only access to formData
    var currentFormData: [String: String] {
        return formData
    }
}
