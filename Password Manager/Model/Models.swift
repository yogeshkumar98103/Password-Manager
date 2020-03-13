////
////  Models.swift
////  Password Manager
////
////  Created by Yogesh Kumar on 11/12/19.
////  Copyright © 2019 Yogesh Kumar. All rights reserved.
////
//
//import Foundation
//
//enum CerdentialType{
//    case Account
//    case Card
//}
//
//struct SecurityQuestion{
//    var question: String
//    var answer: String
//}
//
//class Credential: NSObject{
//    override init(){
//        super.init()
//    }
//}
//
//class AccountCredentials: Credential{
//    var password: String?
//    var username: String?
//    var email: String?
//    var url: String?
//    var securityQuestion: [SecurityQuestion]?
//    var extras: [String: String]?
//}
//
//class CardCredentials: Credential{
//    var accountNumber: String?
//    var ifscCode: String?
//    var cvv: String?
//    var cardHolderName: String?
//    var expiryDate: Date?
//    var extras: [String: String]?
//}
//
//class DataDetails{
//    var type: CerdentialType
//    var data: Credential
//
//    init(_ type: CerdentialType, _ data: Credential){
//        self.type = type
//        self.data = data
//    }
//}
