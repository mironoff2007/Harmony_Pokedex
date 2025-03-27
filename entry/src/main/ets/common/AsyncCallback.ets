export abstract class AsyncCallback<T, E = void> {
  parent: object

  abstract onCallback(err: BusinessError<E> | null, data: T | null): void;

  constructor(parent: object) {
    this.parent = parent
  }
}


export class BusinessError<T = void> extends Error {
  /**
   * Defines the basic error code.
   * @since 6
   */
  code: number | null;

  /**
   * Defines the additional information for business.
   * @type { ?T }
   * @since 9
   */

  constructor(code: number | null, message: string, data?: T) {
    super(message);
    this.code = code;
  }
}