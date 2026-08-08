module alloy4fun_augmented_graphs_inv3
adj : set Node
}

pred inv3_oracle[] {
all n : Node | n not in n.^adj
}

pred inv3_correct_0[] {
no n1: Node | n1 in n1.^adj
}

pred inv3_correct_1[] {
no iden & ^adj
}

pred inv3_correct_2[] {
all a:Node | a not in a.^adj
}

pred inv3_correct_3[] {
all v : Node | no v.(^adj) & v
}

pred inv3_correct_4[] {
all x : Node | no x.(^adj) & x
}

pred inv3_correct_5[] {
no (^adj & iden)
}

pred inv3_correct_6[] {
no n:Node | n in n.^adj
}

pred inv3_correct_7[] {
all n : Node | no n.^adj & n
}

pred inv3_correct_8[] {
all a:Node | no a.^adj & a.~(^adj)
}

pred inv3_correct_9[] {
all n : Node | n not in n.^adj

no (^adj & iden)

iden - ^adj = iden
}

pred inv3_correct_10[] {
all x: Node | x not in x.^adj
}

pred inv3_correct_11[] {
iden - ^adj = iden
}

pred inv3_correct_12[] {
all n : Node | n not in  n.adj.*adj
}

pred inv3_correct_13[] {
all e1 : Node | e1 not in e1.^adj
}

pred inv3_correct_14[] {
inv2
all n : Node | n not in n.(^adj)
}

pred inv3_correct_15[] {
no p: Node | p in p.^adj
}

pred inv3_correct_16[] {
all x, y : Node | x->y in adj implies y->x not in adj and no x.(^adj) & x
}

pred inv3_correct_17[] {
all n : Node | not (n in n.^adj)
}

pred inv3_correct_18[] {
all n : Node | n->n not in ^adj
}

pred inv3_correct_19[] {
all n : Node | no (^adj).n & n
}

pred inv3_correct_20[] {
all n : Node | n not in n.^adj

no (^adj & iden)
}

