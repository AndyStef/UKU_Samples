//
//  Useful comments.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/22/19.
//  Copyright © 2019 AS. All rights reserved.
//

import Foundation

// .userInteractive - highest - work is virtually instantaneous
// Work that is interacting with the user, such as operating on the main thread, refreshing the user interface, or performing animations. If the work doesn't happen quickly, the user interface may appear frozen. Focuses on responsiveness and performance
// UI updates -> Serial main queue

// .userInitiated - work is nearly instantaneous, such as a few seconds or less
// Work that the user has initiated and requires immediate results, such as opening a saved documents or performing an action when the user clicks something in the user interface. The work is required in order to continue user interaction. Focuses on responsiveness and performance
// async UI related tasks -> high priority global queue

// .utility - work takes a few seconds to a few minutes
// Work that may take some time to complete and doesn't require an immediate result, such as download or importing data. Utility tasks typically have a progress bar that is visible to the user. Focuses on providing a balance between responsiveness, performance, and energy efficiency.
// low priority global queue

// .background - lowest - work takes significant time, such as minutes or hours
// Work that operates in the background and isn't visible to the user, such as indexing, synchronizing, and backups. Focuses on energy efficiency

// .default
// .unspecified

// How you call async() informs the system where you want the code to run. GCD works with a system of queues, which are much like a real-world queue: they are First In, First Out (FIFO) blocks of code. What this means is that your GCD calls don't create threads to run in, they just get assigned to one of the existing threads for GCD to manage.

// GCD creates for you a number of queues, and places tasks in those queues depending on how important you say they are. All are FIFO, meaning that each block of code will be taken off the queue in the order they were put in, but more than one code block can be executed at the same time so the finish order isn't guaranteed.

// Can talk about [weak self] [unowned self] diff things)

// The Grand Central Dispatch (GCD, or just Dispatch) framework is based on the underlying thread pool design pattern. This means that there are a fixed number of threads spawned by the system - based on some factors like CPU cores - they're always available waiting for tasks to be executed concurrently.

// In the past a processor had one single core, it could only deal with one task at a time. Later on time-slicing was introduced, so CPU's could execute threads concurrently using context switching. As time passed by processors gained more horse power and cores so they were capable of real multi-tasking using parallelism.

// On every dispatch queue, tasks will be executed in the same order as you add them to the queue - FIFO the first task in the line will be executed first - but you should note that the order of completion is not guaranteed. Tasks will be completed according to the code complexity. So if you add two tasks to the queue, a slow one first and a fast one later, the fast one can finish before the slower one.

// Clasification
// Serial and Concurrent queues
// Main, Global and Custom queues
// Main queue is Serial one
// Global queues are system provided concurrent queues
// It is recommended to use only custom serial queues, use global for concurrent

// Sync is just an async call with a semaphore (explained later) that waits for the return value.
// DEADLOCK WARNING: you should never call sync on the main queue, because it'll cause a deadlock and a crash.
// Don't call sync on a serial queue from the serial queue's thread!

// DispatchWorkItem encapsulates work that can be performed. A work item can be dispatched onto a DispatchQueue and within a DispatchGroup. A DispatchWorkItem can also be set as a DispatchSource event, registration, or cancel handler.




// Plan of demo application:
// Explain why we should use background threads and explain why it is so important to keep user notified about system state
// Show some application with hard operation without any spinners and lagging UI
// Than add GCD in different ways and show that it is good)
