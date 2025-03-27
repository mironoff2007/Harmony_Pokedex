// Define the base types for ViewState
export interface InitialViewState {
  _tag: 'Initial';
}

export interface LoadingViewState {
  _tag: 'Loading';
}

export interface ContentViewState<T> {
  _tag: 'Content';
  value: T;
}

export interface FailureViewState {
  _tag: 'Failure';
  error: Error;
}

// Union type for ViewState
export type ViewStateGeneric<T> = InitialViewState | LoadingViewState | ContentViewState<T> | FailureViewState;

export interface ViewStateFactoryType {
  initial: InitialViewState;
  loading: LoadingViewState;
  empty: () => ContentViewState<void>;
  content: <T>(value: T) => ContentViewState<T>;
  failure: (error: Error) => FailureViewState;
  isInitial: <T>(view: ViewStateGeneric<T>) => boolean;
  isLoading: <T>(view: ViewStateGeneric<T>) => boolean;
  isContent: <T>(view: ViewStateGeneric<T>) => boolean;
  isFailure: <T>(view: ViewStateGeneric<T>) => boolean;
}

// Implement the ViewState object
export const ViewState: ViewStateFactoryType = {
  initial: { _tag: 'Initial' } as InitialViewState,
  loading: { _tag: 'Loading' } as LoadingViewState,
  empty: (): ContentViewState<void> => ({ _tag: 'Content', value: undefined }),
  content: <T>(value: T): ContentViewState<T> => ({ _tag: 'Content', value }),
  failure: (error: Error): FailureViewState => ({ _tag: 'Failure', error }),

  // Type guards for ViewState
  isInitial: <T>(view: ViewStateGeneric<T>): boolean => view._tag === 'Initial',
  isLoading: <T>(view: ViewStateGeneric<T>): boolean => view._tag === 'Loading',
  isContent: <T>(view: ViewStateGeneric<T>): boolean => view._tag === 'Content',
  isFailure: <T>(view: ViewStateGeneric<T>): boolean => view._tag === 'Failure',
};