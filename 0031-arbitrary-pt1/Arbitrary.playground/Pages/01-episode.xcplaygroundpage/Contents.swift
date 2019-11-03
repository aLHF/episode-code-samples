
//Decodable

import Foundation
//JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)

struct ArbitraryDecoder: Decoder {
  var codingPath: [CodingKey] = []
  var userInfo: [CodingUserInfoKey: Any] = [:]

  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    return KeyedDecodingContainer(KeyedContainer())
  }

  struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey] = []
    var allKeys: [Key] = []

    init() {

      self.allKeys = Array(repeating: (), count: Int.random(in: 0 ... 100))
        .map { Int.random(in: 0 ... .max) }
        .compactMap { Key(intValue: $0) }
    }

    func contains(_ key: Key) -> Bool {
      return allKeys.contains(where: { $0.intValue == key.intValue })
    }

    func decodeNil(forKey key: Key) throws -> Bool {
      fatalError()
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
      return try T(from: ArbitraryDecoder())
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
      fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      fatalError()
    }

    func superDecoder() throws -> Decoder {
      fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
      fatalError()
    }
  }

  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    return UnkeyedContainer()
  }

  struct UnkeyedContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int? = Int.random(in: 1 ... 10)
    var isAtEnd: Bool { return currentIndex == endIndex }
    var currentIndex: Int = 0

    private var endIndex: Int {
      if let count = count {
        return max(count - 1, 0)
      } else {
        return 0
      }
    }

    mutating func decodeNil() throws -> Bool {
      fatalError()
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
      self.currentIndex += 1
      return try T(from: ArbitraryDecoder())
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
      fatalError()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      fatalError()
    }

    mutating func superDecoder() throws -> Decoder {
      print("super")
      self.currentIndex += 1
      fatalError()
    }
  }

  func singleValueContainer() throws -> SingleValueDecodingContainer {
    return SingleValueContainer()
  }

  struct SingleValueContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    func decodeNil() -> Bool {
      return .random()
    }

    func decode(_ type: Bool.Type) throws -> Bool {
      return .random()
    }

    func decode(_ type: String.Type) throws -> String {
      return Array(repeating: (), count: .random(in: 0...280))
        .map { String(UnicodeScalar(UInt8.random(in: .min ... .max))) }
        .joined()
    }

    func decode(_ type: Double.Type) throws -> Double {
      return .random(in: -1_000_000_000...1_000_000_000)
    }

    func decode(_ type: Float.Type) throws -> Float {
      return .random(in: 0...1)
    }

    func decode(_ type: Int.Type) throws -> Int {
      return .random(in: .min ... .max)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
      return .random(in: .min ... .max)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
      return .random(in: .min ... .max)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
      return .random(in: .min ... .max)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
      return .random(in: .min ... .max)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
      return .random(in: .min ... .max)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
      return .random(in: .min ... .max)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
      return .random(in: .min ... .max)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
      return .random(in: .min ... .max)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
      return .random(in: .min ... .max)
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      return try T(from: ArbitraryDecoder())
    }
  }
}

try Bool(from: ArbitraryDecoder())
try Bool(from: ArbitraryDecoder())
try Bool(from: ArbitraryDecoder())
try Bool(from: ArbitraryDecoder())
try Bool(from: ArbitraryDecoder())
try Int(from: ArbitraryDecoder())
try Int(from: ArbitraryDecoder())
try Int(from: ArbitraryDecoder())
try Int(from: ArbitraryDecoder())
try Int(from: ArbitraryDecoder())
try UInt8(from: ArbitraryDecoder())
try UInt8(from: ArbitraryDecoder())
try UInt8(from: ArbitraryDecoder())
try UInt8(from: ArbitraryDecoder())
try UInt8(from: ArbitraryDecoder())
try Double(from: ArbitraryDecoder())
try Double(from: ArbitraryDecoder())
try Double(from: ArbitraryDecoder())
try Double(from: ArbitraryDecoder())
try Double(from: ArbitraryDecoder())
try Float(from: ArbitraryDecoder())
try Float(from: ArbitraryDecoder())
try Float(from: ArbitraryDecoder())
try Float(from: ArbitraryDecoder())
try Float(from: ArbitraryDecoder())
try String(from: ArbitraryDecoder())
try String(from: ArbitraryDecoder())
try String(from: ArbitraryDecoder())
try String(from: ArbitraryDecoder())
try String(from: ArbitraryDecoder())
try String?(from: ArbitraryDecoder())
try String?(from: ArbitraryDecoder())
try String?(from: ArbitraryDecoder())
try String?(from: ArbitraryDecoder())
try String?(from: ArbitraryDecoder())
try Date(from: ArbitraryDecoder())
try Date(from: ArbitraryDecoder())
try Date(from: ArbitraryDecoder())
try Date(from: ArbitraryDecoder())
try Date(from: ArbitraryDecoder())
//try UUID(from: ArbitraryDecoder())

struct User: Decodable {
  let id: Int
  let name: String
  let email: String
}

print(try User(from: ArbitraryDecoder()))
print(try User(from: ArbitraryDecoder()))
print(try User(from: ArbitraryDecoder()))
print(try User(from: ArbitraryDecoder()))


/*:
 1. We skipped over the allKeys property of the KeyedDecodingContainerProtocol, but it’s what’s necessary to decode dictionaries of values. On initialization of the KeyedDecodingContainer, generate a random number of random CodingKeys to populate this property.

 You’ll need to return true from contains(_ key: Key).

 Decode a few random dictionaries of various decodable keys and values. What are some of the limitations of decoding dictionaries?
 */

// We need to specify Key and Value types.
print(try Dictionary<Int, User>(from: ArbitraryDecoder()))

/*:
 2. Create a new UnkeyedContainer struct that conforms to the UnkeyedContainerProtocol and return it from the unkeyedContainer() method of ArbitraryDecoder. As with the KeyedDecodingContainer, you can delete the same decode methods and have them delegate to the SingleValueContainer.

 The count property can be used to generate a randomly-sized container, while currentIndex and isAtEnd can be used to let the decoder know how far along it is. Generate a random count, default the currentIndex to 0, and define isAtEnd as a computed property using these values. The currentIndex property should increment whenever superDecoder is called.

 Decode a few random arrays of various decodable elements.
 */
print("2) Arrays")
print(try Array<User>(from: ArbitraryDecoder()))
print(try Array<String>(from: ArbitraryDecoder()))
print(try Array<Double>(from: ArbitraryDecoder()))
print(try Array<Bool>(from: ArbitraryDecoder()))
