//
//  StringExtension.swift
//  GuardianRPM
//
//  Created by Mathews on 04/10/17.
//  Copyright © 2017 guardian. All rights reserved.
//

import Foundation
import UIKit


// MARK: - String Extension
extension String {
    
    
    /// Checks for an empty string
    ///
    /// - Returns: true if string is empty
    func isEmpty() -> Bool {
        if self.count == 0 {
            return true
        }
        return false
    }
    
    /// Validate an email id
    ///
    /// - Returns: true if value is a valid email id
    func isValidEmail() -> Bool {
        let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        let emailValidate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailValidate.evaluate(with: self)
    }
    
    
    /// Validate a password
    /// Hippa compliant password
    /// Min 8 characters, 1 upper case, 1 lower case, 1 digit, 1 special charcter
    ///
    /// - Returns: true if value is a valid password
    func isValidPassword() -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*. _~`()?+|=:;\"'\\{}\\[\\]:;'<>?,./-])(?=.*[0-9]).{\(IntegerConstants.passwordMinLength),\(IntegerConstants.passwordMaxLength)}$"
        let passwordValidate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordValidate.evaluate(with: self)
    }
    
    /// Validate a mobile number
    ///
    /// - Returns: true if value is a valid mobile number
    func isValidMobileNumber() -> Bool {
        let mobileRegEx = "^[+]?[0-9]{10,12}"
        let mobileValidate = NSPredicate(format:"SELF MATCHES %@", mobileRegEx)
        return mobileValidate.evaluate(with: self)
    }
    
    /// Validate a US zip code
    ///
    /// - Returns: true if value is a valid US zip code
    func isValidZipCode() -> Bool {
        let zipRegex = "^[0-9]{5}(?:-[0-9]{4})?$"
        let zipValidate = NSPredicate(format: "SELF MATCHES %@", zipRegex)
        return zipValidate.evaluate(with: self.formatToUsZipCode())
    }
    
    /// Validate a numeric value
    ///
    /// - Returns: true if value is number
    func isNumeric() -> Bool {
        let numericRegEx = "^[0-9]*$"
        let numericValidate = NSPredicate(format:"SELF MATCHES %@", numericRegEx)
        return numericValidate.evaluate(with: self)
    }
    
    
    /// Validate a Double value
    ///
    /// - Returns: true if value is Double
    func isDouble() -> Bool {
        let doubleRegEx = "^[0-9]+(\\.[0-9]+)?$"
        let doubleValidate = NSPredicate(format:"SELF MATCHES %@", doubleRegEx)
        return doubleValidate.evaluate(with: self)
    }
    
    
    /// Validates a floating point value
    ///
    /// - Parameter precision: decimal precision desired
    /// - Returns: true if value is floating point
    func isFloatingPoint(decimalPrecision: Int = 0, wholeNumberLength length: Int) -> Bool {
        var floatRegex = ""
        if decimalPrecision > 0 {
            floatRegex = "^(?:|0|[0-9]{0,\(length)})(?:\\.\\d{0,\(decimalPrecision)})?$"
        }
        else {
            floatRegex = "^[0-9]{0,\(length)}$"
        }
        let floatValidate = NSPredicate(format: "SELF MATCHES %@", floatRegex)
        return floatValidate.evaluate(with:self)
    }
    
    
    /// Hashes the string using SHA1 algorithm
    ///
    /// - Returns: SHA1 Hash
    func encryptSHA1() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    
    /// Converts a string to corresponding Date
    ///
    /// - Parameter dateFormat: format specifier for the date string
    /// - Returns: Date formatted from string
    func date(dateFormat: String, withDeviceLocale deviceLocale: Bool = true) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if deviceLocale {
            dateFormatter.timeZone = TimeZone()?.getTimeZone(isGMT: false)
            dateFormatter.locale = Locale.current
        }
        else {
            dateFormatter.timeZone = TimeZone()?.getTimeZone(isGMT: true)
            dateFormatter.locale = Locale(identifier: "GMT")
        }
        let date = dateFormatter.date(from: self)
        return date
    }
    
    /// Strips html tags from a html string
    ///
    /// - Returns: plain string
    func trimmingHtmlTags() -> String {
        guard let htmlData = self.data(using: String.Encoding.unicode) else
        {
            return ""
        }
        do {
            return try NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string
        } catch let error {
            print(error)
            return ""
        }
    }
    
    /// Calculate the height of string needs to draw the height of a label
    ///
    /// - Returns: String height
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
    
    /// Returns the string with first character Upper Cased
    ///
    /// - Returns: Sentance cased string
    func sentanceCased() -> String {
        return String(self.prefix(1)).capitalized + self.dropFirst()
    }
    
    /// Formats the input 10 digit phone number string to US format (xxx)-xxx-xxxx
    ///
    /// - Returns: US formatted phone number string
    func formatToUSPhoneNumber() -> String {
        var inputNumber = self.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        var number = "("
        if inputNumber.count > 0 {
            number.append(String(inputNumber.prefix(3)))
            inputNumber = String(inputNumber.dropFirst(3))
        }
        if inputNumber.count > 0 {
            number.append(")-")
            number.append(String(inputNumber.prefix(3)))
            inputNumber = String(inputNumber.dropFirst(3))
        }
        if inputNumber.count > 0 {
            number.append("-")
            number.append(String(inputNumber.prefix(4)))
            inputNumber = String(inputNumber.dropFirst(4))
        }
        if number == "(" {
            return ""
        }
        return number
    }
    
    /// Formats the input string to US format (XXXXX or XXXXX-XXXX)
    ///
    /// - Returns: US formatted Zip Code
    func formatToUsZipCode() -> String {
        var inputZip = self.replacingOccurrences(of: "-", with: "")
        if inputZip.count <= 5 {
            return inputZip
        }
        var zipCode = String()
        zipCode.append(String(inputZip.prefix(5)))
        inputZip = String(inputZip.dropFirst(5))

        zipCode.append("-")
        zipCode.append(String(inputZip.prefix(4)))
        return zipCode
    }
    
    /// Generic string formatter
    ///
    /// - Parameter format: desired format.
    ///   Zeros will be replaced with charcters from input string
    ///   All other charcters in the format specifier will be copied into formatted string
    /// - Returns: formatted string
    func formatToUsZipCode(format: String = "00000-0000") -> String {
        var inputString = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var formattedString = ""
            for i in format.enumerated() {
                if inputString.count <= 0 {
                    break
                }
                if i.element != "0" {
                    formattedString.append(i.element)
                }
                else {
                    formattedString.append(inputString.first!)
                    inputString = String(inputString.dropFirst())
                }
            }
        return formattedString
    }
}
