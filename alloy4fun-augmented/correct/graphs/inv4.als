module alloy4fun_augmented_graphs_inv4
adj : set Node
}

pred inv4_oracle[] {
adj = Node -> Node
}

pred inv4_correct_0[] {
all n1, n2 : Node | n2 in n1.adj
}

pred inv4_correct_1[] {
all n1, n2: Node | n1 in n2.adj and n2 in n1.adj
}

pred inv4_correct_2[] {
all n: Node | Node in n.adj
}

pred inv4_correct_3[] {
all  n1,n2 :Node | n1->n2 in adj
}

pred inv4_correct_4[] {
Node->Node in adj
}

pred inv4_correct_5[] {
all n: Node | n.adj = Node
}

pred inv4_correct_6[] {
all x : Node | x.adj  = Node
}

pred inv4_correct_7[] {
all n1, n2: Node | n1->n2 + n2->n1 in adj
}

pred inv4_correct_8[] {
all n:Node , a:Node | n->a in adj
}

pred inv4_correct_9[] {
all n1,n2 : Node | n1 in n2.adj
}

pred inv4_correct_10[] {
all a,b : Node | a->b in adj
}

pred inv4_correct_11[] {
all n:Node, x:Node| n in x.adj && x in n.adj
}

pred inv4_correct_12[] {
all n : Node | Node in n.adj and n.adj in Node
}

pred inv4_correct_13[] {
all a,b : Node | a in b.adj
}

pred inv4_correct_14[] {
all n, m: Node | n->m in adj
}

pred inv4_correct_15[] {
all n : Node | n.adj = Node

all disj n1,n2 : Node | n1 in adj.n2

all n1, n2 : Node | n2 in n1.adj
}

pred inv4_correct_16[] {
all a:Node,b:Node |  a->b in adj
}

pred inv4_correct_17[] {
all a,b : Node | a in b.adj





adj = Node->Node
}

pred inv4_correct_18[] {
no n:Node | Node not in n.adj
}

pred inv4_correct_19[] {
all n1, n2 : Node | n2 in n1.adj
all n : Node | n.adj = Node
}

pred inv4_correct_20[] {
Node->Node = adj
}

pred inv4_correct_21[] {
all n : Node | n.adj = Node

all disj n1,n2 : Node | n1 in adj.n2
}

pred inv4_correct_22[] {
all a,b : Node | a->b in adj






adj = Node->Node
}

pred inv4_correct_23[] {
all n: Node | Node = n.adj
}

pred inv4_correct_24[] {
all n1:Node | n1.adj:>Node = Node
}

pred inv4_correct_25[] {
all n1, n2: Node | n1->n2 + n2->n1 in adj
all n: Node | Node = n.adj
}

pred inv4_correct_26[] {
all a, b : Node | b in a.adj
}

