module alloy4fun_augmented_graphs_inv5
adj : set Node
}

pred inv5_oracle[] {
no adj & iden
}

pred inv5_correct_0[] {
all n1,n2:Node | some n1.adj:>n2 implies n1 != n2
}

pred inv5_correct_1[] {
no n:Node | n->n in adj
}

pred inv5_correct_2[] {
no n:Node | n in n.adj
}

pred inv5_correct_3[] {
all n:Node | n not in n.adj
}

pred inv5_correct_4[] {
all n:Node | n not in adj.n
}

pred inv5_correct_5[] {
no iden & adj
}

pred inv5_correct_6[] {
all n : Node | n->n not in adj
}

pred inv5_correct_7[] {
all n: Node | not n->n in adj
}

pred inv5_correct_8[] {
all v : Node | not v->v in adj
}

pred inv5_correct_9[] {
no (iden & adj & ~adj)
}

pred inv5_correct_10[] {
all n: Node | not n->n in adj
all n: Node | n not in n.adj
}

pred inv5_correct_11[] {
no iden & adj

all n : Node | n not in n.adj
}

pred inv5_correct_12[] {
all n: Node | n->n not in adj
all n: Node | n not in n.adj
}

pred inv5_correct_13[] {
no (iden & adj & ~adj)
no (iden & adj)
}

pred inv5_correct_14[] {
all a:Node | not a->a in adj
}

pred inv5_correct_15[] {
all x : Node | not x->x in adj
}

pred inv5_correct_16[] {
no n1: Node | n1 in n1.adj
}

pred inv5_correct_17[] {
all a : Node | a -> a not in adj
}

pred inv5_correct_18[] {
all e1 : Node | e1 not in e1.adj
}

pred inv5_correct_19[] {
all n1:Node | n1 not in adj.n1
}

pred inv5_correct_20[] {
all n1:Node | n1->n1 not in adj
}

pred inv5_correct_21[] {
all n1: Node | not n1->n1 in adj
}

pred inv5_correct_22[] {
all x, y: Node | x in y.adj implies x != y
}

