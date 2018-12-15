//
//  UIButton.swift
//  Nikola
//
//  Created by Shantha Kumar on 9/5/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation


@IBDesignable class CustomButton: UIButton {
    
    @IBInspectable public var cornerRadiusButton : CGFloat = 0.0 {
        
        didSet {
            
            self.layer.cornerRadius = cornerRadiusButton
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.white.cgColor
            
        }
        
    }
    
    
    @IBInspectable public var border : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = border
        }
    }
    
    @IBInspectable public var borderColorButton : UIColor? {
        didSet {
            self.layer.borderColor = borderColorButton?.cgColor
        }
    }
    
}
