//
//  Extensions.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import UIKit

extension String {
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString.string)
    }
}

extension Int {
    // Add commas to numbers
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

// Extension for attributed strings.  Useful for labels and buttons.  This is generally easy to do, but the extension makes the calling code cleaner.
// Can handle changing first occurance of target string, las occurance, or all occurances.  Also currently can change color of substrings as well as size.  Can be extended to handle more.
extension NSMutableAttributedString {
    enum AtributeSearchType {
        case First, All, Last
    }
    
    enum AttributeType {
        case Size, Color
        
        var attributeName: NSAttributedString.Key {
            switch self {
            case .Size:
                return NSAttributedString.Key.font
            case .Color:
                return NSAttributedString.Key.foregroundColor
            }
        }
    }

    func attributeRangeFor(searchString: String, attributeValue: AnyObject, attributeType: AttributeType, attributeSearchType: AtributeSearchType) {
        let inputLength = self.string.utf16.count
        let searchLength = searchString.utf16.count
        var range = NSRange(location: 0, length: self.length)
        var rangeCollection = [NSRange]()

        while (range.location != NSNotFound) {
            range = (self.string as NSString).range(of: searchString, options: [], range: range)
            if (range.location != NSNotFound) {
                switch attributeSearchType {
                case .First:
                    self.addAttribute(attributeType.attributeName, value: attributeValue, range: NSRange(location: range.location, length: searchLength))
                    return
                case .All:
                    self.addAttribute(attributeType.attributeName, value: attributeValue, range: NSRange(location: range.location, length: searchLength))
                    break
                case .Last:
                    rangeCollection.append(range)
                    break
                }

                range = NSRange(location: range.location + range.length, length: inputLength - (range.location + searchLength))
//                range = NSRange(location: 0, length: 3)
            }
        }

        switch attributeSearchType {
        case .Last:
            let indexOfLast = rangeCollection.count - 1
            self.addAttribute(attributeType.attributeName, value: attributeValue, range: rangeCollection[indexOfLast])
            break
        default:
            break
        }
    }    
}
