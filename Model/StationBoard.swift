//
//  StationBoard.swift
//  Networkrail
//
//  Created by Sudhakar Reddy on 10/05/2019.
//  Copyright © 2019 Sudhakar Reddy. All rights reserved.
//

import Foundation
import XMLCoder

struct StationBoard {
    let locationName : String?
    let crs : String?
    let trainServices : TrainServices?
}
struct TrainServices {
    let services : [Service]?
}
struct Service {
    let std : String?
    let etd : String?
    let platform : String?
    let trainOperator : String?
    let serviceType : String?
}
extension StationBoard : Codable {
    enum CodingKeys : String, CodingKey {
        case locationName
        case crs
        case trainServices
    }
}
extension TrainServices : Codable {
    enum CodingKeys : String, CodingKey {
        case services = "service"
    }
}
extension Service : Codable {
    enum CodingKeys : String, CodingKey {
        case std,etd,platform,serviceType
        case trainOperator = "operator"
    }
}
