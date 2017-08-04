import Foundation
import FluentProvider

final class User: Model {
    let storage = Storage()
    
    var name: String
    var email: String
    var avatarURL: URL
    
    init(name: String, email: String, avatarURL: URL) {
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
    }
    
    // MARK: - Row conversion
    init(row: Row) throws {
        name = try row.get(Field.name)
        email = try row.get(Field.email)
        guard let path: String = try row.get(Field.avatarURL),
            let url = URL(string: path) else {
                throw Error.deserialization
        }
        avatarURL = url
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Field.name, name)
        try row.set(Field.email, email)
        try row.set(Field.avatarURL, avatarURL.absoluteString)
        return row
    }
    
    fileprivate enum Field {
        static let id = "id"
        static let name = "name"
        static let email = "email"
        static let avatarURL = "avatar_url"
    }
    
    fileprivate enum Error: Swift.Error {
        case deserialization
    }
}

// MARK: - Database preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Field.name)
            builder.string(Field.email)
            builder.string(Field.avatarURL)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        let dict = try [
            Field.id: id.makeNode(in: context),
            Field.name: name.makeNode(in: context),
            Field.email: email.makeNode(in: context),
            Field.avatarURL: avatarURL.absoluteString.makeNode(in: context),
            ]
        return try Node(node: dict)
    }
}
