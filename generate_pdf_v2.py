#!/usr/bin/env python3
"""
Blood Donation App - Key Screens & Logic PDF (compact edition)
Only includes main screens and core logic. Strips comments & blank lines.
"""

import os
from datetime import datetime

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak,
    Table, TableStyle, HRFlowable,
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER
from reportlab.lib import colors
from reportlab.lib.colors import HexColor
from reportlab.pdfgen import canvas

# ── Palette ────────────────────────────────────────────────────────────────────
RED_DARK   = HexColor("#C0392B")
RED_MID    = HexColor("#E74C3C")
RED_LIGHT  = HexColor("#FADBD8")
GREY_DARK  = HexColor("#2C3E50")
GREY_MID   = HexColor("#7F8C8D")
GREY_LIGHT = HexColor("#ECF0F1")
BG_CODE    = HexColor("#F8F9FA")
BORDER     = HexColor("#BDC3C7")
WHITE      = colors.white

# ── Config ─────────────────────────────────────────────────────────────────────
BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
OUT_PDF   = os.path.join(BASE_DIR, "blood_donate_code.pdf")
APP_TITLE = "Blood Donation App"
SUBTITLE  = "Key Screens & Core Logic"
AUTHOR    = "Project Documentation"
DATE      = datetime.now().strftime("%B %d, %Y")

# Files to include — main logic + main user screens only
INCLUDE_FILES = [
    "lib/main.dart",
    "lib/core/router/app_router.dart",
    "lib/core/theme/app_theme.dart",
    "lib/features/auth/data/auth_service.dart",
    "lib/features/auth/presentation/screens/login_screen.dart",
    "lib/features/auth/presentation/screens/register_screen.dart",
    "lib/features/auth/presentation/screens/role_selection_screen.dart",
    "lib/features/dashboard/presentation/admin/screens/admin_dashboard_screen.dart",
    "lib/features/dashboard/presentation/donor/screens/donor_dashboard_screen.dart",
    "lib/features/dashboard/presentation/receiver/screens/receiver_dashboard_screen.dart",
    "lib/features/blood_requests/presentation/screens/blood_requests_screen.dart",
    "lib/features/blood_requests/presentation/screens/blood_request_detail_screen.dart",
    "lib/features/blood_requests/presentation/screens/post_blood_request_screen.dart",
    "lib/features/profile/presentation/screens/profile_screen.dart",
    "lib/features/notifications/presentation/screens/notifications_screen.dart",
    "lib/rbac/rbac_service.dart",
    "lib/shared/services/user_model.dart",
]


# ── Helpers ────────────────────────────────────────────────────────────────────
def collect_files():
    result = []
    for rel in INCLUDE_FILES:
        full = os.path.join(BASE_DIR, rel.replace("/", os.sep))
        if os.path.exists(full):
            result.append((rel, full))
        else:
            print(f"  [SKIP] {rel}")
    return result


def strip_code(text: str) -> str:
    """Drop blank lines and full-line // comments."""
    out = []
    for line in text.splitlines():
        s = line.strip()
        if s == "" or s.startswith("//"):
            continue
        out.append(line)
    return "\n".join(out)


def section_label(path: str) -> str:
    parts = path.replace("lib/", "").split("/")
    return parts[0].replace("_", " ").title() if len(parts) > 1 else "Root"


def esc(t: str) -> str:
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def code_paragraphs(content: str, style, chunk=110):
    lines, wrapped = content.splitlines(), []
    for line in lines:
        while len(line) > chunk:
            wrapped.append(line[:chunk])
            line = "    " + line[chunk:]
        wrapped.append(line)
    paragraphs = []
    for i in range(0, len(wrapped), 60):
        block = wrapped[i:i + 60]
        text = "<br/>".join(esc(l) for l in block)
        paragraphs.append(Paragraph(text, style))
    return paragraphs


