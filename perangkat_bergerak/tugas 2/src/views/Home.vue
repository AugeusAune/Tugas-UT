<template>
  <ion-page>
    <ion-header :translucent="true">
      <ion-toolbar color="primary">
        <ion-title>Prakiraan Cuaca Jakarta</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content :fullscreen="true" class="ion-padding page-content">
      <div id="container">
        <!-- Header Info -->
        <header class="app-header">
          <h2>Prakiraan Suhu Cuaca Jakarta (Open-Meteo)</h2>
          <p class="subtitle">
            Koordinat: Lat -6.2, Long 106.8 &bull; Klik pada baris hari untuk melihat detail suhu per jam
          </p>
        </header>

        <!-- Action Button -->
        <div class="action-section">
          <ion-button @click="ambilData" :disabled="isLoading">
            {{ isLoading ? 'Mengambil Data...' : 'Ambil Data Cuaca' }}
          </ion-button>
        </div>

        <!-- Loading State -->
        <div v-if="isLoading" class="loading-state">
          <ion-spinner name="crescent"></ion-spinner>
          <p>Sedang mengambil data cuaca dari Open-Meteo API...</p>
        </div>

        <!-- Error State -->
        <div v-if="errorMessage" class="error-state">
          <p class="error-text">{{ errorMessage }}</p>
        </div>

        <!-- Days Table List -->
        <section v-if="daysList.length > 0" class="results-section">
          <div class="table-wrapper">
            <table class="days-table">
              <thead>
                <tr>
                  <th scope="col">No</th>
                  <th scope="col">Hari &amp; Tanggal</th>
                  <th scope="col">Suhu Min</th>
                  <th scope="col">Suhu Max</th>
                  <th scope="col">Rata-rata</th>
                  <th scope="col">Aksi</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(day, index) in daysList"
                  :key="day.dateKey"
                  class="day-row"
                  @click="openDayDetail(day)"
                >
                  <td class="col-num">{{ index + 1 }}</td>
                  <td class="day-info">
                    <span class="day-title">{{ day.dayLabel }}</span>
                    <span class="date-badge">{{ day.dateKey }}</span>
                  </td>
                  <td class="temp-val temp-min">{{ day.minTemp }} {{ tempUnit }}</td>
                  <td class="temp-val temp-max">{{ day.maxTemp }} {{ tempUnit }}</td>
                  <td class="temp-val temp-avg">{{ day.avgTemp }} {{ tempUnit }}</td>
                  <td class="action-cell">
                    <ion-button
                      size="small"
                      fill="outline"
                      @click.stop="openDayDetail(day)"
                    >
                      Lihat Jam
                    </ion-button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>

      <!-- Modal Dialog: Hourly Detail -->
      <ion-modal :is-open="isModalOpen" @didDismiss="closeModal">
        <ion-header>
          <ion-toolbar color="primary">
            <ion-title>Detail Suhu Cuaca Per Jam</ion-title>
            <ion-buttons slot="end">
              <ion-button @click="closeModal">Tutup</ion-button>
            </ion-buttons>
          </ion-toolbar>
        </ion-header>

        <ion-content class="ion-padding modal-content">
          <div v-if="selectedDay" class="modal-body">
            <div class="day-summary-card">
              <h3>{{ selectedDay.dayLabel }}</h3>
              <p class="date-caption">{{ selectedDay.dateKey }}</p>
              <div class="stat-pills">
                <span class="stat-pill">Min: <strong>{{ selectedDay.minTemp }} {{ tempUnit }}</strong></span>
                <span class="stat-pill">Max: <strong>{{ selectedDay.maxTemp }} {{ tempUnit }}</strong></span>
                <span class="stat-pill">Rata-rata: <strong>{{ selectedDay.avgTemp }} {{ tempUnit }}</strong></span>
              </div>
            </div>

            <div class="table-wrapper">
              <table class="hourly-table">
                <thead>
                  <tr>
                    <th scope="col">No</th>
                    <th scope="col">Time (Waktu Pengukuran)</th>
                    <th scope="col">Temperature_2m (Suhu per Jam)</th>
                    <th scope="col">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(hourItem, idx) in selectedDay.hours" :key="hourItem.time">
                    <td class="col-num">{{ idx + 1 }}</td>
                    <td class="time-col">
                      <span class="time-clock">{{ hourItem.hour }}</span>
                      <span class="time-raw">{{ hourItem.time }}</span>
                    </td>
                    <td class="temp-col">
                      <strong>{{ hourItem.temperature }} {{ tempUnit }}</strong>
                    </td>
                    <td>
                      <span :class="['badge-status', getTempBadgeClass(hourItem.temperature)]">
                        {{ getTempBadgeLabel(hourItem.temperature) }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </ion-content>
      </ion-modal>
    </ion-content>
  </ion-page>
</template>

<script lang="ts">
import {
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar,
  IonButton,
  IonButtons,
  IonModal,
  IonSpinner,
} from '@ionic/vue';
import { defineComponent } from 'vue';
import EndPointAccess from '@/services/EndPointAccess';

interface OpenMeteoResponse {
  latitude: number;
  longitude: number;
  hourly_units: {
    time: string;
    temperature_2m: string;
  };
  hourly: {
    time: string[];
    temperature_2m: number[];
  };
}

export interface WeatherItem {
  time: string;
  hour: string;
  temperature: number;
}

export interface DaySummary {
  dateKey: string;
  dayLabel: string;
  minTemp: number;
  maxTemp: number;
  avgTemp: number;
  hours: WeatherItem[];
}

const WEATHER_API_URL =
  'https://api.open-meteo.com/v1/forecast?latitude=-6.2&longitude=106.8&hourly=temperature_2m';

const formatDayLabel = (dateStr: string): string => {
  try {
    const date = new Date(`${dateStr}T00:00:00`);
    return date.toLocaleDateString('id-ID', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
  } catch {
    return dateStr;
  }
};

const groupHourlyByDay = (
  times: string[],
  temps: number[],
): DaySummary[] => {
  const dayMap = new Map<string, WeatherItem[]>();

  times.forEach((timeStr, index) => {
    const parts = timeStr.split('T');
    const dateKey = parts[0];
    const hourPart = parts[1] || timeStr;

    const item: WeatherItem = {
      time: timeStr,
      hour: hourPart,
      temperature: temps[index],
    };

    if (!dayMap.has(dateKey)) {
      dayMap.set(dateKey, []);
    }
    dayMap.get(dateKey)!.push(item);
  });

  return Array.from(dayMap.entries()).map(([dateKey, items]) => {
    const tempValues = items.map((i) => i.temperature);
    const minTemp = Math.min(...tempValues);
    const maxTemp = Math.max(...tempValues);
    const avgTemp = Number(
      (tempValues.reduce((sum, v) => sum + v, 0) / tempValues.length).toFixed(1),
    );

    return {
      dateKey,
      dayLabel: formatDayLabel(dateKey),
      minTemp,
      maxTemp,
      avgTemp,
      hours: items,
    };
  });
};

export default defineComponent({
  name: 'Home',
  components: {
    IonContent,
    IonHeader,
    IonPage,
    IonTitle,
    IonToolbar,
    IonButton,
    IonButtons,
    IonModal,
    IonSpinner,
  },
  data() {
    return {
      daysList: [] as DaySummary[],
      selectedDay: null as DaySummary | null,
      isModalOpen: false,
      tempUnit: '°C',
      isLoading: false,
      errorMessage: '',
    };
  },
  methods: {
    async ambilData(): Promise<void> {
      this.isLoading = true;
      this.errorMessage = '';

      try {
        const endpointService = new EndPointAccess(WEATHER_API_URL);
        const response = await endpointService.getRes<OpenMeteoResponse>();
        const { hourly, hourly_units } = response.data;

        if (!hourly || !Array.isArray(hourly.time) || !Array.isArray(hourly.temperature_2m)) {
          throw new Error('Format data cuaca hourly tidak sesuai dari server.');
        }

        this.tempUnit = hourly_units?.temperature_2m || '°C';
        this.daysList = groupHourlyByDay(hourly.time, hourly.temperature_2m);
      } catch (error) {
        const message =
          error instanceof Error ? error.message : 'Terjadi kesalahan tidak dikenal.';
        this.errorMessage = `Gagal memuat data cuaca: ${message}`;
      } finally {
        this.isLoading = false;
      }
    },

    openDayDetail(day: DaySummary): void {
      this.selectedDay = day;
      this.isModalOpen = true;
    },

    closeModal(): void {
      this.isModalOpen = false;
    },

    getTempBadgeClass(temp: number): string {
      if (temp >= 32) return 'badge-hot';
      if (temp >= 27) return 'badge-warm';
      return 'badge-cool';
    },

    getTempBadgeLabel(temp: number): string {
      if (temp >= 32) return 'Panas';
      if (temp >= 27) return 'Hangat';
      return 'Sejuk';
    },
  },
});
</script>

<style scoped>
.page-content {
  --background: #f8fafc;
}

#container {
  max-width: 900px;
  margin: 0 auto;
  padding: 16px 8px;
}

.app-header {
  text-align: center;
  margin-bottom: 20px;
}

.app-header h2 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #0f172a;
  margin-bottom: 6px;
}

