var r = ""

for (i=0; i<len; i++) {
	r += `createMenuPageText(menuPageTexts[${page}][${i}], ${i})\n`;
}

r;