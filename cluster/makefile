TARGET=cluster
EPS=$(shell ls *.eps)
TEX=platex
DVIPDF=dvipdfmx

.SUFFIXES: .tex .dvi .pdf

all:$(TARGET).pdf
	open $<

$(TARGET).dvi: $(TARGET).tex $(EPS)

.tex.dvi:
	$(TEX) $<
	$(TEX) $<

tar:
	tar cvzf $(TARGET).tar.gz $(TARGET).* *.eps

.dvi.pdf:
	$(DVIPDF) $(TARGET)

clean:
	rm -f $(TARGET).dvi $(TARGET).aux $(TARGET).log $(TARGET).toc
	rm -f $(TARGET).pdf $(TARGET).tar.gz 
	rm -f *.pbm *.bmc
