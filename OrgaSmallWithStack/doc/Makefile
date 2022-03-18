all: orgaSmallwithStack_datasheet.pdf

orgaSmallwithStack_datasheet.pdf: orgaSmallwithStack_datasheet.tex
	pdflatex $^
	pdflatex $^
	rm -f *.log *.aux *.ent *.idx *.nav *.out *.snm *.toc *.vrb

clean:
	rm -f orgaSmallwithStack_datasheet.pdf
	rm -f *.log *.aux *.ent *.idx *.nav *.out *.snm *.toc *.vrb
