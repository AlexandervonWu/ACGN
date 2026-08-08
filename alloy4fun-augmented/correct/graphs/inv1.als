module alloy4fun_augmented_graphs_inv1
adj : set Node
}

pred inv1_oracle[] {
adj = ~adj
}

pred inv1_correct_0[] {
all a,b: Node | a->b in adj implies b->a in adj
}

pred inv1_correct_1[] {
all disj n1,n2 : Node | n2 in n1.adj => n2 in adj.n1
}

pred inv1_correct_2[] {
all x,y:Node | x->y in adj implies y->x in adj
}

pred inv1_correct_3[] {
all n:Node, n2:Node | n2 in n.adj => n in n2.adj
}

pred inv1_correct_4[] {
all n,m: Node | m in n.adj => n in m.adj
}

pred inv1_correct_5[] {
(adj & ~adj) = adj
}

pred inv1_correct_6[] {
all n1,n2:Node | n1->n2 in adj implies n2->n1 in adj
}

pred inv1_correct_7[] {
all n1, n2 : Node | n1->n2 in adj <=> n2->n1 in adj
}

pred inv1_correct_8[] {
all n1 : Node | n1.adj = adj.n1
}

pred inv1_correct_9[] {
no (adj - ~adj )
}

pred inv1_correct_10[] {
all disj n1, n2: Node | n2 in n1.adj <=> n1 in n2.adj
}

pred inv1_correct_11[] {
all a,b : Node | b in a.adj implies a in b.adj
}

pred inv1_correct_12[] {
all n : Node, n2: n.adj | n in n2.adj
}

pred inv1_correct_13[] {
adj in ~adj
}

pred inv1_correct_14[] {
all n: Node | all a: n.adj | n in a.adj
}

pred inv1_correct_15[] {
all disj n1,n2: Node |n1->n2 in adj implies n2->n1 in adj
}

pred inv1_correct_16[] {
all disj n, n1 : Node | n->n1 in adj => n1->n in adj
}

pred inv1_correct_17[] {
(adj in ~adj) and (~adj in adj)
}

pred inv1_correct_18[] {
all n1, n2:Node | n1 in n2.adj implies n2 in n1.adj
}

pred inv1_correct_19[] {
all n, m : Node | n->m in adj iff m->n in adj
}

pred inv1_correct_20[] {
all n1,n2:Node | n1 in n2.adj <=> n2 in n1.adj
}

pred inv1_correct_21[] {
adj = adj + ~adj
}

pred inv1_correct_22[] {
~adj = adj
}

pred inv1_correct_23[] {
all disj n1, n2 :Node | n1 in n2.adj implies n2 in n1.adj
}

pred inv1_correct_24[] {
all n : Node, a : n.adj | n->a in adj implies a->n in adj
}

pred inv1_correct_25[] {
all n:Node | n.adj in adj.n
}

pred inv1_correct_26[] {
all n1,n2 :Node | n1->n2 in adj  implies n2->n1 in adj
all n:Node |  (n.adj  in adj.n)
}

pred inv1_correct_27[] {
all n1,n2:Node | some n1.adj:>n2 implies some n2.adj:>n1
}

pred inv1_correct_28[] {
all disj n, n1 : Node | n1 in n.adj <=> n in n1.adj
}

pred inv1_correct_29[] {
all n1,n2 : Node | n2 in n1.adj implies n1 in n2.adj
}

pred inv1_correct_30[] {
all disj n, n1 : Node | n->n1 in adj <=> n1->n in adj
}

pred inv1_correct_31[] {
all disj n1,n2: Node | n1 in n2.adj iff n2 in n1.adj
}

pred inv1_correct_32[] {
all v1, v2 : Node | v1->v2 in adj implies v2->v1 in adj
}

pred inv1_correct_33[] {
all n,x:Node | n->x in adj implies x->n in adj
}

pred inv1_correct_34[] {
all n : Node, a : n.adj | a->n in adj
}

pred inv1_correct_35[] {
all n, n1 : Node | n->n1 in adj => n1->n in adj
}

pred inv1_correct_36[] {
all n : Node | n.adj = adj.n
}

pred inv1_correct_37[] {
adj in adj & ~adj
}

pred inv1_correct_38[] {
all e1, e2 : Node | e1 -> e2 in adj implies e2 -> e1 in adj
}

pred inv1_correct_39[] {
all a,b:Node | b->a in adj implies a->b in adj
}

pred inv1_correct_40[] {
all x, y: Node | y in x.adj implies x in y.adj
}

pred inv1_correct_41[] {
all n:Node | adj.n in n.adj
}

pred inv1_correct_42[] {
all n1, n2: Node | n2 in n1.adj iff n1 in n2.adj
}

pred inv1_correct_43[] {
all a:Node,b:Node | a->b in adj implies b->a in adj
}

pred inv1_correct_44[] {
all n : Node | ~(n->(n.adj)) in adj
}

pred inv1_correct_45[] {
all disj n1, n2: Node | n2 in n1.adj => n1 in n2.adj
}