.subtitle {
  font-size: 0.95rem;
  color: #475569;
  margin: 0;
  line-height: 1.4;
}

.action-section {
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  margin: 32px 0;
  color: #334155;
  font-weight: 500;
}

.error-state {
  background-color: #fee2e2;
  border: 1px solid #ef4444;
  border-radius: 8px;
  padding: 14px;
  margin: 16px auto;
  max-width: 600px;
}

.error-text {
  color: #b91c1c;
  margin: 0;
  font-size: 0.95rem;
  text-align: center;
}

/* Table styling */
.table-wrapper {
  overflow-x: auto;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  border: 1px solid #e2e8f0;
  background-color: #ffffff;
}

.days-table,
.hourly-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.95rem;
}

.days-table th,
.days-table td,
.hourly-table th,
.hourly-table td {
  padding: 12px 14px;
  text-align: center;
  border-bottom: 1px solid #f1f5f9;
}

.days-table th,
.hourly-table th {
  background-color: #f1f5f9;
  color: #1e293b;
  font-weight: 600;
  letter-spacing: 0.02em;
}

.day-row {
  cursor: pointer;
  transition: background-color 0.15s ease-in-out;
}

.day-row:hover {
  background-color: #f0f9ff;
}

.col-num {
  font-weight: 600;
  color: #64748b;
  width: 48px;
}

