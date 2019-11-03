enum Validated<Valid, Invalid> {
  case valid(Valid, String)
  case invalid([Invalid], String)
}
