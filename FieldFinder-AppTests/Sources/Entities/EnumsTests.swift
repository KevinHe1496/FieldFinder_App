//
//  EnumsTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest
import SwiftUICore

@testable import FieldFinder_App
final class EnumsTests: XCTestCase {
    
    // MARK: Tab Bar Items Tests
    
    func test_TabBarItem_Icons_ShouldBeCorrect() {
        XCTAssertEqual(TabBarItem.home.iconName, "house.fill")
        XCTAssertEqual(TabBarItem.map.iconName, "map.fill")
        XCTAssertEqual(TabBarItem.profile.iconName, "person.fill")
        XCTAssertEqual(TabBarItem.favorites.iconName, "heart.fill")
    }
    
    func test_TabBarItem_Titles_ShouldBeCorrect() {
        XCTAssertEqual(TabBarItem.home.title, "Home")
        XCTAssertEqual(TabBarItem.map.title, "Mapa")
        XCTAssertEqual(TabBarItem.profile.title, "Perfil")
        XCTAssertEqual(TabBarItem.favorites.title, "Favoritos")
    }
    
    func test_TabBarItem_Colors_ShouldBeWhite() {
        XCTAssertEqual(TabBarItem.home.color, Color.white)
        XCTAssertEqual(TabBarItem.map.color, Color.white)
        XCTAssertEqual(TabBarItem.profile.color, Color.white)
        XCTAssertEqual(TabBarItem.favorites.color, Color.white)
    }
    
    // MARK: UserRole Tests
    
    func test_UserRole_DisplayName_ShouldBeCorrect() {
        XCTAssertEqual(UserRole.jugador.displayName, "Player")
        XCTAssertEqual(UserRole.dueno.displayName, "Owner")
    }
    
    func test_UserRole_ID_ShouldMatchRawValue() {
        XCTAssertEqual(UserRole.jugador.id, "Jugador")
        XCTAssertEqual(UserRole.dueno.id, "Dueno")
    }
    
    // MARK: Field Tests
    
    
    func test_Field_DisplayName_ShouldBeCorrect() {
        XCTAssertEqual(Field.cesped.displayName, "Grass")
        XCTAssertEqual(Field.sintetico.displayName, "Synthetic")
    }
    
    func test_Field_ID_ShouldMatchRawValue() {
        XCTAssertEqual(Field.cesped.id, "cesped")
        XCTAssertEqual(Field.sintetico.id, "sintetico")
    }
    
    // MARK: Capacidad Tests
    
    func test_Capacidad_ID_ShouldMatchRawValue() {
        XCTAssertEqual(Capacidad.cinco.id, "5-5")
        XCTAssertEqual(Capacidad.siete.id, "7-7")
        XCTAssertEqual(Capacidad.nueve.id, "9-9")
        XCTAssertEqual(Capacidad.once.id, "11-11")
    }
    
    
}
