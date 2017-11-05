@_exported import Vapor
import Foundation

extension Droplet {
    public func setup() throws {
        let routes = Routes(view)
        try collection(routes)
        
        let mailgunUrlWithKey = config["server", "mailgunUrlWithKey"]?.string
        let senderName = config["server", "senderName"]?.string
        let senderAddress = config["server", "senderAddress"]?.string
        let recipientName = config["server", "recipientName"]?.string
        let recipientAddress = config["server", "recipientAddress"]?.string
        let subject = config["server", "subject"]?.string
        
        /// POST /mail
        post("mail") { req in
            if let rcvdMsg = req.data["message"]?.string
            {
                sendMail(rcvdMsg)
                return "thanks"
            }
            else
            {
                return "blank message -- not sent"
            }
        }
        
        func sendMail(_ message: String)
        {
            let session = URLSession.shared
            var request = URLRequest(url: URL(string: mailgunUrlWithKey!)!)
            request.httpMethod = "POST"
            let bodyData = "from=\(senderName!)<\(senderAddress!)>&to=\(recipientName!)<\(recipientAddress!)>&subject=\(subject!)&text=\(message)"
            request.httpBody = bodyData.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: {(data,
                response, error) in
    
                if let error = error {
                    print (error)
                }
                if let response = response {
                    print("url = \(response.url!)")
                    print("response = \(response)")
                    let httpResponse = response as! HTTPURLResponse
                    print("response code = \(httpResponse.statusCode)")
                }
                
            })
            task.resume()
        }
        
    }
}
