import Foundation

actor APIClient {
    static let shared = APIClient()

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }

    func request<T: Decodable, U: Encodable>(
        endpoint: APIEndpoint,
        body: U,
        token: String? = nil
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try encoder.encode(body)

        print("[APIClient] Request URL: \(url)")
        print("[APIClient] Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("[APIClient] Network error: \(error)")
            throw APIError.networkError(error)
        }

        print("[APIClient] Response data: \(String(data: data, encoding: .utf8) ?? "nil")")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIClient] Invalid response - not HTTPURLResponse")
            throw APIError.invalidResponse
        }

        print("[APIClient] HTTP Status Code: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 401 {
            print("[APIClient] Unauthorized (401)")
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            print("[APIClient] HTTP error - status: \(httpResponse.statusCode), message: \(errorResponse?.message ?? "nil")")
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.message
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("[APIClient] Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        token: String? = nil
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }

        print("[APIClient] Request URL: \(url)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("[APIClient] Network error: \(error)")
            throw APIError.networkError(error)
        }

        print("[APIClient] Response data: \(String(data: data, encoding: .utf8) ?? "nil")")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIClient] Invalid response - not HTTPURLResponse")
            throw APIError.invalidResponse
        }

        print("[APIClient] HTTP Status Code: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 401 {
            print("[APIClient] Unauthorized (401)")
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            print("[APIClient] HTTP error - status: \(httpResponse.statusCode), message: \(errorResponse?.message ?? "nil")")
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.message
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("[APIClient] Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    func requestVoid(
        endpoint: APIEndpoint,
        token: String? = nil
    ) async throws {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }

        print("[APIClient] Request URL: \(url)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("[APIClient] Network error: \(error)")
            throw APIError.networkError(error)
        }

        print("[APIClient] Response data: \(String(data: data, encoding: .utf8) ?? "nil")")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIClient] Invalid response - not HTTPURLResponse")
            throw APIError.invalidResponse
        }

        print("[APIClient] HTTP Status Code: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 401 {
            print("[APIClient] Unauthorized (401)")
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            print("[APIClient] HTTP error - status: \(httpResponse.statusCode), message: \(errorResponse?.message ?? "nil")")
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.message
            )
        }
    }

    func requestVoidWithBody<U: Encodable>(
        endpoint: APIEndpoint,
        body: U,
        token: String? = nil
    ) async throws {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try encoder.encode(body)

        print("[APIClient] Request URL: \(url)")
        print("[APIClient] Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("[APIClient] Network error: \(error)")
            throw APIError.networkError(error)
        }

        print("[APIClient] Response data: \(String(data: data, encoding: .utf8) ?? "nil")")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIClient] Invalid response - not HTTPURLResponse")
            throw APIError.invalidResponse
        }

        print("[APIClient] HTTP Status Code: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 401 {
            print("[APIClient] Unauthorized (401)")
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            print("[APIClient] HTTP error - status: \(httpResponse.statusCode), message: \(errorResponse?.message ?? "nil")")
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.message
            )
        }
    }
}
