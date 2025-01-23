package BVIApplication;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class CustomPriorityBlockingQueue<T> {
    private final List<T> queue; // The queue of commands
    private final Comparator<? super T> comparator; // Comparator to determine priority
    private final int capacity;
    private final ReentrantLock lock = new ReentrantLock();
    private final Condition notEmpty = lock.newCondition();
    private final Condition notFull = lock.newCondition();

    public CustomPriorityBlockingQueue(int capacity, Comparator<? super T> comparator) {
        this.capacity = capacity;
        this.comparator = comparator;
        this.queue = new ArrayList<>(capacity);
    }

    /**
     * Add a command to the queue.
     * If the queue is full, it waits in notFull.await() until space is available.
     */
    public void put(T command) throws InterruptedException {
        lock.lock();
        try {
            while (queue.size() >= capacity) {
                notFull.await();
            }
            queue.add(command);
            queue.sort(comparator); // Sort according to priority order
            notEmpty.signal(); // Signal that the queue is no longer empty
        } finally {
            lock.unlock();
        }
    }

    /**
     * Retrieves and removes the highest-priority command.
     * If the queue is empty, it waits in notEmpty.await() until a command is
     * available.
     */
    public T take() throws InterruptedException {
        lock.lock();
        try {
            while (queue.isEmpty()) {
                notEmpty.await();
            }
            T command = queue.remove(0); // Remove the highest-priority command
            notFull.signal(); // Signal that the queue is no longer full
            return command;
        } finally {
            lock.unlock();
        }
    }

    /**
     * Returns the current size of the queue.
     */
    public int size() {
        lock.lock();
        try {
            return queue.size();
        } finally {
            lock.unlock();
        }
    }

    /**
     * Checks if the queue is empty.
     */
    public boolean isEmpty() {
        lock.lock();
        try {
            return queue.isEmpty();
        } finally {
            lock.unlock();
        }
    }
    
    /**
     * Checks if the queue is full.
     */
    public boolean isFull() {
        lock.lock();
        try {
            return queue.size() >= capacity;
        } finally {
            lock.unlock();
        }
    }

    /**
     * Get a copy of all commands from the queue.
     */
    public List<T> getAll() {
        lock.lock();
        try {
            return new ArrayList<>(queue); // Return a copy of the queue
        } finally {
            lock.unlock();
        }
    }
    
    /**
     * Remove specific command from queue.
     */
    public void remove(T command) {
        lock.lock();
        try {
            queue.remove(command);
            queue.sort(comparator); // Sort according to priority order
            notFull.signal();
        } finally {
            lock.unlock();
        }
    }

}
