sig User {
  follows: set User
}

pred aci {
  some u : User |
    u in User
    and u in User
    and u.follows in User
}
