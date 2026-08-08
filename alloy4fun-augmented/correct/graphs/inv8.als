module alloy4fun_augmented_graphs_inv8
adj : set Node
}

pred inv8_oracle[] {
adj = ^adj
}

pred inv8_correct_0[] {
all n1,n2,n3:Node | n1->n2 in adj and n2->n3 in adj implies n1->n3 in adj
}

pred inv8_correct_1[] {
all n, n1, n2 : Node | n->n1 in adj and n1->n2 in adj => n->n2 in adj
}

pred inv8_correct_2[] {
all n1,n2,n3:Node | some (n1.adj:>n2) and some (n2.adj:>n3) implies some n1.adj:>n3
}

pred inv8_correct_3[] {
all n: Node | n.adj.adj in n.adj
}

pred inv8_correct_4[] {
all v1,v2,v3:Node | v1->v2 in adj and v2->v3 in adj implies v1->v3 in adj
}

pred inv8_correct_5[] {
all n1, n2, n3: Node | ((n2 in n1.adj) and (n3 in n2.adj)) => n3 in n1.adj
}

pred inv8_correct_6[] {
adj.^adj in adj
}

pred inv8_correct_7[] {
all e1 : Node | e1.adj.adj in e1.adj
}

pred inv8_correct_8[] {
all n,nn,nnn : Node | nn in n.adj.adj implies nn in n.adj
}

pred inv8_correct_9[] {
adj.adj in adj
}

pred inv8_correct_10[] {
all n : Node | n->n.adj.adj in adj
}

pred inv8_correct_11[] {
all x, y, z : Node | x->y in adj and y->z in adj implies x->z in adj
}

pred inv8_correct_12[] {
all n:Node, x:Node | n in x.^adj => n in x.adj
}

pred inv8_correct_13[] {
all a,b,c : Node | c in b.adj and b in a.adj implies c in a.adj
}

pred inv8_correct_14[] {
all  a,b,c : Node | (a in adj.b and c in b.adj) => c in a.adj

all n1,n2 : Node | n2 in n1.adj.adj => n2 in n1.adj

all disj n1,n2 : Node | n2 in n1.adj.adj => n2 in n1.adj
}

pred inv8_correct_15[] {
all a,b,c:Node | a->b in adj and b->c in adj implies a->c in adj
}

pred inv8_correct_16[] {
all  a,b,c : Node | (a in adj.b and c in b.adj) => c in a.adj
}

pred inv8_correct_17[] {
all n1,n2:Node | n2 in (n1.adj).adj implies n2 in n1.adj
}

pred inv8_correct_18[] {
all a:Node , b:Node, c:Node | (a->b in adj && b->c in adj) implies a->c in adj
}

pred inv8_correct_19[] {
all n1, n2: Node | n1 in n2.^adj iff n1 in n2.adj
}

pred inv8_correct_20[] {
all x, y, z: Node | x in y.adj and y in z.adj implies x in z.adj
}

pred inv8_correct_21[] {
all n,o,p:Node | n->o in adj and o->p in adj implies n->p in adj
}

pred inv8_correct_22[] {
^adj in adj
}

