import Foundation

struct MultipartFormData {
    private let boundary: String
    private var data: Data

    var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    init() {
        self.boundary = "Boundary-\(UUID().uuidString)"
        self.data = Data()
    }

    mutating func append(field: String, value: String) {
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(field)\"\r\n\r\n")
        data.append("\(value)\r\n")
    }

    mutating func append(file: String, filename: String, mimeType: String, fileData: Data) {
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(file)\"; filename=\"\(filename)\"\r\n")
        data.append("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.append("\r\n")
    }

    func finalize() -> Data {
        var finalData = data
        finalData.append("--\(boundary)--\r\n")
        return finalData
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
