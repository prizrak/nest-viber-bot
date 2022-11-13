import Vapor
import JWT

func routes(_ app: Application) throws {
    try! app.register(collection: AuthenticationController())
    try! app.register(collection: ViberController(app))
    
    app.get { req async in
        "It's viber bot endpoint"
    }
    
    app.post("viber", "**") { req -> HTTPStatus in
        print(req)
        return .ok
    }
}
