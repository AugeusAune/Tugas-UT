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
  const cleanNim = nim?.trim();
  if (!cleanNim || !/^\d+$/.test(cleanNim)) {
    throw new Error('NIM must be a non-empty numeric string.');
  }

  const height = Number.parseInt(cleanNim.slice(-1), 10);
  if (height <= 0) {
    throw new Error(`The last digit of NIM is '${height}'. Height must be greater than zero.`);
  }

  return Array.from({ length: height }, (_, rowIndex) =>
    Array.from({ length: rowIndex + 1 }, (_, colIndex) => colIndex + 1).join(' ')
  );
};

/**
 * Executes and prints the output for Question 1.
 *
 * @param nim - Student Identification Number
 */
export const runSoal1 = (nim: string): void => {
  try {
    const rows = generateTrianglePattern(nim);
    const height = nim.trim().slice(-1);

    console.log('--- Soal 1: Pola Segitiga dari NIM ---');
    console.log(`NIM            : ${nim}`);
    console.log(`Tinggi Segitiga: ${height}`);
    console.log('Pola:');
    rows.forEach((row) => {
      console.log(row);
      console.log();
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error(`[Soal 1 Error]: ${message}`);
  }
};
