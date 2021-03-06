
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

# keep in mind :
# 	* "$@" corresponds to the target, 
# 	* "$<" corresponds the first dependency.

# include non-file target in .PHONY
.PHONY: these.pdf all clean mrproper

MAIN = these

PANDOC = pandoc
TEX = pdflatex
VIEWER = zathura

CHPTDIR=chapters
SRCS=$(shell find $(CHPTDIR) -name '*.md')
OBJS=$(patsubst %.md,$(CHPTDIR)/%.tex,$SRCS)

TMP_FILES=$(shell find . -name 'these.m*')

all: pertin_$(MAIN).pdf pertin_$(MAIN)_print.pdf

# compute the .pdf file using latexmk
$(MAIN).pdf: $(MAIN).tex $(MAIN).fmt $(OBJS)
	latexmk  				\
		-pdf 				\
		-pdflatex="$(TEX)"  \
		-use-make $<
		# use-make useless
	
# compute the .pdf file using latexmk (printable version)
$(MAIN)_print.pdf: $(MAIN)_print.tex $(MAIN)_print.fmt $(OBJS)
	latexmk  				\
		-pdf 				\
		-pdflatex="$(TEX)"  \
		-use-make $<
		# use-make useless

$(MAIN).fmt: header.tex these-LUNAM-UBL.cls
	$(TEX)                  \
	    -ini                \
	    -jobname="$(MAIN)"  \
	    "&$(TEX) header.tex\dump"

$(MAIN)_print.fmt: header_print.tex these-LUNAM-UBL.cls
	$(TEX)                  \
	    -ini                \
	    -jobname="$(MAIN)_print"  \
	    "&$(TEX) header_print.tex\dump"

pertin_$(MAIN).pdf: $(MAIN).pdf
	pdftk $< cat 1-r2 output $@

pertin_$(MAIN)_print.pdf: $(MAIN)_print.pdf
	pdftk $< cat 1-r2 output $@

# compute .tex files from .md files related to chapters
$(OBJS):
	cd $(CHPTDIR); make

open: $(MAIN).pdf
	$(VIEWER) $<

# clean temporary files
clean: 
	latexmk -c
ifneq ("$(wildcard $(word 1, $(TMP_FILES)))","")
	-rm $(TMP_FILES)
endif
	-cd $(CHPTDIR); make clean

# clean temporary files + PDF output
mrproper: clean 
	latexmk -C
	-rm these.fmt
	-rm pertin_these.pdf

