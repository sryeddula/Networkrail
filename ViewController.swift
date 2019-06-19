//
//  ViewController.swift
//  Networkrail
//
//  Created by Sudhakar Reddy on 03/05/2019.
//  Copyright © 2019 Sudhakar Reddy. All rights reserved.
//

import UIKit
import Alamofire
import AEXML
import Foundation
import Fuzi
import XMLCoder

class ViewController: UIViewController {
    let DARWIN_URL = "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb11.asmx"
    let DARWIN_TOKEN = "f6b2bf85-3ab3-4007-a4e4-c7d1be9d1f3d"
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textArea: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func btnPress(_ sender: UIButton) {
        sendRequest()
    }
    
    func getRequest() -> AEXMLDocument{
        let request = AEXMLDocument()
        let attributes = ["xmlns:soap":"http://www.w3.org/2003/05/soap-envelope", "xmlns:typ":"http://thalesgroup.com/RTTI/2013-11-28/Token/types", "xmlns:ldb":"http://thalesgroup.com/RTTI/2017-10-01/ldb/"]
        let envelope = request.addChild(name: "soap:Envelope", attributes: attributes)
        let header = envelope.addChild(name: "soap:Header")
        let token = header.addChild(name:"typ:AccessToken")
        _ = token.addChild(name:"typ:TokenValue", value: DARWIN_TOKEN)
        let body = envelope.addChild(name: "soap:Body")
        let method = body.addChild(name:"ldb:GetDepBoardWithDetailsRequest")
        _ = method.addChild(name: "ldb:numRows", value: "10")
        _ = method.addChild(name: "ldb:crs", value: "WAT")
        _ = method.addChild(name: "ldb:filterCrs", value: "WOK")
        _ = method.addChild(name: "ldb:filterType", value: "to")
        _ = method.addChild(name: "ldb:timeOffset", value: "0")
        _ = method.addChild(name: "ldb:timeWindow", value: "120")
        return request
    }
    func sendRequest() {
        let stationBoardService = StationBoardService(token: DARWIN_TOKEN)
        let body = stationBoardService.toXML(parameters: LDBRequestParameters(numRows: 10, crs: "WAT", filterCrs: "WOK", filterType: "to", timeOffset: 0, timeWindow: 120), request: LDBRequests.GetDepBoardWithDetailsRequest)
        let url = URL(string: DARWIN_URL)
        var request = URLRequest(url: url!)
        //print(String(data:body!,encoding: .utf8)!)
        request.httpBody = body
        request.httpMethod = "POST"
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        //let timer = ParkBenchTimer()
        Alamofire.request(request).responseData{
            response in
            do{
                let stringResponse: String = String(data: response.data!, encoding: String.Encoding.utf8)!
                let doc =  try XMLDocument(string: stringResponse)
                let result = doc.firstChild(xpath: "//*[local-name()='GetStationBoardResult']")!
                let decoder = XMLDecoder()
                decoder.shouldProcessNamespaces = true
                let parsedData = try decoder.decode(StationBoard.self, from: result.rawXML.data(using: .utf8)!)
                for service in (parsedData.trainServices?.services)!{
                    print(service)
                }
                
            }catch let error{
                print(error)
            }
        }
        
        
    }
}

class ParkBenchTimer {
    
    let startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
