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
        let form = try UserForm(user: user)
        return try view.make("profile", ["form": form, "request": request])
    }
    
    func update(_ request: Request) throws -> ResponseRepresentable {
        guard let user = try User.find(1) else {
            throw Abort.badRequest
        }
        
        let form = try UserForm(user: user, valuesFrom: request.data)
        do {
            try form.save()
            return Response(status: .seeOther, headers: ["Location": path]).flash(.success, "Saved changes.")
        } catch let errors as UserForm.ValidationError {
            return try view.make("profile", ["form": form, "errors": errors, "request": request])
        }
    }
}
