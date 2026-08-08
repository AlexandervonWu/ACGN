module alloy4fun_augmented_graphs_inv2
adj : set Node
}

pred inv2_oracle[] {
no adj & ~adj
}

pred inv2_correct_0[] {
all n1,n2:Node | n1 in n2.adj implies n2 not in n1.adj
}

pred inv2_correct_1[] {
all n: Node | n not in n.adj.adj
}

pred inv2_correct_2[] {
no iden & adj.adj
}

pred inv2_correct_3[] {
all n1,n2:Node | n1->n2 in adj implies n2->n1 not in adj
}

pred inv2_correct_4[] {
all n : Node | no (n.adj & n.(~adj))
}

pred inv2_correct_5[] {
all n : Node | all a : n.adj | n  not in a.adj
}

pred inv2_correct_6[] {
not some n1, n2: Node | n1->n2 in adj and n2->n1 in adj
}

pred inv2_correct_7[] {
all x, y : Node | x->y in adj implies y->x not in adj
}

pred inv2_correct_8[] {
all n1,n2:Node | n1 in n2.adj => n2 in (univ - n1.adj)
}

pred inv2_correct_9[] {
all n : Node | n not in n.adj.adj
no (iden & adj.adj)
}

pred inv2_correct_10[] {
adj - ~adj = adj
}

pred inv2_correct_11[] {
all a,b:Node | a->b in adj implies b->a not in adj
}

pred inv2_correct_12[] {
all n1,n2: Node | (n1 in n2.adj => not (n2 in n1.adj))
}

pred inv2_correct_13[] {
no n : Node, n2 : n.adj | n in n2.adj
}

pred inv2_correct_14[] {
all n,m: Node | m in n.adj => n not in m.adj
}

pred inv2_correct_15[] {
all e1, e2 : Node | e1 -> e2 in adj implies e2 -> e1 not in adj
}

pred inv2_correct_16[] {
all n:Node.adj |all x:n.adj | n not in x.adj
}

pred inv2_correct_17[] {
all n1, n2 : Node | n1->n2 in adj implies not n2->n1 in adj
}

pred inv2_correct_18[] {
all a,b : Node | b in a.adj implies a not in b.adj
}

pred inv2_correct_19[] {
all x, y, z: Node | (y in x.adj and z in y.adj) implies z != x
}

pred inv2_correct_20[] {
#(adj - ~adj) = #adj
}

pred inv2_correct_21[] {
all n1,n2:Node | some n1.adj:>n2 implies no n2.adj:>n1
}

pred inv2_correct_22[] {
all v1, v2 : Node | v1->v2 in adj implies not v2->v1 in adj
no adj & ~adj
}

pred inv2_correct_23[] {
all n, n1 : Node | n->n1 in adj => n1->n not in adj

adj & ~adj in iden
}

pred inv2_correct_24[] {
all e1 : Node | no e1.adj & adj.e1
}

pred inv2_correct_25[] {
all n, m : Node | n->m in adj implies m->n not in adj
}

pred inv2_correct_26[] {
all n, n1 : Node | n->n1 in adj => n1->n not in adj
}

pred inv2_correct_27[] {
no ~adj & adj
}

pred inv2_correct_28[] {
all v1, v2 : Node | v1->v2 in adj implies not v2->v1 in adj
}

pred inv2_correct_29[] {
all a:Node,b:Node | a->b in adj implies not (b->a in adj)
}

pred inv2_correct_30[] {
all n1,n2:Node | n2 in n1.adj implies n1 not in n2.adj
}

pred inv2_correct_31[] {
all n,x:Node | n->x in adj implies x->n not in adj
}

pred inv2_correct_32[] {
all disj n, n1 : Node | n->n1 in adj => n1->n not in adj
all n: Node, n1 : n.adj | n not in n1.adj
}

pred inv2_correct_33[] {
all n : Node, n2 : n.adj | n not in n2.adj
}

pred inv2_correct_34[] {
all n:Node, n2:n.adj | not n in n2.adj
}

