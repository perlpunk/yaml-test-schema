gh-pages:
	git worktree add gh-pages gh-pages

update:
	perl etc/generate-schema-html.pl

data-update:
	perl etc/generate-data-by-schema.pl yaml-schema.yaml
