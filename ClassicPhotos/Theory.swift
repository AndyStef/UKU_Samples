/// Copyright (c) 2019 Razeware LLC


import Foundation


// Operation and OperationQueue are built on top of GCD. As a very general rule, Apple recommends using the highest-level abstraction, then dropping down to lower levels when measurements show this is necessary.


// GCD is a lightweight way to represent units of work that are going to be executed concurrently. You don’t schedule these units of work; the system takes care of scheduling for you. Adding dependency among blocks can be a headache. Canceling or suspending a block creates extra work for you as a developer!

// Operation adds a little extra overhead compared to GCD, but you can add dependency among various operations and re-use, cancel or suspend them.
