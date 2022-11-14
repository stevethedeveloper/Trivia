//
//  ViewHelpers.swift
//  Trivia
//
//  Created by Stephen Walton on 11/11/22.
//

import UIKit

func getStarsAttributedText(numberOfStars: Int, font: UIFont) -> NSAttributedString {
    let starsLabelText = StarsText.allCases[numberOfStars].asString
    // Resize empty stars to match gold stars
    let searchChar = "☆"
    let starsLabelAttributedText = NSMutableAttributedString(string: starsLabelText)
//        starsLabelAttributedText.attributeRangeFor(searchString: searchChar, attributeValue: UIFont(name: starsLabel.font.fontName, size: 17.0)!, attributeType: .Size, attributeSearchType: .All)
    starsLabelAttributedText.attributeRangeFor(searchString: searchChar, attributeValue: font, attributeType: .Size, attributeSearchType: .All)
    return starsLabelAttributedText
}

