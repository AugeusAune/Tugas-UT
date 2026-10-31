<template>
  <ion-page>
    <ion-header :translucent="true">
      <ion-toolbar>
        <div class="header-action-container">
          <ion-button
            class="refresh-btn"
            color="primary"
            :disabled="isLoading"
            @click="loadData"
          >
            <ion-spinner v-if="isLoading" name="crescent" slot="start" />
            Refresh
          </ion-button>
        </div>
      </ion-toolbar>
    </ion-header>

    <ion-content :fullscreen="true" class="page-content">
      <ion-refresher slot="fixed" @ionRefresh="handleRefresh($event)">
        <ion-refresher-content />
      </ion-refresher>

      <div class="content-wrapper">
        <!-- Error State -->
        <div v-if="errorMessage" class="error-banner">
          <p>{{ errorMessage }}</p>
          <ion-button fill="outline" size="small" color="danger" @click="loadData">
            Coba Lagi
          </ion-button>
        </div>

        <!-- Loading Indicator -->
        <div v-if="isLoading && tickers.length === 0" class="loading-container">
          <ion-spinner name="crescent" color="primary" />
          <p>Memuat data cryptocurrency...</p>
        </div>

        <!-- Crypto Table / List -->
        <div v-else-if="tickers.length > 0" class="crypto-table">
          <div
            v-for="item in tickers"
            :key="item.id"
            class="crypto-row"
          >
            <!-- Column 1: Rank -->
            <div class="col col-rank">
              <span class="label">Rank</span>
              <span class="value rank-val">{{ item.rank }}</span>
            </div>

            <!-- Column 2: Name & Symbol -->
            <div class="col col-crypto">
              <span class="label name-val">{{ item.name }}</span>
              <span class="value symbol-val">{{ item.symbol }}</span>
            </div>

            <!-- Column 3: Price in USD -->
            <div class="col col-price">
              <span class="label">USD</span>
              <span class="value price-val">{{ formatPrice(item.price_usd) }}</span>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div v-else-if="!isLoading" class="empty-state">
          <p>Tidak ada data cryptocurrency.</p>
        </div>
      </div>
    </ion-content>
  </ion-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import {
  IonPage,
  IonHeader,
  IonToolbar,
  IonContent,
  IonButton,
  IonSpinner,
  IonRefresher,
  IonRefresherContent,
  type RefresherCustomEvent,
} from '@ionic/vue';
import { getCryptoTickers } from '@/services/cryptoService';
import type { CryptoTicker } from '@/types/crypto';

const tickers = ref<CryptoTicker[]>([]);
const isLoading = ref<boolean>(false);
const errorMessage = ref<string>('');

/**
 * Format price string to maintain readable decimal precision
 */
const formatPrice = (priceStr: string): string => {
  if (!priceStr) return '0.00';
  const num = parseFloat(priceStr);
  if (isNaN(num)) return priceStr;
  
  // Display numbers cleanly
  if (num >= 1) {
    return num.toLocaleString('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }
  return num.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 6,
  });
};

/**
 * Load cryptocurrency data from API
 */
const loadData = async (): Promise<void> => {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    const data = await getCryptoTickers();
    tickers.value = data;
  } catch (err) {
    errorMessage.value = err instanceof Error ? err.message : 'Terjadi kesalahan sistem';
  } finally {
    isLoading.value = false;
  }
};

/**
 * Handle pull to refresh gesture
 */
const handleRefresh = async (event: RefresherCustomEvent): Promise<void> => {
  await loadData();
  event.target.complete();
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.header-action-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 8px 16px;
}

.refresh-btn {
  --background: #2563eb;
  --background-hover: #1d4ed8;
  --border-radius: 8px;
  font-weight: 600;
  text-transform: none;
  min-width: 130px;
  height: 40px;
  margin: 0;
}

.page-content {
  --background: #f1f5f9;
}

.content-wrapper {
  max-width: 500px;
  margin: 0 auto;
  padding: 12px 14px 32px;
}

/* Crypto Table / Card Stack */
.crypto-table {
  background-color: #fffbe6;
  border: 1px solid #e7dfb5;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.crypto-row {
  display: flex;
  align-items: stretch;
  border-bottom: 1px solid #ece4bc;
  transition: background-color 0.15s ease;
}

.crypto-row:last-child {
  border-bottom: none;
}

.crypto-row:hover {
  background-color: #fcf6d6;
}

/* Columns */
.col {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 10px 8px;
  border-right: 1px solid #ece4bc;
}

.col:last-child {
  border-right: none;
}

.label {
  font-size: 0.72rem;
  color: #374151;
  font-weight: 500;
  margin-bottom: 3px;
  line-height: 1.1;
}

.value {
  color: #111827;
  line-height: 1.2;
}

/* Specific column styling */
.col-rank {
  flex: 0 0 55px;
  text-align: center;
}

.rank-val {
  font-size: 1.25rem;
  font-weight: 700;
}

.col-crypto {
  flex: 1 1 auto;
  text-align: center;
  padding-left: 12px;
  padding-right: 12px;
  min-width: 0;
}

.name-val {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 0.76rem;
}

.symbol-val {
  font-size: 1.2rem;
  font-weight: 800;
  letter-spacing: 0.5px;
}

.col-price {
  flex: 0 0 135px;
  text-align: center;
  padding-left: 8px;
  padding-right: 8px;
}

.price-val {
  font-size: 1.05rem;
  font-weight: 700;
  white-space: nowrap;
}

/* Feedback states */
.loading-container,
.empty-state {
  text-align: center;
  padding: 48px 16px;
  color: #64748b;
  font-size: 0.95rem;
}

.error-banner {
  background: #fee2e2;
  border: 1px solid #fca5a5;
  border-radius: 8px;
  padding: 14px 16px;
  margin-bottom: 16px;
  text-align: center;
  color: #991b1b;
}

.error-banner p {
  margin: 0 0 8px;
  font-weight: 500;
}
</style>
