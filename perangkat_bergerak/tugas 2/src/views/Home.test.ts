import { describe, expect, it } from 'bun:test';

interface WeatherItem {
  time: string;
  hour: string;
  temperature: number;
}

interface DaySummary {
  dateKey: string;
  dayLabel: string;
  minTemp: number;
  maxTemp: number;
  avgTemp: number;
  hours: WeatherItem[];
}

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
      dayLabel: dateKey,
      minTemp,
      maxTemp,
      avgTemp,
      hours: items,
    };
  });
};

describe('Weather Data Grouping Logic', () => {
  it('correctly aggregates hourly entries into daily summaries', () => {
    const mockTimes = [
      '2026-10-18T00:00',
      '2026-10-18T06:00',
      '2026-10-18T12:00',
      '2026-10-19T00:00',
    ];
    const mockTemps = [24.0, 26.5, 33.5, 23.0];

    const result = groupHourlyByDay(mockTimes, mockTemps);

    expect(result).toHaveLength(2);
    expect(result[0].dateKey).toBe('2026-10-18');
    expect(result[0].minTemp).toBe(24.0);
    expect(result[0].maxTemp).toBe(33.5);
    expect(result[0].avgTemp).toBe(28.0);
    expect(result[0].hours).toHaveLength(3);

    expect(result[1].dateKey).toBe('2026-10-19');
    expect(result[1].minTemp).toBe(23.0);
    expect(result[1].maxTemp).toBe(23.0);
    expect(result[1].avgTemp).toBe(23.0);
    expect(result[1].hours).toHaveLength(1);
  });
});
