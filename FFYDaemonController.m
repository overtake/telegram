//
//  <!-- FFYDaemonController -->
//  Based in *DaemonController* by 
//  [Max Howell](https://github.com/mxcl/playdar.prefpane/blob/master/DaemonController.h).
//

// **DaemonController** is a tool to monitor daemons using Objective C, that are
// running in the system. The idea is to keep it simple, and provide methods to
// start, and stop a given daemon. It also watches for the PID, in order to give
// feedback about when the process is stopped by an external tool.

// ## Installation
//
// To install, just add the FFYDaemonController.h and FFYDaemonController.m files to your
// project. Then, be shure to add FFYDaemonController.m to your selected target.

// ## Usage
//
// Just include the FFYDaemonController.h file in your Class:
//
//     include "FFYDaemonController.h";
//
// Then, create an instance of it
//
//     FFYDaemonController *daemonController = [[FFYDaemonController alloc]
//       init];
//
// Set the launch path for the Daemon to watch:
//
//     daemonController.launchPath =
//       @"/usr/local/Cellar/mysql/5.1.56/libexec/mysqld";
//
// Set the initialization arguments, if any:
//
//     daemonController.startArguments = [NSArray arrayWithObjects:
//       @"--basedir=/usr/local/Cellar/mysql/5.1.56",
//       @"--datadir=/usr/local/var/mysql",
//       @"--log-error=/usr/local/var/mysql/localjost.local.err",
//       @"--pid-file=/usr/local/var/mysql/localjost.local.pid", nil];
//
// Finally,  there's an especial list of arguments in order to stop the daemon:
//
//     daemonController.stopArguments = [NSArrary arrayWithObjects:
//       @"stop", nil];
//
// That's it. In order to get notifications about the status of the process, just set the
// block callbacks for any operation you need. Please refer to the [Callbacks][cbs]
// section in order to get more information on how to add them.
//
// To control the daemon, there are two simple tasks, start and stop. Please refer to the
// [Control Tasks][dct] for more information.
//
// [cbs]: #section-Callbacks
// [dct]: #section-Control_Tasks

#import <sys/sysctl.h>
#import "FFYDaemonController.h"

// ## Hidden Methods
//
// Here are the instance variables and methods used internally to control the Daemon.
//
// The binary name is stored in order to get the PID of the daemon.
//
// There's a reference to a poll timer, if it is not running yet, it will poll for it
// until there's a running process of it.
//
// The daemon task holds the active task, in case that the daemon was initialized by us.
//
@interface FFYDaemonController(/* Hidden Methods */)
@property (nonatomic, retain) NSString *binaryName;
@property (nonatomic, retain) NSTimer  *pollTimer;
@property (nonatomic, retain) NSTask   *daemonTask;
@property (nonatomic, retain) NSTimer  *checkStartupStatusTimer;

- (void)startPoll;
- (void)daemonTerminatedFromQueue;
- (void)daemonTerminated:(NSNotification*)notification;
- (void)initDaemonTask;
- (void)poll:(NSTimer*)timer;
- (void)failedToStartDaemonTask:(NSString *)reason;
- (void)checkIfDaemonIsRunning;
- (BOOL)didStopWithArguments;
@end

// ## C Methods
//
// Checks for the PID of a given daemon. If it's running, it will return the
// PID. If not, it will return 0.
static pid_t daemon_pid(const char *binary) {
  int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
  struct kinfo_proc *info;
  size_t totalTasks;
  pid_t pid = 0;

  // Means that there are no running tasks. Very unlikely.
  if (sysctl(mib, 3, NULL, &totalTasks, NULL, 0) < 0)
    return 0;
  // Not able to allocate the memory. Unlikey.
  if (!(info = NSZoneMalloc(NULL, totalTasks)))
    return 0;
  if (sysctl(mib, 3, info, &totalTasks, NULL, 0) >= 0) {
    // Search for the process id that matches the name of our daemon.
    totalTasks = totalTasks / sizeof(struct kinfo_proc);
    for(size_t i = 0; i < totalTasks; i++)
      // If found, store it in pid.
      if(strcmp(info[i].kp_proc.p_comm, binary) == 0) {
        pid = info[i].kp_proc.p_pid;
        break;
      }
  }

  NSZoneFree(NULL, info);
  return pid;
}

