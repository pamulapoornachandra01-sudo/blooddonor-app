#!/usr/bin/env python3
import os
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.enums import TA_LEFT, TA_JUSTIFY

# Read the text file
with open('blood_donate_code.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# Split into sections
sections = content.split('FILE:')

# Create PDF
pdf_file = 'blood_donate_code.pdf'
doc = SimpleDocTemplate(pdf_file, pagesize=letter,
                        leftMargin=0.5*inch, rightMargin=0.5*inch,
                        topMargin=0.5*inch, bottomMargin=0.5*inch)

styles = getSampleStyleSheet()
code_style = ParagraphStyle(
    'Code',
    parent=styles['Normal'],
    fontName='Courier',
    fontSize=7,
    leading=8,
    spaceAfter=6,
    spaceBefore=6
)

story = []

# Add title
title = Paragraph("BLOOD DONATION APP - COMPLETE SOURCE CODE", styles['Title'])
story.append(title)
story.append(Spacer(1, 0.3*inch))

# Process each section
for section in sections:
    if section.strip():
        # Extract file path from section header
        lines = section.split('\n')
        if lines:
            file_path = lines[0].strip()
            header = Paragraph(f"<b>FILE:</b> {file_path}", styles['Heading3'])
            story.append(header)
            story.append(Spacer(1, 0.1*inch))
            
            # Add remaining content as code
            remaining = '\n'.join(lines[1:])
            if remaining.strip():
                # Split into chunks to avoid too long paragraphs
                chunks = remaining.split('###################################################')
                for chunk in chunks:
                    if chunk.strip():
                        # Clean up the text
                        clean_text = chunk.strip()
                        if len(clean_text) > 2000:
                            # Split large chunks
                            for i in range(0, len(clean_text), 2000):
                                p = Paragraph(clean_text[i:i+2000].replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;'), code_style)
                                story.append(p)
                        else:
                            p = Paragraph(clean_text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;'), code_style)
                            story.append(p)
                        story.append(Spacer(1, 0.1*inch))

# Build PDF
doc.build(story)
print(f"PDF generated: {pdf_file}")
print(f"Size: {os.path.getsize(pdf_file) / 1024:.1f} KB")
