//
//  EmailPresenter.swift
//  Flowify
//
//  Created by Ramon Martinez on 11/26/24.
//

class EmailPresenter {
    private var dataModel = DataModel.shared
    
    var fetchEmailRecipient: String {
        dataModel.dictionaryLookUp(forKey: "email", in: dataModel.currentFormData)
    }
    
    var fetchFlowName: String {
        dataModel.dictionaryLookUp(forKey: "name", in: dataModel.currentFormData)
    }
    
    func fetchMergedAsset() {
        
    }
    
    func fetchMultipleMergedAssets() {
        
    }
    
}
