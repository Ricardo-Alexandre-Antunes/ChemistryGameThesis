.PHONY: all build preview print ebook clean clean_aux cleanall lint

DOC_DIR := thesis-document

all:
	$(MAKE) -C $(DOC_DIR) build

build:
	$(MAKE) -C $(DOC_DIR) build

preview:
	$(MAKE) -C $(DOC_DIR) preview

print:
	$(MAKE) -C $(DOC_DIR) print

ebook:
	$(MAKE) -C $(DOC_DIR) ebook

clean:
	$(MAKE) -C $(DOC_DIR) clean

clean_aux:
	$(MAKE) -C $(DOC_DIR) clean_aux

cleanall:
	$(MAKE) -C $(DOC_DIR) cleanall

lint:
	$(MAKE) -C $(DOC_DIR) lint texfile="$(texfile)"
