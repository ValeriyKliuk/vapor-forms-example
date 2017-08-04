import Foundation

final class UserController {
    let view: ViewRenderer
    
    private let path = "/profile"
    
    init(view: ViewRenderer) {
        self.view = view
    }
    
    func addRoutes(to builder: RouteBuilder) {
        builder.get(path, handler: edit)
        builder.post(path, handler: update)
    }
    
    func edit(_ request: Request) throws -> ResponseRepresentable {
        let user = try User.find(1)
        return try view.make("profile", ["user": user])
    }
    
    func update(_ request: Request) throws -> ResponseRepresentable {
        guard let user = try User.find(1), let name = request.data["name"]?.string, let email = request.data["email"]?.string, let avatarPath = request.data["avatar_url"]?.string, let avatarURL = URL(string: avatarPath) else {
            throw Abort.badRequest
        }
        
        user.name = name
        user.email = email
        user.avatarURL = avatarURL
        
        do {
            try user.save()
        } catch {
            print("Error: \(String(reflecting: error))")
        }
        
        return Response(status: .seeOther, headers: ["Location": path])
    }
}
