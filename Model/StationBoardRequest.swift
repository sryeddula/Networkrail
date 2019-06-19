//
//  StationBoardRequest.swift
//  Networkrail
//
//  Created by Sudhakar Reddy on 10/05/2019.
//  Copyright © 2019 Sudhakar Reddy. All rights reserved.
//

import Foundation
import XMLCoder

class StationBoardService {
    let token : AccessToken
    let encoder = XMLEncoder()
    init(token: String) {
        self.token = AccessToken(tokenValue: TokenValue(token: token))
    }
    public func toXML(parameters : LDBRequestParameters, request: LDBRequests) -> Data?{
        let request = LDBRequest(parameters: parameters, method: request)
        let envelope = SOAPEnvelope(header: token, body: request)
        do {
            let data = try encoder.encode(envelope, withRootKey: "soap:Envelope", header: XMLHeader(version: 1.0, encoding: "utf-8"))
            return data;
        } catch {
            print(error)
            return nil
        }
    }
}
enum LDBRequests : String{
    case GetDepBoardWithDetailsRequest = "ldb:GetDepBoardWithDetailsRequest"
}

struct SOAPEnvelope {
    let header : AccessToken
    let body : LDBRequest
    let soap = "http://www.w3.org/2003/05/soap-envelope"
    let typ = "http://thalesgroup.com/RTTI/2013-11-28/Token/types"
    let ldb = "http://thalesgroup.com/RTTI/2017-10-01/ldb/"
}
struct AccessToken {
    let tokenValue : TokenValue
}
struct TokenValue {
    let token : String
}
struct LDBRequest {
    let parameters : LDBRequestParameters
    let method : LDBRequests
}
struct LDBRequestParameters {
    let numRows : Int?
    let crs : String?
    let filterCrs : String?
    let filterType : String?
    let timeOffset : Int?
    let timeWindow : Int?
}

extension SOAPEnvelope : Encodable, Equatable, DynamicNodeEncoding{
    enum CodingKeys: String, CodingKey {
        case header = "soap:Header"
        case body = "soap:Body"
        case soap = "xmlns:soap"
        case typ = "xmlns:typ"
        case ldb = "xmlns:ldb"
    }
    static func == (lhs: SOAPEnvelope, rhs: SOAPEnvelope) -> Bool {
        return true
    }
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case SOAPEnvelope.CodingKeys.ldb,SOAPEnvelope.CodingKeys.typ,SOAPEnvelope.CodingKeys.soap: return .attribute
        default: return .element
        }
    }
}
struct LDBRequestKeys : CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    init!(stringValue: String,nameSpace: String) {
        self.stringValue = "\(nameSpace):\(stringValue)"
    }
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}
extension LDBRequest : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LDBRequestKeys.self)
        try container.encode(parameters, forKey: LDBRequestKeys(stringValue: self.method.rawValue)!)
    }
}
extension LDBRequestParameters : Encodable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case numRows = "ldb:numRows"
        case crs = "ldb:crs"
        case filterCrs = "ldb:filterCrs"
        case filterType = "ldb:filterType"
        case timeOffset = "ldb:timeOffset"
        case timeWindow = "ldb:timeWindow"
    }
}
extension AccessToken : Encodable {
    enum CodingKeys: String, CodingKey {
        case tokenValue = "typ:AccessToken"
    }
}
extension TokenValue : Encodable {
    enum CodingKeys: String, CodingKey {
        case token = "typ:TokenValue"
    }
}
