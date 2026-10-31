import axios from 'axios';
import type { CoinloreResponse, CryptoTicker } from '@/types/crypto';

const COINLORE_API_URL = 'https://api.coinlore.net/api/tickers/';

/**
 * Fetch cryptocurrency tickers from Coinlore API.
 * Returns an array of CryptoTicker items sorted by rank.
 */
export async function getCryptoTickers(start = 0, limit = 100): Promise<CryptoTicker[]> {
  try {
    const response = await axios.get<CoinloreResponse>(COINLORE_API_URL, {
      params: { start, limit },
      timeout: 10000,
    });

    if (!response.data || !Array.isArray(response.data.data)) {
      throw new Error('Format data API tidak valid');
    }

    return response.data.data;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const message = error.response
        ? `Gagal mengambil data crypto: Status ${error.response.status}`
        : error.message || 'Koneksi ke API terputus';
      throw new Error(message);
    }
    throw error;
  }
}
