//
//  UIFont++.swift
//  SeeMeet_iOS
//
//  Created by 박익범 on 2022/01/05.
//
import UIKit

struct AppFontName {
    static let DINEng = "DINEngschriftStd"
    static let DINMittel = "DINMittelschriftStd"
    static let DINBdCond = "DINNeuzeitGroteskStd-BdCond"
    static let DINLight = "DINNeuzeitGroteskStd-Light"
    static let DINProblack = "DINPro-Black"
    static let DINProBold = "DINPro-Bold"
    static let DINProLight = "DINPro-Light"
    static let DINProMedium = "DINPro-Medium"
    static let DINProRegular = "DINPro-Regular"
    static let HanSansBold = "SpoqaHanSansNeo-Bold"
    static let HanSansLight = "SpoqaHanSansNeo-Light"
    static let HanSansMedium = "SpoqaHanSansNeo-Medium"
    static let HanSansRegular = "SpoqaHanSansNeo-Regular"
    static let HanSansThin = "SpoqaHanSansNeo-Thin"
}
extension UIFont{
    
    @objc class func dinEngFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINEng, size: size)!
    }

    @objc class func dinMittelFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINMittel, size: size)!
    }
    
    @objc class func dinBdCondFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINBdCond, size: size)!
    }
    
    @objc class func dinLightFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINLight, size: size)!
    }
    
    @objc class func dinProBlackFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINProblack, size: size)!
    }
    
    @objc class func dinProBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINProBold, size: size)!
    }
    
    @objc class func dinProLightFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINProLight, size: size)!
    }
    
    @objc class func dinProMediumFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINProMedium, size: size)!
    }
    
    @objc class func dinProRegularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.DINProRegular, size: size)!
    }
    
    @objc class func hanSansBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.HanSansBold, size: size)!
    }
    
    @objc class func hanSansLightFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.HanSansLight, size: size)!
    }
    
    @objc class func hanSansMediumFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.HanSansMedium, size: size)!
    }
    
    @objc class func hanSansRegularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.HanSansRegular, size: size)!
    }
    
    @objc class func hanSansThinFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.HanSansThin, size: size)!
    }
}
