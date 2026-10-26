.PHONY: all build preview print ebook clean cleanall setup

# Vars
SRC     := $(CURDIR)
OUT     := $(CURDIR)/build
SCRIPTS := $(CURDIR)/scripts

ifeq ($(OS),Windows_NT)
IS_WINDOWS := 1
else
IS_WINDOWS := 0
endif

# Commands
ifeq ($(IS_WINDOWS),1)
LATEXMK := latexmk
DIST := Windows
PLATFORM := Windows
GS := $(strip $(shell powershell -NoProfile -ExecutionPolicy Bypass -Command "$$p = Get-Command gswin64c -ErrorAction SilentlyContinue; if ($$p) { $$p.Source } else { (Get-ChildItem 'C:/Program Files/gs/*/bin/gswin64c.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName) }"))
PANDOC := $(strip $(shell powershell -NoProfile -ExecutionPolicy Bypass -Command "$$p = Get-Command pandoc -ErrorAction SilentlyContinue; if ($$p) { $$p.Source } elseif (Test-Path 'C:/Users/$(USERNAME)/AppData/Local/Pandoc/pandoc.exe') { 'C:/Users/$(USERNAME)/AppData/Local/Pandoc/pandoc.exe' }"))
MAGICK := magick
else
LATEXMK := $(or $(shell command -v latexmk),latexmk)
DIST := $(shell lsb_release -si)
PLATFORM := $(shell uname)
GS := gs
PANDOC := pandoc
MAGICK := convert
endif

LATEXMK_FLAGS := -pdf
#LATEXMK_FLAGS += -silent
LATEXMK_FLAGS += -view=none
LATEXMK_FLAGS += -auxdir="${OUT}"
LATEXMK_FLAGS += -outdir="${OUT}"
ifeq ($(IS_WINDOWS),1)
LATEXMK_FLAGS += -pdflatex="pdflatex -file-line-error --shell-escape %%O %%S"
else
LATEXMK_FLAGS += -pdflatex="pdflatex -file-line-error --shell-escape %O %S"
endif
# LATEXMK_FLAGS += -e '$$makeindex=q/sh -c "cd `dirname "%D"`" ; makeindex %O -o "`basename "%D"`" "`basename "%S"`";/'

all: build

setup:
	@echo "Current Platform: $(PLATFORM)"
	@echo "Current Distribution: $(DIST)"
ifeq  ($(PLATFORM),Linux)
ifeq ($(DIST),$(shell echo -n "${DIST}" | grep "Ubuntu\|Debian\|Kali\|Linuxmint"))
	@sudo apt install texlive-latex-base texlive-lang-portuguese texlive-lang-english biber texlive-latex-extra texlive-science python3-pygments python3-proselint pandoc imagemagick latexmk ghostscript lacheck chktex
else
	@echo "Distribution not supported. Currently we support setup for: Ubuntu, Debian, Linuxmint and Kali"
endif
else
	@echo "Platform not supported. Currently we support setup for: Linux"
endif

build: 
	@echo "Building the document"
ifeq ($(IS_WINDOWS),1)
	@if not exist "${OUT}\chapters" mkdir "${OUT}\chapters"
	cd /d "${OUT}" && "${LATEXMK}" ${LATEXMK_FLAGS} -cd "${SRC}/thesis.tex"
else
	@mkdir -p "${OUT}/chapters"
	cd "${OUT}" ; "${LATEXMK}" ${LATEXMK_FLAGS} -cd "${SRC}/thesis.tex"
endif

preview: build
	@echo "Creating a preview PDF"
ifeq ($(IS_WINDOWS),1)
	"${LATEXMK}" ${LATEXMK_FLAGS} -pvc -cd "${SRC}/thesis.tex"
else
	("${LATEXMK}" ${LATEXMK_FLAGS} -pvc -cd "${SRC}/thesis.tex")
endif

print: build
	@echo "Creating print PDF"
ifeq ($(IS_WINDOWS),1)
ifeq ($(strip $(GS)),)
	@echo "Ghostscript not found. Install it or add gswin64c to PATH."
	@exit 1
else
	"${GS}" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${OUT}/thesis-print.pdf" "${OUT}/thesis.pdf"
endif
else
	"${SCRIPTS}/simplify-colors.sh" "${OUT}/thesis-print.pdf"
endif

ebook: build
	@echo "Creating ebook PDF"
ifeq ($(strip $(GS)),)
	@echo "Ghostscript not found. Install it or add gs/gswin64c to PATH."
	@exit 1
else
	"${GS}" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${OUT}/thesis-ebook.pdf" "${OUT}/thesis.pdf"
endif

clean: 
	@echo "Deleting all files except PDFs in the build directory"
ifeq ($(IS_WINDOWS),1)
	powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '${OUT}' -Recurse -File | Where-Object { $$_.Name -notlike '*.pdf' -and $$_.Name -ne '.gitkeep' } | Remove-Item -Force"
	powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '${OUT}' -Recurse -Directory | Sort-Object FullName -Descending | Where-Object { @(Get-ChildItem -LiteralPath $$_.FullName -Force).Count -eq 0 } | Remove-Item -Force"
else
	find "${OUT}" -type f ! \( -name '*.pdf' -o -name '.gitkeep' \) -delete
	find "${OUT}"/* -empty -type d -delete
endif

clean_aux:
	@echo "Deleting AUX files in the build directory"
ifeq ($(IS_WINDOWS),1)
	powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '${OUT}' -Recurse -File -Filter '*.aux' | Remove-Item -Force"
else
	find "${OUT}" -type f -name '*.aux' -delete
endif

cleanall: 
	@echo "Deleting all files in the build directory"
ifeq ($(IS_WINDOWS),1)
	powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path '${OUT}') { Get-ChildItem -Path '${OUT}' -Force | Remove-Item -Recurse -Force }"
else
	rm -rf "${OUT}/*"
endif

lint:
ifeq ($(strip $(texfile)),)
ifeq ($(IS_WINDOWS),1)
	for /f "delims=" %%f in ('dir /b /on chapters\\*.tex') do @echo * chapters/%%f && @$(MAKE) --no-print-directory lint texfile="chapters/%%f"
else
	+@for f in `ls -v chapters/*.tex`; do  \
		echo "* $$f";  \
		make --no-print-directory lint texfile="$$f";  \
	done
endif
else
	@lacheck "$(texfile)"
	@chktex -q --verbosity=3 "$(texfile)"
ifeq ($(IS_WINDOWS),1)
	@if not exist "${PANDOC}" echo "Pandoc not found. Install it or add pandoc.exe to PATH." && exit 1
endif
	$(eval txtfile := $(shell echo "$(OUT)/`basename "$(texfile)" .tex`.txt"))
	@"${PANDOC}" -s "$(texfile)" -o "$(txtfile)"
	@proselint "$(txtfile)" || true
endif
