import Vapor
import Jobs

struct MyScheduledJob: Job {
    func dequeue(_ context: JobContext, _ payload: String) -> EventLoopFuture<Void> {
        // Functionality to execute weekly
        print("Running scheduled job at \(Date())")
        return context.eventLoop.makeSucceededFuture(())
    }
}
