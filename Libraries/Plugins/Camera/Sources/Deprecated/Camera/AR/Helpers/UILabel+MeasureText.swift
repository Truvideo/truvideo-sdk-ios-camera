//
//  UILabel+MeasureText.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 6/6/24.
//

import UIKit

extension UILabel {

    static func make(with text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.text = text
        label.font = UIFont.systemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        return label
    }

    func toImage() -> UIImage? {
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        return image
    }
}
