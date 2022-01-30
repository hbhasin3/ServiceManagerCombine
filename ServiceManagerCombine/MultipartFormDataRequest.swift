import Foundation

public class Parameters {
    var key: String
    var value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public class Files {
    var filename: String
    var mineType: String
    var data: NSData
    var filenameWithExtension: String
    
    public init(filename: String, mineType: String, data: NSData, filenameWithExtension : String) {
        self.filename = filename
        self.mineType = mineType
        self.data = data
        self.filenameWithExtension = filenameWithExtension
    }
}

public class MultipartFormDataRequest {
    let boundary = "Boundary-\(UUID().uuidString)"
    
    var body = NSMutableData()
    var parameters: [Parameters]?
    var files: [Files]?
    
    public init(parameters: [Parameters]?, files: [Files]?) {
        self.parameters = parameters
        self.files = files
        
        self.addParamertes()
        self.addFiles()
    }
    
    
     func addParamertes() {
        if let param = self.parameters {
            for data in param {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(data.key)\"\r\n\r\n")
                body.appendString(string: "\(data.value)\r\n")
            }
        }
    }
    
    func addFiles() {
        
        if let param = files {
            for data in param {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(data.filename)\"; filename=\"\(data.filenameWithExtension)\"\r\n")
                body.appendString(string: "Content-Type: \(data.mineType)\r\n\r\n")
                body.append(data.data as Data)
                body.appendString(string: "\r\n")

                body.appendString(string: "--\(boundary)--\r\n")
            }
        }
    }
}

public extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
