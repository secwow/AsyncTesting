import Foundation

extension DispatchQueue {
    static func performImmediateWhenOnMainQueue(block: @escaping () -> ()) {
        guard Self.current == Self.main else {
            DispatchQueue.main.async {
                block()
            }
            return
        }

        block()
    }

    static func immediateWhenOnMainQueue(block: @escaping () -> ()) -> () -> () {
        return {
            DispatchQueue.performImmediateWhenOnMainQueue(block: block)
        }
    }

    private struct QueueReference { weak var queue: DispatchQueue? }

    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        setupSystemQueuesDetection(key: key)
        return key
    }()

    private static func _registerDetection(of queues: [DispatchQueue], key: DispatchSpecificKey<QueueReference>) {
        queues.forEach { $0.setSpecific(key: key, value: QueueReference(queue: $0)) }
    }

    private static func setupSystemQueuesDetection(key: DispatchSpecificKey<QueueReference>) {
        let queues: [DispatchQueue] = [
                                        .main,
                                        .global(qos: .background),
                                        .global(qos: .default),
                                        .global(qos: .unspecified),
                                        .global(qos: .userInitiated),
                                        .global(qos: .userInteractive),
                                        .global(qos: .utility)
                                    ]
        _registerDetection(of: queues, key: key)
    }
}



extension DispatchQueue {
    static func registerDetection(of queue: DispatchQueue) {
        _registerDetection(of: [queue], key: key)
    }

    static var currentQueueLabel: String? { current?.label }
    static var current: DispatchQueue? { getSpecific(key: key)?.queue }
}
