//
//  GeoRegion.swift
//  Forescoop
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation

/*
 *  GeoRegion
 *
 *  Discussion:
 *    Model object representing the base class of GeoRegion.
 *
 *  "2": "Africa",
 */

public class GeoRegion: Object, Mappable {

    var id: String? = nil
    var name: String? = nil

    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        id = map["id"] as? String
        name = map["name"] as? String
    }

    public var description : String {
        ["\(type(of:self))", id, name]
            .compactMap{$0}
            .joined(separator: ", ")
    }
}

public extension GeoRegion {
    var oficialName: String? {
        name
    }
}
