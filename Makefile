REPO := $(shell git config --get remote.origin.url)
GHPAGES := gh-pages

LESSC := node_modules/less/bin/lessc
LESSDIR := less
LESSFILE := $(LESSDIR)/main.less
CSSDIR := $(GHPAGES)/css
CSSFILE := $(CSSDIR)/main.css
INDEXFILE := $(GHPAGES)/index.html

ICOFILE := favicon.ico
FAVICON := $(GHPAGES)/$(ICOFILE)

all: init $(GHPAGES) $(CSSFILE) $(addprefix $(GHPAGES)/, $(addsuffix .html, $(basename $(wildcard *.md)))) $(INDEXFILE)

$(INDEXFILE): $(GHPAGES)/README.html
	mv "$<" "$@"

$(GHPAGES)/%.html: %.md
	@# uncomment if not using YAML pagetitle
	@# pandoc -s -V pagetitle:'$(notdir $(basename $@))' -c "css/main.css" -f markdown -t html5 -o "$@" "$<"
	pandoc -s -c "css/main.css" -f markdown -t html5 -o "$@" "$<"

$(CSSFILE): $(CSSDIR) $(LESSFILE)
	$(LESSC) "$(LESSFILE)" "$@"

$(CSSDIR):
	[ -d $(CSSDIR) ] || mkdir "$(CSSDIR)"

$(GHPAGES):
	[ -d $(GHPAGES) ] || git clone "$(REPO)" "$(GHPAGES)"
	(cd $(GHPAGES) && git checkout $(GHPAGES)) || (cd $(GHPAGES) && git checkout --orphan $(GHPAGES) && git rm -rf .)

init:
	@command -v pandoc > /dev/null 2>&1 || (echo 'pandoc not found http://johnmacfarlane.net/pandoc/installing.html' && exit 1)
	@[ -x $(LESSC) ] || npm install

serve:
	(cd gh-pages && python -m SimpleHTTPServer) || echo 'Have you run make yet?'

clean:
	rm -rf gh-pages

commit:
	(cd gh-pages && git add . && git commit --edit --message="Publish @$$(date)")
	(cd gh-page && git push origin gh-pages)

.PHONY: init gh-pages clean serve