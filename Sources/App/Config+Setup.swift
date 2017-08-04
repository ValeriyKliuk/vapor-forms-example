import LeafProvider
import PostgreSQLProvider
import Flash

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        try setupMiddleware()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
    }
    
    private func setupMiddleware() throws {
        addConfigurable(middleware: FlashMiddleware(), name: "flash")
    }
}
