import { format } from 'fast-csv'

interface Column {
  header: string; key: string
}

export async function generateCSV(
  columns: Column[],
  rows: Record<string, unknown>[],
): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunks: string[] = []
    const stream = format({ headers: true })

    stream.on('data', (chunk: Buffer) => chunks.push(chunk.toString()))
    stream.on('end', () => resolve(chunks.join('')))
    stream.on('error', reject)

    for (const row of rows) {
      const mapped: Record<string, unknown> = {}
      for (const col of columns) {
        mapped[col.header] = row[col.key]
      }
      stream.write(mapped)
    }
    stream.end()
  })
}