// Watches for termination of the process, doing a watch in its kernel event.
// Calls daemonTerminatedFromQueue whenever it happens, as a CFFileDescriptor
// provides just one callback, the call invalidates the current one.
static void kqueue_termination_callback(CFFileDescriptorRef f, CFOptionFlags callBackTypes, void *self) {
  [(id)self performSelector:@selector(daemonTerminatedFromQueue)];
}

// Returns a CFFileDescriptor that is the reference for the callback whenever the status of
// the process has changed.
static inline CFFileDescriptorRef kqueue_watch_pid(pid_t pid, id self) {
  int                     kq;
  struct kevent           changes;
  CFFileDescriptorContext context = {0, self, NULL, NULL, NULL};
  CFRunLoopSourceRef      rls;

  // Create the kqueue and set it up to watch for SIGCHLD. Use the
  // new-in-10.5 EV_RECEIPT flag to ensure that we get what we expect.
  kq = kqueue();

  // Sets the kernel event watcher, to use the process id, and to notify when the
  // process exits.
  EV_SET(&changes, pid, EVFILT_PROC, EV_ADD | EV_RECEIPT, NOTE_EXIT, 0, NULL);
  (void)kevent(kq, &changes, 1, &changes, 1, NULL);

  // Wrap the kqueue in a CFFileDescriptor (new in Mac OS X 10.5!). Then
  // create a run-loop source from the CFFileDescriptor and add that to the
  // runloop.
  CFFileDescriptorRef ref;
  ref = CFFileDescriptorCreate(NULL, kq, true, kqueue_termination_callback, &context);
  rls = CFFileDescriptorCreateRunLoopSource(NULL, ref, 0);
  CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
  CFRelease(rls);

  // Enable the callback, and return the created CFFileDescriptor.
  CFFileDescriptorEnableCallBacks(ref, kCFFileDescriptorReadCallBack);
  return ref;
}

// ## Public properties
//
// There's three properties that are important in order to start, stop, run and monitor
// a daemon.
@implementation FFYDaemonController
// The launchPath is the daemon binary's absolute location.
@synthesize launchPath;
// If the daemon needs any special arguments to be started, this is the array where
// they should be.
@synthesize startArguments;
// If it needs arguments to stop it, they should be in this array.
@synthesize stopArguments;

// ## Private properties
//
// The DaemonController, stores the name of the binary. It is needed in order to get its PID.
@synthesize binaryName;
// If the daemon is not running, the pollTimer will be executed until it starts. Then it will
// be invalidated, and the watch will be switched to the process id observation.
@synthesize pollTimer;
// If we start the daemon, the task is stored in this property.
@synthesize daemonTask;
// When the daemon is started, this timer is used to check when it really starts, assuming it
// will take some time to start up.
@synthesize checkStartupStatusTimer;

// ## Callbacks
//
// In order to notify about the status of the deamon, there are some defined blocks.
// The definition of the blocks is the following:
//     typedef void (^DaemonStarted)(NSNumber *);
//     typedef void (^DaemonStopped)();
//     typedef void (^DaemonIsStarting)();
//     typedef void (^DaemonIsStopping)();
//     typedef void (^DaemonFailedToStart)(NSString *);
//     typedef void (^DaemonFailedToStop)(NSString *);
//
// Whenever the daemon is started this notification is called. The block receives an NSNumber,
// this is the PID of the started daemon.
@synthesize daemonStartedCallback;
// When the daemon is stopped, this callback is called.
@synthesize daemonStoppedCallback;
// When the daemon is going to be started or stopped, these callbacks are called.
@synthesize daemonIsStartingCallback;
@synthesize daemonIsStoppingCallback;
// When the daemon failes to start or stop, these callbacks are called, passing an NSString,
// that contains the reason of the failure.
@synthesize daemonFailedToStartCallback;
@synthesize daemonFailedToStopCallback;

