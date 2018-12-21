all: orgaSmall_datasheet.pdf

orgaSmall_datasheet.pdf: orgaSmall_datasheet.tex
	pdflatex $^
	pdflatex $^
	rm -f *.log *.aux *.ent *.idx *.nav *.out *.snm *.toc *.vrb

clean:
	rm -f orgaSmall_datasheet.pdf
	rm -f *.log *.aux *.ent *.idx *.nav *.out *.snm *.toc *.vrb
