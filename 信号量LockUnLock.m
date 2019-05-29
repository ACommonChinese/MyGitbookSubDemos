信号量LOCK, UNLOCK

@property (strong, nonatomic, nonnull) dispatch_semaphore_t failedURLsLock; // a lock to keep the access to `failedURLs` thread-safe

init {
    _failedURLsLock = dispatch_semaphore_create(1);
}

// LOCK(_failedURLsLock)
#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);
// #define SD_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);

BOOL isFailedUrl = NO
if (url) {
    LOCK(self.failedURLsLock);
    isFailedUrl = [self.failedURLs containsObject:url];
    UNLOCK(self.failedURLsLock);
}

====================================================================================

dispatch_main_async_safe 和 dispatch_queue_async_safe
参考链接：https://www.jianshu.com/p/7f68a3d5b07d

// 此方法获取label:
dispatch_queue_get_label(dispatch_queue_t  _Nullable queue)
// Returns the label specified for the queue when the queue was created. The label of the queue, or NULL if the queue was not provided a label during initialization.
// Pass parameter queue to DISPATCH_CURRENT_QUEUE_LABEL to retrieve the label of current queue, DISPATCH_CURRENT_QUEUE_LABEL is defined as NULL
const char *queue_label = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
printf("queue_label: %s\n", queue_label); // com.apple.main-thread

需求：在queue中执行一个block，如果当前线程和queue是一个，则直接执行，否则，相当于调用：
// dispatch_async(dispatch_queue_t  _Nonnull queue, ^(void)block)

-- SDWebImageCompat.h --
#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)\
    if (dispatch_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)) {\
        block();\
    } else {\
        dispatch_async(queue, block);\
    }
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif

====================================================================================


