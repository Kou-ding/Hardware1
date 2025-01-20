TEX_MAIN = report.tex

all: report

report: $(TEX_MAIN)
	# the shell-escape flag is needed for minted package
	latexmk -pdf -shell-escape  $(TEX_MAIN) 

clean:
	latexmk -C $(TEX_MAIN)
	rm -f *.bbl