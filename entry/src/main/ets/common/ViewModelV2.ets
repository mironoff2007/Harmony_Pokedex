import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { ContentViewState, FailureViewState, ViewState, ViewStateGeneric } from "./State";

@ObservedV2
export abstract class ViewModelV2<T> {
  constructor() {

  }

  @Trace
  state: ViewStateGeneric<T> = ViewState.loading;

  getContentState(): T | null {
    if (ViewState.isContent(this.state)) {
      const contentState = this.state as ContentViewState<T>
      return contentState.value
    } else {
      return null
    }
  }

  getErrorState(): Error | null {
    if (ViewState.isFailure(this.state)) {
      const contentState = this.state as FailureViewState
      return contentState.error
    } else {
      return null
    }
  }

  delayTime: number = 5000; // Remaining duration for the suspension delay request.

  // Request a suspension delay.
  private requestSuspendDelay(): number {
    const myReason = 'requestSuspendDelay'; // Reason for the suspension delay request.
    let id: number = this.delayTime
    try {
      const delayInfo = backgroundTaskManager.requestSuspendDelay(myReason, () => {
        // The callback is invoked to notify the application that the suspension delay request is about to time out. The application needs to perform some cleanup and annotation operations and cancels the transient task.
        console.info("[backgroundTaskManager] Request suspension delay will time out.");
        backgroundTaskManager.cancelSuspendDelay(id);
      })
      id = delayInfo.requestId;
      this.delayTime = delayInfo.actualDelayTime;
      console.info("[backgroundTaskManager] The requestId is: " + id);
      console.info("[backgroundTaskManager]The actualDelayTime is: " + this.delayTime);
    } catch (error) {
      console.error(`[backgroundTaskManager] requestSuspendDelay failed. code is ${error.code} message is ${error.message}`);
    }
    return id
  }

  // Obtain the remaining duration before the application is suspended.
  private async getRemainingDelayTime(id: number): Promise<number> {
     try {
      return await backgroundTaskManager.getRemainingDelayTime(id)
    } catch (error) {
      console.error(`[backgroundTaskManager] promise => Operation getRemainingDelayTime failed. code is ${error.code} message is ${error.message}`);
      return 0
    }
  }

  // Cancel the suspension delay.
  private cancelSuspendDelay(id: number) {
    backgroundTaskManager.cancelSuspendDelay(id);
  }


  backgroundTask(task: Promise<void>): Promise<void> {
    return new Promise<void>(async (resolve, reject) => {
      try {
        const id: number = this.requestSuspendDelay();
        const remainingTime: number = await this.getRemainingDelayTime(id);

        if (remainingTime < 0) {
          this.cancelSuspendDelay(id);
          reject(new Error("Insufficient delay time"));
          return;
        }

        await task;
        this.cancelSuspendDelay(id);
        resolve();
      } catch (error) {
        reject(error);
      }
    });
  }

}