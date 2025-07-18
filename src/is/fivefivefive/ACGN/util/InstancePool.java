package is.fivefivefive.ACGN.util;

import edu.mit.csail.sdg.translator.A4Solution;

/**
 * InstancePool is the LFU (Least Frequently Used) cache for instances.
 * It stores instances of the oracle solutions and provides methods to retrieve them.
 * For each time there is a predicate generated that matches all instances in the pool, 
 * if the new predicate is not an equivalent of the oracle solution,
 * and if the pool is full, the least frequently un-matched instance will be removed.
 */
public class InstancePool {
    private static class AlloyInstance {    
        public A4Solution instance;
        public AlloyInstance next;
        public AlloyInstance last;
        public int usageFrequency = 0; // for LFU cache
        public AlloyInstance(A4Solution instance) {
            this.instance = instance;
            this.next = null;
            this.last = null;
            this.usageFrequency = 1; // initial usage frequency
        }
    }
    private AlloyInstance head;
    private AlloyInstance tail;
    private int size;
    private final int capacity;
    public InstancePool(int capacity) {
        this.capacity = capacity;
        this.size = 0;
        this.head = null;
        this.tail = null;
    }
    public void add(A4Solution instance) {
        AlloyInstance newInstance = new AlloyInstance(instance);
        if (size == capacity) {
            // remove the least frequently used instance
            AlloyInstance toRemove = head;
            head = head.next;
            if (head != null) {
                head.last = null;
            }
            size--;
        }
        if (head == null) {
            head = newInstance;
            tail = newInstance;
        } else {
            tail.next = newInstance;
            newInstance.last = tail;
            tail = newInstance;
        }
        size++;
    }
    public A4Solution get(int index) {
        if (index < 0 || index >= size) {
            throw new IndexOutOfBoundsException("Index out of bounds: " + index);
        }
        AlloyInstance current = head;
        for (int i = 0; i < index; i++) {
            current = current.next;
        }
        current.usageFrequency++;
        // Move the accessed instance to the end of the list
        if (current != tail) {
            if (current == head) {
                head = current.next;
                head.last = null;
            } else {
                current.last.next = current.next;
                if (current.next != null) {
                    current.next.last = current.last;
                }
            }
            tail.next = current;
            current.last = tail;
            current.next = null;
            tail = current;
        }
        return current.instance;
    }
    public int size() {
        return size;
    }
    public boolean isEmpty() {
        return size == 0;
    }
    public void clear() {
        head = null;
        tail = null;
        size = 0;
    }
    public int getCapacity() {
        return capacity;
    }
    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("InstancePool: [");
        AlloyInstance current = head;
        while (current != null) {
            sb.append(current.instance.toString()).append(", ");
            current = current.next;
        }
        if (sb.length() > 2) {
            sb.setLength(sb.length() - 2); // remove last comma and space
        }
        sb.append("]");
        return sb.toString();
    }
    public boolean contains(A4Solution instance) {
        AlloyInstance current = head;
        while (current != null) {
            if (current.instance.equals(instance)) {
                return true;
            }
            current = current.next;
        }
        return false;
    }
    public void remove(A4Solution instance) {
        AlloyInstance current = head;
        while (current != null) {
            if (current.instance.equals(instance)) {
                if (current == head) {
                    head = current.next;
                    if (head != null) {
                        head.last = null;
                    }
                } else if (current == tail) {
                    tail = current.last;
                    if (tail != null) {
                        tail.next = null;
                    }
                } else {
                    current.last.next = current.next;
                    if (current.next != null) {
                        current.next.last = current.last;
                    }
                }
                size--;
                return;
            }
            current = current.next;
        }
    }
    public boolean isFull() {
        return size == capacity;
    }
    public A4Solution getHead() {
        return head.instance;
    }
    public A4Solution getTail() {
        return tail.instance;
    }
    public void setHead(AlloyInstance head) {
        this.head = head;
    }
    public void setTail(AlloyInstance tail) {
        this.tail = tail;
    }
    public int getUsageFrequency(A4Solution instance) {
        AlloyInstance current = head;
        while (current != null) {
            if (current.instance.equals(instance)) {
                return current.usageFrequency;
            }
            current = current.next;
        }
        return 0; // instance not found
    }
    public void incrementUsageFrequency(A4Solution instance) {
        AlloyInstance current = head;
        while (current != null) {
            if (current.instance.equals(instance)) {
                current.usageFrequency++;
                return;
            }
            current = current.next;
        }
        throw new IllegalArgumentException("Instance not found in the pool: " + instance);
    }
    public void decrementUsageFrequency(A4Solution instance) {
        AlloyInstance current = head;
        while (current != null) {
            if (current.instance.equals(instance)) {
                if (current.usageFrequency > 0) {
                    current.usageFrequency--;
                }
                return;
            }
            current = current.next;
        }
        throw new IllegalArgumentException("Instance not found in the pool: " + instance);
    }
    public void removeLeastFrequentlyUsed() {
        if (head == null) {
            return; // Pool is empty
        }
        AlloyInstance leastUsed = head;
        AlloyInstance current = head;
        while (current != null) {
            if (current.usageFrequency < leastUsed.usageFrequency) {
                leastUsed = current;
            }
            current = current.next;
        }
        remove(leastUsed.instance); // Remove the least frequently used instance
    }
}
