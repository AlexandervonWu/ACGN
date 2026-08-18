sig User {
    follows: set User,
    suggested: set User
}

sig Influencer extends User {}

pred inv7 {
    all u1, u2, u3 : User |
        u3 in u1.follows
        and u3 in follows.u2
        and u1 not in follows.u2
        implies u2 in u1.suggested

    all u : User |
        u not in u.suggested

    all u1, u2 : User |
        u2 in u1.follows
        implies u2 not in u1.suggested

    all u : User |
        #(u.follows) = 0
        implies #(u.suggested) = 0

    all u : User |
        all i : Influencer |
            i not in u.suggested
}
