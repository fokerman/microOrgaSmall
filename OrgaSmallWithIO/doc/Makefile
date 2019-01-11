all: orgaSmallwithIO_datasheet.pdf

orgaSmallwithIO_datasheet.pdf: orgaSmallwithIO_datasheet.tex
	pdflatex $^
	pdflatex $^
	rm -f *.log *.aux *.ent *.idx *.nav *.out *.snm *.toc *.vrb

clean:
	rm -f orgaSmallwithIO_datasheet.pdf
	rm -f *.log *.aux *.ent *.idx *.nav *.out *.snm *.toc *.vrb
