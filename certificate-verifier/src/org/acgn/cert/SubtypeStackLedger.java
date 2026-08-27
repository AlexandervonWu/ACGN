package org.acgn.cert;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Single-valued top-to-bottom subtype stacks for dependent-chain replay. */
final class SubtypeStackLedger<K> {
    private final Map<K, List<K>> stacksByTop = new HashMap<>();
    private final Map<K, K> directParents = new HashMap<>();

    void register(K top, List<K> stack) {
        K checkedTop = Objects.requireNonNull(top, "subtype stack top");
        List<K> checkedStack = List.copyOf(
                Objects.requireNonNull(stack, "subtype stack"));
        if (checkedStack.isEmpty() || !checkedTop.equals(checkedStack.get(0))) {
            throw new IllegalArgumentException(
                    "A subtype stack must start at its exact top key");
        }
        List<K> prior = stacksByTop.putIfAbsent(checkedTop, checkedStack);
        if (prior != null && !prior.equals(checkedStack)) {
            throw new IllegalArgumentException(
                    "One exact dependent-chain carrier has conflicting subtype stacks");
        }
        for (int index = 1; index < checkedStack.size(); index++) {
            K child = checkedStack.get(index - 1);
            K parent = checkedStack.get(index);
            K oldParent = directParents.putIfAbsent(child, parent);
            if (oldParent != null && !oldParent.equals(parent)) {
                throw new IllegalArgumentException(
                        "One dependent-chain carrier has two direct parents");
            }
            K cursor = parent;
            Set<K> seen = new HashSet<>();
            seen.add(child);
            while (cursor != null) {
                if (!seen.add(cursor)) {
                    throw new IllegalArgumentException(
                            "Dependent-chain subtype stacks contain a cycle");
                }
                cursor = directParents.get(cursor);
            }
        }
    }
}
