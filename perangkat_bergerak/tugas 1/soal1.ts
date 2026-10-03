/**
 * Soal 1: Pola Segitiga dari NIM
 * Ambil digit terakhir NIM sebagai tinggi segitiga.
 * Buat program TypeScript untuk mencetak segitiga angka.
 */

/**
 * Generates a numeric triangle pattern based on the last digit of NIM.
 *
 * @param nim - Student Identification Number
 * @returns Array of strings representing each line of the triangle
 */
export const generateTrianglePattern = (nim: string): string[] => {
  if (!nim || typeof nim !== 'string') {
    throw new Error('NIM must be a non-empty string.');
  }

  const cleanNim = nim.trim();
  if (!/^\d+$/.test(cleanNim)) {
    throw new Error('NIM must contain only numeric digits.');
  }

  const lastChar = cleanNim.slice(-1);
  const height = Number.parseInt(lastChar, 10);

  if (height <= 0) {
    throw new Error(`The last digit of NIM is '${height}'. Height must be greater than zero.`);
  }

  const rows: string[] = [];
  for (let currentRow = 1; currentRow <= height; currentRow++) {
    const rowNumbers: number[] = [];
    for (let currentNumber = 1; currentNumber <= currentRow; currentNumber++) {
      rowNumbers.push(currentNumber);
    }
    rows.push(rowNumbers.join(' '));
  }

  return rows;
};

/**
 * Executes and prints the output for Question 1.
 *
 * @param nim - Student Identification Number (default: '230411013')
 */
export const runSoal1 = (nim: string = '230411013'): void => {
  try {
    const rows = generateTrianglePattern(nim);
    const height = nim.trim().slice(-1);

    console.log('--- Soal 1: Pola Segitiga dari NIM ---');
    console.log(`NIM            : ${nim}`);
    console.log(`Tinggi Segitiga: ${height}`);
    console.log('Pola:');
    for (const row of rows) {
      console.log(row);
      console.log();
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error(`[Soal 1 Error]: ${message}`);
  }
};
