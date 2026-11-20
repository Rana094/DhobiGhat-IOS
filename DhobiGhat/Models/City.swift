struct City: Identifiable, Equatable, Sendable {
    let name: String
    let latitude: Double
    let longitude: Double

    var id: String { name }

    static let khulna = City(name: "Khulna", latitude: 22.8456, longitude: 89.5403)
    static let dhaka = City(name: "Dhaka", latitude: 23.8103, longitude: 90.4125)
    static let chattogram = City(name: "Chattogram", latitude: 22.3569, longitude: 91.7832)

    static let cities = [khulna, dhaka, chattogram]
}
