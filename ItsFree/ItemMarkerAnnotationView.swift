//
//  ItemMarkerAnnotationView.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-07-29.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import MapKit

//  MARK: Battle Rapper View
internal final class ItemMarkerAnnotationView: MKMarkerAnnotationView {
    //  MARK: Properties
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
}
//  MARK: Configuration
private extension ItemMarkerAnnotationView {
    func configure(with annotation: MKAnnotation) {
        guard annotation is Item else { fatalError("Unexpected annotation type: \(annotation)") }
        
//         let newMarkerView = mapView.dequeueReusableAnnotationView(withIdentifier: "itemMarkerView", for: annotation) as! MKMarkerAnnotationView
//        
//        newMarkerView.markerTintColor = UIProperties.sharedUIProperties.purpleColour
//        newMarkerView.glyphTintColor = UIProperties.sharedUIProperties.lightGreenColour
//        
//        switch(item.itemCategory){
//        case .clothing : newMarkerView.glyphImage = #imageLiteral(resourceName: "clothing")
//        case .books : newMarkerView.glyphImage = #imageLiteral(resourceName: "book")
//        case .electronics : newMarkerView.glyphImage = #imageLiteral(resourceName: "electronics")
//        case .furniture : newMarkerView.glyphImage = #imageLiteral(resourceName: "furniture")
//        case .sportingGoods : newMarkerView.glyphImage = #imageLiteral(resourceName: "sports")
//        case .artAndCollectables : newMarkerView.glyphImage = #imageLiteral(resourceName: "art")
//        case .homeAppliances : newMarkerView.glyphImage = #imageLiteral(resourceName: "homeApplicance")
//        case .toys :newMarkerView.glyphImage = #imageLiteral(resourceName: "toys")
//        case .buildingToolsAndSupplies : newMarkerView.glyphImage = #imageLiteral(resourceName: "tools")
//        case .jewelleryAndWatches : newMarkerView.glyphImage = #imageLiteral(resourceName: "jewellery")
//        case .indoorDecor : newMarkerView.glyphImage = #imageLiteral(resourceName: "indoorDecor")
//        case .outdoorDecor : newMarkerView.glyphImage = #imageLiteral(resourceName: "outdoorDecor")
//        case .other : newMarkerView.glyphImage = #imageLiteral(resourceName: "random")
        
        clusteringIdentifier = String(describing: MKMarkerAnnotationView.self)
    }
}
