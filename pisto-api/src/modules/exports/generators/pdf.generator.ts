import { PDFDocument, StandardFonts, rgb, PageSizes } from '@cantoo/pdf-lib'

interface Column {
  header: string; key: string; width?: number
}

const COLOR_HEADER_BG = rgb(0.102, 0.337, 0.859)  // #1A56DB
const COLOR_ROW_ALT   = rgb(0.953, 0.957, 0.965)  // #F3F4F6
const COLOR_WHITE     = rgb(1, 1, 1)
const COLOR_BLACK     = rgb(0, 0, 0)

const MARGIN        = 40
const ROW_HEIGHT    = 18
const HEADER_HEIGHT = 20
const FONT_SIZE_TITLE = 16
const FONT_SIZE_SUB   = 9
const FONT_SIZE_BODY  = 8

export async function generatePDF(
  title: string,
  columns: Column[],
  rows: Record<string, unknown>[],
): Promise<Uint8Array> {
  const pdfDoc = await PDFDocument.create()

  const fontRegular = await pdfDoc.embedStandardFont(StandardFonts.Helvetica)
  const fontBold    = await pdfDoc.embedStandardFont(StandardFonts.HelveticaBold)

  const [pageWidth, pageHeight] = PageSizes.Letter

  const usableWidth = pageWidth - MARGIN * 2
  const colWidth    = usableWidth / columns.length

  const addPage = () => {
    const page = pdfDoc.addPage([pageWidth, pageHeight])
    return page
  }

  let page     = addPage()

  let topOffset = MARGIN

  const getY = () => pageHeight - topOffset

  const titleWidth = fontBold.widthOfTextAtSize(title, FONT_SIZE_TITLE)
  page.drawText(title, {
    x: MARGIN + (usableWidth - titleWidth) / 2,
    y: getY() - FONT_SIZE_TITLE,
    size: FONT_SIZE_TITLE,
    font: fontBold,
    color: COLOR_BLACK,
  })
  topOffset += FONT_SIZE_TITLE + 6

  const dateStr = `Generado: ${new Date().toLocaleString('es-SV')}`
  const dateWidth = fontRegular.widthOfTextAtSize(dateStr, FONT_SIZE_SUB)
  page.drawText(dateStr, {
    x: MARGIN + usableWidth - dateWidth,
    y: getY() - FONT_SIZE_SUB,
    size: FONT_SIZE_SUB,
    font: fontRegular,
    color: COLOR_BLACK,
  })
  topOffset += FONT_SIZE_SUB + 10

  const drawTableHeader = (p: ReturnType<typeof pdfDoc.getPage>, to: number) => {
    const rowY = pageHeight - to - HEADER_HEIGHT
    p.drawRectangle({
      x: MARGIN,
      y: rowY,
      width: usableWidth,
      height: HEADER_HEIGHT,
      color: COLOR_HEADER_BG,
    })
    columns.forEach((col, i) => {
      p.drawText(col.header, {
        x: MARGIN + i * colWidth + 4,
        y: rowY + 5,
        size: FONT_SIZE_BODY,
        font: fontBold,
        color: COLOR_WHITE,
        maxWidth: colWidth - 8,
      })
    })
    return to + HEADER_HEIGHT + 2
  }

  topOffset = drawTableHeader(page, topOffset)

  for (let r = 0; r < rows.length; r++) {
    if (pageHeight - topOffset - ROW_HEIGHT < 60) {
      page = addPage()
      topOffset = MARGIN
      topOffset = drawTableHeader(page, topOffset)
    }

    const rowY = pageHeight - topOffset - ROW_HEIGHT

    if (r % 2 === 0) {
      page.drawRectangle({
        x: MARGIN,
        y: rowY,
        width: usableWidth,
        height: ROW_HEIGHT,
        color: COLOR_ROW_ALT,
      })
    }

    columns.forEach((col, i) => {
      const val = rows[r]?.[col.key]
      page.drawText(String(val ?? ''), {
        x: MARGIN + i * colWidth + 4,
        y: rowY + 4,
        size: FONT_SIZE_BODY,
        font: fontRegular,
        color: COLOR_BLACK,
        maxWidth: colWidth - 8,
      })
    })

    topOffset += ROW_HEIGHT
  }

  topOffset += 10
  if (pageHeight - topOffset < 20) {
    page = addPage()
    topOffset = MARGIN
  }
  page.drawText(`Total registros: ${rows.length}`, {
    x: MARGIN,
    y: pageHeight - topOffset - FONT_SIZE_BODY,
    size: FONT_SIZE_BODY,
    font: fontRegular,
    color: COLOR_BLACK,
  })

  return pdfDoc.save()
}
