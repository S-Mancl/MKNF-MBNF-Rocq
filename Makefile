ROCQ ?= rocq c
PYTHON ?= python3
ROCQCHECK ?= rocq check
ROCQFLAGS ?= -Q theories MKNF
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
VFILES := theories/Finite.v theories/Syntax.v theories/Semantics.v \
          theories/Algorithms.v theories/MurderMystery.v
VOFILES := $(VFILES:.v=.vo)
.PHONY: all check clean help
all: $(VOFILES)
theories/%.vo: theories/%.v
	$(ROCQ) $(ROCQFLAGS) $<
theories/Syntax.vo: theories/Finite.vo
theories/Semantics.vo: theories/Finite.vo theories/Syntax.vo
theories/Algorithms.vo: theories/Finite.vo theories/Syntax.vo theories/Semantics.vo
theories/MurderMystery.vo: theories/Finite.vo theories/Syntax.vo theories/Semantics.vo theories/Algorithms.vo
check: all
	$(ROCQCHECK) -Q theories MKNF MKNF.Algorithms MKNF.MurderMystery
help:
	@printf '%s\n' 'make        Compile the sources with Rocq 9.1 and GNU Make' \
		'make check  Kernel-check the compiled chapters' 'make clean  Remove compilation outputs' 'make sources-zip  Re-zip the current sources without compiling them'
clean:
	@find theories -type f \( -name '*.vo' -o -name '*.vos' -o -name '*.vok' -o -name '*.glob' -o -name '*.aux' \) -delete

# This archive can contain unfinished proofs; packaging never invokes Rocq.
.PHONY: sources-zip
sources-zip: sources.zip
sources.zip: $(VFILES) Makefile _CoqProject README.md .gitignore
	$(PYTHON) -c 'import sys; from zipfile import ZipFile, ZIP_DEFLATED; \
	z = ZipFile(sys.argv[1], "w", ZIP_DEFLATED); \
	[z.write(p, p) for p in sys.argv[2:]]; z.close()' \
	sources.zip $(VFILES) Makefile _CoqProject README.md .gitignore
