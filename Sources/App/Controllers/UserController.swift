import Foundation
import Validation

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
        guard let user = try User.find(1) else {
            throw Abort.badRequest
        }
        return try view.make("profile", ["user": user, "request": request])
    }
    
    func update(_ request: Request) throws -> ResponseRepresentable {
        guard let user = try User.find(1) else {
            throw Abort.badRequest
        }

        var errors: [String: String] = [:]
        
        let name = request.data["name"]?.string
        if name == nil {
            errors["name"] = "Name is required."
        }
        
        let email = request.data["email"]?.string
        if let email = email {
            do {
                try EmailValidator().validate(email)
            } catch _ as ValidationError {
                errors["email"] = "Email is not a valid email address."
            }
        } else {
            errors["email"] = "Email is required."
        }
        
        let avatarPath = request.data["avatar_url"]?.string
        var avatarURL: URL? = nil
        if let avatarPath = avatarPath {
            avatarURL = URL(string: avatarPath)
            if avatarURL == nil {
                errors["avatar_url"] = "Avatar URL is not a valid URL."
            }
        } else {
            errors["avatar_url"] = "Avatar URL is required."
        }
        
        if errors.isEmpty, let name = name, let email = email, let avatarURL = avatarURL {
            user.name = name
            user.email = email
            user.avatarURL = avatarURL
            
            try user.save()
            
            return Response(status: .seeOther, headers: ["Location": path]).flash(.success, "Saved changes.")
        } else {
            return try view.make("profile", ["user": user, "errors": errors])
        }
    }
}