// ## Control Tasks
//
// These are the public methods, that control a daemon.
#pragma mark - Daemon control tasks

// Starts the daemon. Calls to daemonIsStartingCallback, and optionally to
// daemonFailedToStartCallback if it failed to start, or daemonStartedCallback if it
// successfully started.
- (void)start {
  @try {
    // Initialize the daemonTask. Set the launchPath to the one from the properties.
    // If there are any launch arguments, then set them, else set an empty array.
    [self initDaemonTask];
    daemonTask.launchPath = launchPath;
    if (startArguments)
      daemonTask.arguments = startArguments;
    else
      daemonTask.arguments = [NSArray array];

    // Observe the task for its termination.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(daemonTerminated:) name:NSTaskDidTerminateNotification object:daemonTask];
    [daemonTask launch];
    pid = daemonTask.processIdentifier;

    // Continuosly check that the daemon is up and running after a delay of 0.2s.
    self.checkStartupStatusTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkIfDaemonIsRunning) userInfo:nil repeats:true];
  } @catch (NSException *exception) {
    // If there's an exception while trying to initialize the daemon, then
    // notify about the problem.
    [self failedToStartDaemonTask:exception.reason];
  }
}

// Stops the daemon. Calls to daemonIsStoppingCallback if there are arguments to stop the daemon.
// Will call, daemonFailedToStopCallback if it failed to stop the daemon, or
// daemonStoppedCallback if it was sucessfull.
- (void)stop {
  // First if there are stop arguments, then try to stop it.
  if (stopArguments && [self didStopWithArguments]) {
    if (daemonIsStoppingCallback)
      daemonIsStoppingCallback();

    // The kqueue event will tell us eventually when the process exits.
    return;
  }

  // If we have it running, then terminate the task.
  if (daemonTask) {
    [daemonTask terminate];

    if (daemonIsStoppingCallback)
      daemonIsStoppingCallback();
  } else {
    // If not, get the PID from the daemon.
    pid = daemon_pid([binaryName UTF8String]);
    if ((pid = daemon_pid([binaryName UTF8String])) == 0) {
      // The daemon wasn't running, start the polling to check whenever it starts.
      [self startPoll];
      if (daemonStoppedCallback)
        daemonStoppedCallback();
    } else {
      // If it is running, ans is not our task, and we don't have the arguments to stop it.
      // Then kill it, if for some reason it fails, then call the appropiate callback.
      if (kill(pid, SIGTERM) == -1 && errno != ESRCH)
        if (daemonFailedToStopCallback)
          daemonFailedToStopCallback(@"Failed to stop and kill the daemon.");
    }
  }
}

// Returns the process id from the daemon, or 0 if not running.
- (NSNumber *)pid {
  return [NSNumber numberWithInt:pid];
}

// Returns if the daemon is running.
- (BOOL)running {
  return [self.pid boolValue];
}

// ## Internal Daemon Control Tasks
//
// The following are internal methods (a.k.a hidden methods) to keep control of the daemon.
#pragma mark - Internal Daemon Tasks

// Initializes the daemonTask. Also invalidates the pollTimer, since it's useless to keep it
// polling for the PID of the daemon, when we already started it.
- (void)initDaemonTask {
  [pollTimer invalidate];
  self.pollTimer = nil;

  // Calls the daemonIsStartingCallback, if set.
  if (daemonIsStartingCallback)
    daemonIsStartingCallback();

  NSTask *task = [[NSTask alloc] init];
  // Assigsns the daemonTask property.
  self.daemonTask = task;
  [task release];
}

// Called when the daemon was terminated from the kernel event watcher.
- (void)daemonTerminatedFromQueue {
  // Sets the file description reference to nil.
  fdref = nil;
  [self daemonTerminated:nil];
}

// Called when the daemon has terminated.
- (void)daemonTerminated:(NSNotification*)notification {
  // Removes this instance observer from the task termination notification.
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:daemonTask];

  // Invalidate the daemonTask, and the PID.
  self.daemonTask = nil;
  pid = 0;

  // Starts polling if the daemon has been started from outside the controller.
  [self startPoll];
  // Calls the proper callback.
  if (daemonStoppedCallback)
    daemonStoppedCallback();
}