# ── Page numbering ─────────────────────────────────────────────────────────────
class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        total = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self._draw_footer(total)
            super().showPage()
        super().save()

    def _draw_footer(self, total):
        self.saveState()
        w, _ = A4
        y = 0.4 * inch
        self.setFont("Helvetica", 8)
        self.setFillColor(GREY_DARK)
        self.drawString(0.6 * inch, y, f"{APP_TITLE} — Key Screens & Logic")
        self.setFillColor(RED_MID)
        self.drawRightString(w - 0.6 * inch, y,
                             f"Page {self._pageNumber} of {total}")
        self.setStrokeColor(RED_MID)
        self.setLineWidth(0.5)
        self.line(0.6 * inch, 0.55 * inch, w - 0.6 * inch, 0.55 * inch)
        self.restoreState()


# ── Styles ─────────────────────────────────────────────────────────────────────
def build_styles():
    base = getSampleStyleSheet()
    def ps(name, parent="Normal", **kw):
        return ParagraphStyle(name, parent=base[parent], **kw)

    return {
        "title": ps("T", "Title", fontSize=28, leading=34,
                    textColor=WHITE, alignment=TA_CENTER,
                    fontName="Helvetica-Bold", spaceAfter=4),
        "subtitle": ps("ST", fontSize=13, leading=17,
                       textColor=HexColor("#FADBD8"), alignment=TA_CENTER,
                       fontName="Helvetica"),
        "toc_head": ps("TH", "Heading1", fontSize=18, leading=22,
                       textColor=RED_DARK, fontName="Helvetica-Bold",
                       spaceBefore=0, spaceAfter=8),
        "toc_entry": ps("TE", fontSize=9, leading=13, textColor=GREY_DARK,
                        fontName="Helvetica"),
        "sec_head": ps("SH", "Heading2", fontSize=12, leading=15,
                       textColor=WHITE, fontName="Helvetica-Bold",
                       spaceBefore=0, spaceAfter=0),
        "file_head": ps("FH", "Heading3", fontSize=10, leading=13,
                        textColor=GREY_DARK, fontName="Helvetica-Bold",
                        spaceBefore=6, spaceAfter=2),
        "code": ps("CD", "Code", fontName="Courier", fontSize=7,
                   leading=10, textColor=GREY_DARK, backColor=BG_CODE,
                   borderColor=BORDER, borderWidth=0.5, borderPad=5,
                   leftIndent=4, spaceAfter=3, spaceBefore=2,
                   wordWrap="LTR"),
        "info": ps("IN", fontSize=8, leading=11, textColor=GREY_MID,
                   fontName="Helvetica-Oblique"),
    }


