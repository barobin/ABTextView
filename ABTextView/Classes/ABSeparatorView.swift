//
//  ABSeparatorView.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

//MARK: ABSeparatorView
public class ABSeparatorView: UIView {

    public var lineColor: UIColor = UIColor.clear {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initABSeparatorView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initABSeparatorView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let scale = UIScreen.main.scale
        let width = 1.0 / scale
        let center = (UInt(scale) % 2 == 0) ? CGFloat(4.0) : CGFloat(2.0)
        let offset = scale / center * width
        
        let context: CGContext! = UIGraphicsGetCurrentContext()
        context.setStrokeColor(self.lineColor.cgColor)
        context.setLineWidth(width)
        
        let bounds = self.bounds
        if bounds.size.width > bounds.size.height {
            if bounds.size.height >= 1.0 {
                context.beginPath()
                context.move(to: CGPoint(x: 0.0, y: offset))
                context.addLine(to: CGPoint(x: bounds.size.width, y: offset))
                context.strokePath()
            }
        } else {
            if bounds.width >= 1.0 {
                context.beginPath()
                context.move(to: CGPoint(x: offset, y: 0.0))
                context.addLine(to: CGPoint(x: offset, y: bounds.size.height))
                context.strokePath()
            }
        }
    }

    //MARK: Private
    private func initABSeparatorView() {
        self.contentMode = UIViewContentMode.redraw
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
    }
}
