//
//  UIConfig.swift
//  MagicSecurity
//
//  Created by User on 13.04.25.
//

import UIKit

@MainActor 
public enum UIConfig {
    public static func setupUI() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.designSystem(.primary))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(red: 170 / 255, green: 176 / 255, blue: 186 / 255, alpha: 1.0)
        
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(.designSystem(.textSecondary))]
    }
}
