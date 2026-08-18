sig User {
  follows: set User
}

fun neighbors[u: User]: set User {
  u.follows
}
