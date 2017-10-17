//
//  Models.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation

/*
 *  Models
 *
 *  Discussion:
 *    This is just a container of Model.
 *
 * { [ <Model> ] }
 */

public class Models: Object, Mappable {
    
    typealias ListModel    = List<Model>

    var models = ListModel()

    required public convenience init(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        for json in map.JSON() {
            if  let jsonValue = json.value as? [String: Any],
                let model = Mapper<Model>().map(JSON: jsonValue) {
                models.append(model)
            }
        }
    }
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        for model in models {
            aux += model.description + "\n"
        }
        return aux
    }
    
}
