import Vapor
import JWT
import Fluent
import FluentSQLiteDriver
import NIOSSL

// configures your application
public func configure(_ app: Application) throws {
    app.jwt.signers.use(.hs256(key: "KRtxZQRQb80LGRSRQdB9"))
    app.http.server.configuration.hostname = "0.0.0.0"
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    app.config = .environment
    
    let workingDir = app.directory.workingDirectory
    
    try app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
        certificateChain: NIOSSLCertificate.fromPEMFile(workingDir + "cert.pem").map { .certificate($0) },
        privateKey: .file(workingDir + "key.pem")
    )
    
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateTokens())
    app.autoMigrate()
    
    // register routes
    try routes(app)
}
