import Foundation

struct DebugToolset {
    var text = "Hello, World!"
}

let isRunningUnitTests: Bool = {
    let environment = ProcessInfo().environment
    return (environment["XCTestConfigurationFilePath"] != nil)
}()
