module alloy4fun_augmented_graphs_inv7
adj : set Node
}

pred inv7_oracle[] {
all n:Node | Node = n.*adj
}

pred inv7_correct_0[] {
all n: Node | Node - n in n.^adj
}

pred inv7_correct_1[] {
all n1,n2:Node | n2 in n1.*adj
}

pred inv7_correct_2[] {
all n:Node | Node in n.*adj
}

pred inv7_correct_3[] {
all disj x,y : Node | x in y.^adj
}

pred inv7_correct_4[] {
all x : Node | Node in x.*adj
}

pred inv7_correct_5[] {
Node->Node in *(adj)
}

pred inv7_correct_6[] {
all n1, n2: Node | n1 in n2.*adj
}

pred inv7_correct_7[] {
all n: Node | n.*adj = Node
}

pred inv7_correct_8[] {
(Node -> Node - iden) in ^(adj)
}

pred inv7_correct_9[] {
all v : Node | Node in v.*adj
}

pred inv7_correct_10[] {
all n : Node | Node = (n.^adj + n)
}

pred inv7_correct_11[] {
one Node or all n : Node | Node in n.^adj
}

pred inv7_correct_12[] {
all e1 : Node | Node in (e1.*adj)
}

pred inv7_correct_13[] {
all x : Node | Node in x.^adj + x
}

pred inv7_correct_14[] {
all disj n1,n2: Node | n1 in n2.^adj and n2 in n1.^adj
}

pred inv7_correct_15[] {
all n : Node | Node in n.^adj || one Node
}

pred inv7_correct_16[] {
all a:Node , b:Node| b in a.*adj
}

pred inv7_correct_17[] {
all a, b : Node | a in b.*adj
}

pred inv7_correct_18[] {
all n : Node | Node in n.(^adj + iden)
}

pred inv7_correct_19[] {
all disj n1, n2 : Node | n2 in n1.^adj
}

