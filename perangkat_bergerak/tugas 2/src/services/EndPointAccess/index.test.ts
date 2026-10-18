import { describe, expect, it } from 'bun:test';
import EndPointAccess from './index';

describe('EndPointAccess Service', () => {
  it('throws an error if URL is empty', () => {
    expect(() => new EndPointAccess('')).toThrow('Endpoint URL cannot be empty.');
  });

  it('fetches weather data successfully from Open-Meteo', async () => {
    const url =
      'https://api.open-meteo.com/v1/forecast?latitude=-6.2&longitude=106.8&hourly=temperature_2m';
    const service = new EndPointAccess(url);
    const response = await service.getRes<{
      hourly: { time: string[]; temperature_2m: number[] };
      hourly_units: { time: string; temperature_2m: string };
    }>();

    expect(response.status).toBe(200);
    expect(response.data).toBeDefined();
    expect(response.data.hourly).toBeDefined();
    expect(response.data.hourly.time.length).toBeGreaterThan(0);
    expect(response.data.hourly.temperature_2m.length).toBeGreaterThan(0);
    expect(response.data.hourly.time.length).toBe(
      response.data.hourly.temperature_2m.length,
    );
  });
});