// Called when the daemon failes to start.
- (void)failedToStartDaemonTask:(NSString *)reason {
  // Executes the daemonFailedToStartCallback with the received reason.
  if (daemonFailedToStartCallback)
    daemonFailedToStartCallback(reason);

  // Invalidates the daemonTask.
  self.daemonTask = nil;
}

// Checks if the daemon is running. Called after starting the daemon task, checks whenever
// the daemon is really running.
- (void)checkIfDaemonIsRunning {
  if ((pid = daemon_pid([binaryName UTF8String])) != 0) {
    // Invalidate the timer, since it has been started.
    [checkStartupStatusTimer invalidate];
    self.checkStartupStatusTimer = nil;
    // Called the proper callback, passing the process id as an NSNumber.
    if (daemonStartedCallback)
      daemonStartedCallback(self.pid);
  }
}

// Starts polling to check whenever the daemon is started.
- (void)startPoll {
  // If the pollTimer is already started, invalidate it.
  if (pollTimer)
    [pollTimer invalidate];

  self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(poll:) userInfo:nil repeats:true];
}

// Called from the pollTimer, every 330ms to check for the daemon.
- (void)poll:(NSTimer*)timer {
  // If the daemon is not running, then return.
  if ((pid = daemon_pid([binaryName UTF8String])) == 0)
    return;

  // If the daemonStartedCallback is set, call it passing the process id.
  if (daemonStartedCallback)
    daemonStartedCallback(self.pid);

  // Invalidate the pollTimer, and set the File Description Reference.
  [pollTimer invalidate];
  self.pollTimer = nil;
  fdref = kqueue_watch_pid(pid, self);
}

// Stops the daemon, and return if it was stopped or not.
- (BOOL)didStopWithArguments {
  // Launch a new task, passing the stop arguments.
  NSTask *task = [[[NSTask alloc] init] autorelease];
  task.launchPath = launchPath;
  task.arguments = stopArguments;

  [task launch];
  [task waitUntilExit];

  return task.terminationStatus == 0;
}

// ## Custom Setters and Getters
#pragma mark - Custom Setters and Getters

// When setting the launchPath, means that the deamon to watch has changed. So this custom
// setters does what needed to invalidate timers, and prepare it to watch for another daemon.
- (void)setLaunchPath:(NSString *)theLaunchPath {
  if (launchPath != theLaunchPath) {
    // If the pollTimer is running, invalidate it and set it to nil.
    if (pollTimer) {
      [pollTimer invalidate];
      self.pollTimer = nil;
    }

    // If the timer to check if the daemon has been started up, is running, then invalidate
    // if and set it to nil.
    if (checkStartupStatusTimer) {
      [checkStartupStatusTimer invalidate];
      self.checkStartupStatusTimer = nil;
    }

    // If there is the File Description Reference, then disable the callback.
    if (fdref != NULL)
      CFFileDescriptorDisableCallBacks(fdref, kCFFileDescriptorReadCallBack);

    // Replace the launchPath.
    [launchPath release];
    launchPath = [theLaunchPath retain];
    // And set the binary name to the last path component.
    self.binaryName = [launchPath lastPathComponent];

    // Start polling to check when the daemon starts.
    if (launchPath)
      [self startPoll];
  }
}

// ## Memory Management
#pragma mark - Memory Management

// When the instance is dealloc'ed, it is needed to release the retained properties.
- (void)dealloc {
  // First, if the instance is observing for the task termination, then remove the instance
  // from the notification center.
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  // Release the public properties.
  [startArguments release];
  [stopArguments release];
  [launchPath release];

  // Release the hidden properties.
  [binaryName release];
  [pollTimer release];
  [daemonTask release];

  // Release all the callbacks.
  [daemonStartedCallback release];
  [daemonStoppedCallback release];
  [daemonIsStartingCallback release];
  [daemonFailedToStartCallback release];
  [daemonIsStoppingCallback release];
  [daemonFailedToStopCallback release];

  // Call to super.
  [super dealloc];
}

@end
