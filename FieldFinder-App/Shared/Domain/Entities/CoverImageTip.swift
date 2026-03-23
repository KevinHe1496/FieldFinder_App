//
//  CoverImageTip.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 17/5/25.
//


import TipKit

struct CoverImageTip: Tip {
    var title: Text {
        Text("La primera imagen será la portada")
    }

    var message: Text? {
        Text("La primera foto que subas será usada como imagen principal.")
    }

    var image: Image? {
        Image(systemName: "photo.on.rectangle.angled")
    }
    
}
