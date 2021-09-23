import Foundation

// https://stackoverflow.com/a/28132610/128083
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }

    var html2String: String { self.html2AttributedString?.string ?? "" }
}

// https://stackoverflow.com/a/45073012/128083
extension String {
    func countOccurences(of stringToFind: String) -> Int {
        guard !stringToFind.isEmpty else {
            return 0
        }
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
}
