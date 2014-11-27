REPO_ASSERT := $(shell git config --get remote.origin.url)
REPO ?= $(REPO_ASSERT)

GHPAGES = gh-pages

LESSC    = node_modules/less/bin/lessc
LESSFILE = less/main.less

CSSDIR  = $(GHPAGES)/css
CSSFILE = $(CSSDIR)/main.css

INDEXFILE = $(GHPAGES)/index.html
CHANGED := $(shell git status --porcelain | cut -c4- | grep .md)

all: init clean $(GHPAGES) $(CSSFILE) $(addprefix $(GHPAGES)/, $(addsuffix .html, $(basename $(wildcard *.md))))

$(GHPAGES)/%.html: %.md
	pandoc -s --template "_layout" -c "css/main.css" -f markdown -t html5 -o "$@" "$<"

$(CSSFILE): $(CSSDIR) $(LESSFILE)
	$(LESSC) "$(LESSFILE)" "$(CSSFILE)"

$(CSSDIR):
	mkdir "$(CSSDIR)"

$(GHPAGES):
	git clone "$(REPO)" "$(GHPAGES)"
	@(cd $(GHPAGES) && git checkout $(GHPAGES)) || (cd $(GHPAGES) && git checkout --orphan $(GHPAGES) && git rm -rf .)
	@if [ -n "$(CHANGED)" ]; then \
		touch $(CHANGED); \
	else\
		echo "No changed files found try 'make gh-pages/*.html'";\
	fi

init:
	@command -v pandoc > /dev/null 2>&1 || (echo 'pandoc not found http://johnmacfarlane.net/pandoc/installing.html' && exit 1)
	@[ -x $(LESSC) ] || npm install

serve:
	cd gh-pages && python -m SimpleHTTPServer

clean:
	rm -rf gh-pages

commit:
	cd $(GHPAGES) && \
		git add . && \
		git commit --message="Publish @$$(date)"
	cd $(GHPAGES) && \
		git push origin $(GHPAGES)

deploy:
	s3cmd sync --add-header=Expires:max-age=604800 --exclude '.git/*' --acl-public gh-pages/ s3://tylercipriani.com/links/

.PHONY: init gh-pages clean commit serve deploy