.day-info {
  text-align: left;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.day-title {
  font-weight: 600;
  color: #0f172a;
}

.date-badge {
  font-size: 0.8rem;
  color: #64748b;
}

.temp-val {
  font-weight: 600;
}

.temp-min {
  color: #0284c7;
}

.temp-max {
  color: #e11d48;
}

.temp-avg {
  color: #0d9488;
}

.action-cell {
  width: 110px;
}

/* Modal styling */
.modal-body {
  max-width: 800px;
  margin: 0 auto;
}

.day-summary-card {
  background-color: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  text-align: center;
}

.day-summary-card h3 {
  margin: 0 0 4px;
  color: #0f172a;
  font-size: 1.25rem;
}

.date-caption {
  margin: 0 0 12px;
  color: #64748b;
  font-size: 0.9rem;
}

.stat-pills {
  display: flex;
  justify-content: center;
  gap: 12px;
  flex-wrap: wrap;
}

.stat-pill {
  background-color: #ffffff;
  border: 1px solid #cbd5e1;
  border-radius: 20px;
  padding: 4px 14px;
  font-size: 0.85rem;
  color: #334155;
}

.time-col {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}

.time-clock {
  font-weight: 600;
  color: #0f172a;
}

.time-raw {
  font-size: 0.75rem;
  color: #94a3b8;
}

.temp-col {
  color: #0284c7;
  font-size: 1rem;
}

.badge-status {
  display: inline-block;
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
}

.badge-cool {
  background-color: #e0f2fe;
  color: #0369a1;
}

.badge-warm {
  background-color: #fef3c7;
  color: #b45309;
}

.badge-hot {
  background-color: #fee2e2;
  color: #b91c1c;
}
</style>
