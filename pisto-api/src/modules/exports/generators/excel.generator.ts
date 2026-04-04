import { type ExcelColumnMetadata, Workbook, createExcelFile } from 'excel-builder-vanilla'

interface Column {
  header: string; key: string; width?: number
}

export async function generateExcel(
  title: string,
  columns: Column[],
  rows: Record<string, unknown>[],
): Promise<Buffer> {
  const workbook = new Workbook()
  const sheet = workbook.createWorksheet({ name: title })

  const stylesheet = workbook.getStyleSheet()

  // Header style: bold white text on blue background, centered
  const headerFormat = stylesheet.createFormat({
    font: { bold: true, color: 'FFFFFFFF' },
    fill: { type: 'pattern', patternType: 'solid', fgColor: 'FF1A56DB' },
    alignment: { horizontal: 'center' },
  })

  // Alternate row fill: light gray
  const altRowFormat = stylesheet.createFormat({
    fill: { type: 'pattern', patternType: 'solid', fgColor: 'FFF3F4F6' },
  })

  // Build header row with styling
  const headerRow: ExcelColumnMetadata[] = columns.map(col => ({
    value: col.header,
    metadata: { style: headerFormat.id },
  }))

  // Build data rows, applying alternate row background on even rows (0-indexed row 1, 3, 5…)
  const dataRows: (string | number | boolean | Date | ExcelColumnMetadata | null)[][] = rows.map((row, rowIndex) => {
    const isAlt = rowIndex % 2 === 0 // rows[0] is visual row 2 (even)
    return columns.map(col => {
      const raw = row[col.key] ?? ''
      const value = (
        raw === null || typeof raw === 'string' || typeof raw === 'number' ||
        typeof raw === 'boolean' || raw instanceof Date
          ? raw as string | number | boolean | Date | null
          : String(raw)
      )
      return isAlt
        ? ({ value, metadata: { style: altRowFormat.id } } as ExcelColumnMetadata)
        : value
    })
  })

  sheet.setData([headerRow, ...dataRows])

  // Set column widths using setColumns with ExcelColumn objects
  sheet.setColumns(columns.map(col => ({ width: col.width ?? 15 })))

  workbook.addWorksheet(sheet)

  const uint8 = await createExcelFile(workbook, 'Uint8Array')
  return Buffer.from(uint8)
}
