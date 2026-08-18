sig User {
  follows: set User
}

pred prenex {
  (some x : User | x in User)
  implies
  (all y : User | y in User)
}
