/**
 * Soal 2: Deret Aritmatika dengan NIM
 * Ambil 2 digit terakhir NIM sebagai angka awal deret.
 * Ambil digit ke-3 dari belakang sebagai beda (step).
 * Cetak 10 angka pertama dari deret aritmatika tersebut.
 */

export interface ArithmeticSeriesResult {
  startNumber: number;
  rawStepDigit: number;
  effectiveStep: number;
  series: number[];
}

/**
 * Generates an arithmetic series based on NIM.
 *
 * @param nim - Student Identification Number
 * @param totalTerms - Number of terms to generate (default: 10)
 * @returns ArithmeticSeriesResult containing calculated values and sequence
 */
export const generateArithmeticSeries = (
  nim: string,
  totalTerms = 10
): ArithmeticSeriesResult => {
  const cleanNim = nim?.trim();
  if (!cleanNim || !/^\d+$/.test(cleanNim)) {
    throw new Error('NIM must be a non-empty numeric string.');
  }

  if (cleanNim.length < 3) {
    throw new Error('NIM must be at least 3 digits long to extract start and step.');
  }

  if (totalTerms <= 0) {
    throw new Error('Total terms must be a positive integer.');
  }

  const startNumber = Number.parseInt(cleanNim.slice(-2), 10);
  const rawStepDigit = Number.parseInt(cleanNim.charAt(cleanNim.length - 3), 10);
  const effectiveStep = rawStepDigit === 0 ? 1 : rawStepDigit;

  const series = Array.from(
    { length: totalTerms },
    (_, index) => startNumber + index * effectiveStep
  );

  return { startNumber, rawStepDigit, effectiveStep, series };
};

/**
 * Executes and prints the output for Question 2.
 *
 * @param nim - Student Identification Number (default: '230411013')
 * @param totalTerms - Number of terms to generate (default: 10)
 */
export const runSoal2 = (nim = '230411013', totalTerms = 10): void => {
  try {
    const result = generateArithmeticSeries(nim, totalTerms);

    console.log('--- Soal 2: Deret Aritmatika dengan NIM ---');
    console.log(`NIM                      : ${nim}`);
    console.log(`Angka Awal (2 digit akhir): ${result.startNumber}`);
    console.log(`Digit ke-3 dari belakang : ${result.rawStepDigit}`);
    console.log(`Beda (Step) Digunakan    : ${result.effectiveStep}`);
    console.log(`Output: ${result.series.join(', ')}`);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error(`[Soal 2 Error]: ${message}`);
  }
};
