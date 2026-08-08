module alloy4fun_augmented_graphs_inv6
adj : set Node
}

pred inv6_oracle[] {
all n:Node | Node = n.*(adj+~adj)
}

pred inv6_correct_0[] {
Node->Node in *(adj + ~adj)
}

pred inv6_correct_1[] {
all a, b : Node | b in a.*(~adj + adj)
}

pred inv6_correct_2[] {
all n:Node | Node in n.*(adj+~adj)
}

pred inv6_correct_3[] {
all n : Node | Node = (n.^(adj + ~adj) + n)
}

pred inv6_correct_4[] {
one Node or all n : Node | Node in n.^(adj + ~adj)
}

pred inv6_correct_5[] {
all v : Node | Node in v.*(adj + ~adj)
}

pred inv6_correct_6[] {
all n: Node | n.*(adj + ~adj) = Node
}

pred inv6_correct_7[] {
all n: Node | Node - n in n.^(adj + ~adj)
}

pred inv6_correct_8[] {
all disj n1, n2 : Node | n2 in n1.^({n1 : Node, n2 : Node | n2 in n1.adj or n1 in n2.adj})
}

pred inv6_correct_9[] {
all n:Node | Node in (n+ n.*adj + *adj.n).*(adj+~adj)
}

pred inv6_correct_10[] {
all n1, n2: Node | n1 in n2.*(adj + ~adj)
}

pred inv6_correct_11[] {
(Node -> Node - iden) in ^(adj + ~adj)
}

pred inv6_correct_12[] {
all n1,n2:Node | n2 in n1.*(adj + ~adj)
}

pred inv6_correct_13[] {
all n:Node | Node in (n.^(adj + ~adj) + n)
}

pred inv6_correct_14[] {
all x : Node | Node in x.*(adj + ~adj)
}

pred inv6_correct_15[] {
all n : Node | Node in n.^(adj + ~adj + iden)
}

pred inv6_correct_16[] {
all n:Node | Node in (n.*(adj + ~adj) + n)
}

pred inv6_correct_17[] {
all a:Node, b:Node | b in a.*(adj + ~adj)
}

pred inv6_correct_18[] {
all n:Node | Node in n.*(~adj +adj)
}

pred inv6_correct_19[] {
all e1 : Node | Node in e1.*(adj + ~adj)
}