# ── Cover ──────────────────────────────────────────────────────────────────────
def build_cover(story, styles, file_count):
    w, _ = A4
    hdr = Table(
        [[Paragraph(APP_TITLE, styles["title"])],
         [Paragraph(SUBTITLE, styles["subtitle"])]],
        colWidths=[w - 2 * inch],
    )
    hdr.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), RED_DARK),
        ("ALIGN",      (0, 0), (-1, -1), "CENTER"),
        ("TOPPADDING",    (0, 0), (-1, 0), 28),
        ("BOTTOMPADDING", (0, 0), (-1, 0), 8),
        ("TOPPADDING",    (0, 1), (-1, 1), 4),
        ("BOTTOMPADDING", (0, 1), (-1, 1), 28),
    ]))
    story.append(Spacer(1, 0.5 * inch))
    story.append(hdr)
    story.append(Spacer(1, 0.35 * inch))

    info = Table(
        [["Generated", DATE],
         ["Files Included", str(file_count)],
         ["Language", "Dart / Flutter"],
         ["Architecture", "Feature-First + RBAC"]],
        colWidths=[1.8 * inch, 3.8 * inch],
    )
    info.setStyle(TableStyle([
        ("BACKGROUND",    (0, 0), (0, -1), RED_LIGHT),
        ("BACKGROUND",    (1, 0), (1, -1), GREY_LIGHT),
        ("TEXTCOLOR",     (0, 0), (-1, -1), GREY_DARK),
        ("FONTNAME",      (0, 0), (0, -1), "Helvetica-Bold"),
        ("FONTNAME",      (1, 0), (1, -1), "Helvetica"),
        ("FONTSIZE",      (0, 0), (-1, -1), 10),
        ("LEFTPADDING",   (0, 0), (-1, -1), 12),
        ("TOPPADDING",    (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
        ("GRID",          (0, 0), (-1, -1), 0.5, BORDER),
    ]))
    story.append(info)
    story.append(PageBreak())


# ── TOC ────────────────────────────────────────────────────────────────────────
def build_toc(story, styles, files):
    story.append(Paragraph("Table of Contents", styles["toc_head"]))
    story.append(HRFlowable(width="100%", thickness=1.2,
                            color=RED_DARK, spaceAfter=10))
    cur_sec = None
    for rel_path, _ in files:
        sec = section_label(rel_path)
        if sec != cur_sec:
            cur_sec = sec
            story.append(Spacer(1, 5))
            story.append(Paragraph(
                f'<b><font color="#C0392B">{esc(sec)}</font></b>',
                styles["toc_entry"]))
        story.append(Paragraph(
            f'&nbsp;&nbsp;&nbsp;&nbsp;{esc(rel_path.replace("lib/", ""))}',
            styles["toc_entry"]))
    story.append(PageBreak())


# ── Main ───────────────────────────────────────────────────────────────────────
def main():
    files = collect_files()
    print(f"Including {len(files)} key files")

    styles = build_styles()
    story  = []

    build_cover(story, styles, len(files))
    build_toc(story, styles, files)

    cur_sec = None
    w = A4[0]
    for i, (rel_path, full_path) in enumerate(files, 1):
        sec = section_label(rel_path)
        if sec != cur_sec:
            cur_sec = sec
            if i > 1:
                story.append(Spacer(1, 10))
            sec_tbl = Table(
                [[Paragraph(f"  {sec.upper()}", styles["sec_head"])]],
                colWidths=[w - 2 * inch],
            )
            sec_tbl.setStyle(TableStyle([
                ("BACKGROUND",    (0, 0), (-1, -1), RED_DARK),
                ("TOPPADDING",    (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
                ("LEFTPADDING",   (0, 0), (-1, -1), 8),
            ]))
            story.append(sec_tbl)
            story.append(Spacer(1, 6))

        fname = os.path.basename(rel_path)
        clean = rel_path.replace("lib/", "")

        try:
            with open(full_path, "r", encoding="utf-8", errors="replace") as f:
                raw = f.read()
        except Exception as e:
            raw = f"// Error: {e}"

        content = strip_code(raw)
        line_count = content.count("\n") + 1

        story.append(Paragraph(
            f'<font color="#C0392B">&#9632;</font> &nbsp;<b>{esc(fname)}</b>',
            styles["file_head"]))
        story.append(Paragraph(
            f'<font color="#7F8C8D">Path: {esc(clean)} &nbsp;|&nbsp; '
            f'Lines (stripped): {line_count}</font>',
            styles["info"]))
        story.append(Spacer(1, 3))
        story.extend(code_paragraphs(content, styles["code"]))
        story.append(HRFlowable(width="100%", thickness=0.4,
                                color=BORDER, spaceAfter=8))
        print(f"  [{i}/{len(files)}] {rel_path}  ({line_count} lines)")

    doc = SimpleDocTemplate(
        OUT_PDF,
        pagesize=A4,
        leftMargin=0.6 * inch, rightMargin=0.6 * inch,
        topMargin=0.65 * inch, bottomMargin=0.75 * inch,
        title=f"{APP_TITLE} - Key Screens & Logic",
        author=AUTHOR,
    )
    doc.build(story, canvasmaker=NumberedCanvas)
    size_kb = os.path.getsize(OUT_PDF) / 1024
    print(f"\nDONE! PDF -> {OUT_PDF}")
    print(f"   Size: {size_kb:.1f} KB  |  Files: {len(files)}")


if __name__ == "__main__":
    main()
