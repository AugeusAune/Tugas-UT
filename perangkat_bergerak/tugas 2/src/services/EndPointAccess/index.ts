import axios, { type AxiosResponse } from 'axios';

/**
 * Service to handle RESTful API endpoint access using Axios.
 */
export default class EndPointAccess {
  theUrl: string;

  /**
   * Initializes the endpoint access with the given URL.
   * @param url - RESTful API endpoint URL
   */
  constructor(url: string) {
    const trimmedUrl = url?.trim();
    if (!trimmedUrl) {
      throw new Error('Endpoint URL cannot be empty.');
    }
    this.theUrl = trimmedUrl;
  }

  /**
   * Performs an asynchronous GET request to the configured URL.
   * @returns Promise resolving to the Axios response
   */
  async getRes<T = unknown>(): Promise<AxiosResponse<T>> {
    try {
      const response = await axios.get<T>(this.theUrl);
      return response;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown network error';
      throw new Error(`Failed to fetch data from ${this.theUrl}: ${errorMessage}`);
    }
  }
}
