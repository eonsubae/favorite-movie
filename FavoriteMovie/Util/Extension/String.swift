import UIKit

extension String {
    func removeHtmlBoldTagFromText() -> String {
        return self.replacingOccurrences(of: "</?b>", with: "", options: .regularExpression)
    }
    
    func replaceArrangeChar() -> String {
        let nameArray = self.split(separator: "|")
        return nameArray.joined(separator: ",")
    }
    
    func mapImageLinkToUIImage() -> UIImage {
        guard let url = URL(string: self) else { return UIImage(systemName: "photo")! }
        
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch {
            print("Image processing failed : \(error)")
            return UIImage(systemName: "photo")!
        }
    }
}
