import Foundation
import Validation

final class UserForm {
    
    fileprivate let user: User
    fileprivate let name: String?
    fileprivate let email: String?
    fileprivate let avatarURLString: String?

    private lazy var emailValidator = EmailValidator()

    struct ValidationError: Error {
        let errors: [String: String]
    }
    
    init(user: User) throws {
        self.user = user
        self.name = user.name
        self.email = user.email
        self.avatarURLString = user.avatarURL.absoluteString
    }
    
    init(user: User, valuesFrom content: Content) throws {
        self.user = user
        self.name = content[Field.name]?.string
        self.email = content[Field.email]?.string
        self.avatarURLString = content[Field.avatarURL]?.string
    }
    
    func save() throws {
        var errors: [String: String] = [:]
        
        if name == nil {
            errors[Field.name] = "Name is required."
        }
        
        if email == nil {
            errors[Field.email] = "Email is required."
        }
        
        do {
            try email.map(emailValidator.validate)
        } catch _ as ValidationError {
            errors[Field.email] = "Email is not a valid email address."
        }
        
        var avatarURL: URL? = nil
        if let avatarURLString = avatarURLString {
            avatarURL = URL(string: avatarURLString)
            if avatarURL == nil {
                errors[Field.avatarURL] = "Avatar URL must be a valid URL."
            }
        } else {
            errors[Field.avatarURL] = "Avatar URL is required."
        }
    
        if errors.isEmpty, let name = name, let email = email, let avatarURL = avatarURL {
            user.name = name
            user.email = email
            user.avatarURL = avatarURL
            
            try user.save()
        } else {
            throw ValidationError(errors: errors)
        }
    }
    
    fileprivate enum Field {
        static let name = "name"
        static let email = "email"
        static let avatarURL = "avatar_url"
    }
}

extension UserForm: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            Field.name: name.makeNode(in: context),
            Field.email: email.makeNode(in: context),
            Field.avatarURL: avatarURLString.makeNode(in: context),
        ])
    }
}

extension UserForm.ValidationError: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: errors)
    }
}
