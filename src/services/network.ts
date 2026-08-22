/**
 * Simulated network layer shared by every mock repository. Swapping these
 * repos for a real API later only means replacing the bodies of the
 * service functions — screens depend on the async signatures alone.
 */
export class NetworkError extends Error {
  constructor() {
    super('network-unavailable');
    this.name = 'NetworkError';
  }
}

export class MatchFullError extends Error {
  constructor() {
    super('match-full');
    this.name = 'MatchFullError';
  }
}

export class PaymentDeclinedError extends Error {
  constructor() {
    super('payment-declined');
    this.name = 'PaymentDeclinedError';
  }
}

let offline = false;

/** Toggle the simulated connection (used to exercise the offline state). */
export function setOffline(value: boolean): void {
  offline = value;
}

export function isOffline(): boolean {
  return offline;
}

/** Resolve after simulated latency, or reject when offline. */
export function simulateRequest<T>(result: T, latencyMs = 450): Promise<T> {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (offline) reject(new NetworkError());
      else resolve(result);
    }, latencyMs);
  });
}
